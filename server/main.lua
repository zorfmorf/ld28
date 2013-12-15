-- server
require("enet")
require 'slither'
require 'challenge'
require 'names'
require 'bot'

STATE_PAUSED = 1
STATE_ACTIVE = 2
STATE_COUNTING = 3

challenge = nil
challengetimer = 0

blacklist = {}
botlist = {}
bottimer = math.random(20)

port = 27395

-- backup messages file
local function backup()
	
	love.filesystem.remove( "mssgl.lst" )
	
	print("Starting backup...")
	
	for i,v in pairs(mssgl) do
		success, errormsg = love.filesystem.append( "mssgl.lst", i.."\n")
	end
	
	print("backup finished")
	
end

local function sendAll(message)
	for i=1,host:peer_count() do

		local peer = host:get_peer(i)

		if peer:state() == "connected" then

			peer:send(message)

		end
	end
end

local function initChallenge()
	sendAll("3#New Challenge imminent!")
	state = STATE_COUNTING
	counter = 6
end

local function isBanned(name)
	
	for i,bn in pairs(blacklist) do
		
		if bn == name then return true end
	
	end
	
	return false
	
end

local function ban(index)
	local peer = host:get_peer(index)
	local name = users[peer:index()][1]
	table.insert(blacklist, name)
	peer:send("2#You failed. BANNED")
	peer:disconnect_later()
	sendAll("3#"..name.." has been banned")
	
end

local function split(inputstr, sep)
  if sep == nil then
          sep = "%s"
  end
  t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
          t[i] = str
          i = i + 1
  end
  return t
end

function love.load()
	math.randomseed(os.time())
	
	-- check the messages file
	mssgl = {}
	mssgk = {}
	if love.filesystem.exists("mssgl.lst") then
		for line in love.filesystem.lines("mssgl.lst") do
			mssgl[line] = true
			table.insert(mssgk, line)
		end
	else
		mssgl = {"test"}
		mssgk = {"test"}
	end
	
	
	host = enet.host_create("localhost:"..port)
	print("Listening on port "..port)
	users = {}
	state = STATE_PAUSED

end

local function addTime(index, amount)
	print("Adding time: "..amount)
	local peer = host:get_peer(index)
	users[peer:index()][2] = users[peer:index()][2] + amount
	peer:send("9#"..users[peer:index()][2])
end

local function getUsersList()
	local rets = ""
	for i,u in pairs(users) do
		rets = rets.."#"..i.." - "..u[1]
	end
	return rets
end

local function calcPoints(length)
	
	local points = 0
	
	if length > 2 then
		points = points + 1
	end
	if length > 10 then
		points = points + 10
	end
	if length > 20 then
		points = points +20
	end
	
	return points
end

local function isBot(index)

	for i,bot in pairs(botlist) do
		
		if bot:getIndex() == index then
			return true
		end
	
	end
	
	return false
	
end


function love.update(dt)
	local event = host:service(100)
	if event then 
	
		if event.type == "receive" then
			print("Got message: ", event.data, event.peer)
			
			t = split(event.data, "#")
			
			if t[1] == "7" and #t == 3 then
			
				-- check if its a blame
				if t[3]:sub(1,5) == "blame" then
				
					local id = tonumber(t[3]:sub(6))
					
					sendAll(t[2].." laid the blame")
					
					if isBot(tonumber(id)) then
						
						ban(tonumber(id))
						addTime(event.peer:index(), 60)
						
					else
						
						ban(event.peer:index())
					end
					
				else
				
					sendAll(event.data)
					
					addTime(event.peer:index(), calcPoints(t[3]:len()))			
					
					if mssgl[t[3]] == false then
						mssgl[t[3]] = true
						table.insert(mssgk, t[3])
					end
					
					if state == STATE_ACTIVE and challenge ~= nil then
						
						if not challenge:check(t[3]) then
							
							sendAll(users[event.peer:index()][1].." failed the challenge")
							ban(event.peer:index())
							
						end
					
					end
					
				end
			end
			
			-- user authenticates self
			if t[1] == "6" and #t == 2 then
				
				if isBanned(t[2]) then
				
					event.peer:send("2#This username is banned")
					event.peer:disconnect_later()
				
				else
					
					users[event.peer:index()] = {}
					users[event.peer:index()][1] = t[2]
					users[event.peer:index()][2] = 60
					sendAll("6#"..users[event.peer:index()][1])
					event.peer:send("3#Welcome, "..t[2])
					event.peer:send("3#To blame someone, write: blame [id]")
					event.peer:send("3#Remember, you only get one chance")
					sendAll("4"..getUsersList())
					event.peer:send("9#"..users[event.peer:index()][2])
					
					if state == STATE_ACTIVE and challenge ~= nil then
						event.peer:send("3#Current Challenge: "..challenge:getText())
					end
					
					if state == STATE_PAUSED then
						initChallenge()
					end
				
				end
			end
			
		end
		
		-- connect still needs to auth
		if event.type == "connect" then
			print("Connect: ", event.data, event.peer)		
		end
		
		if event.type == "disconnect" then
			print("Disconnect: ", event.data, event.peer)
			
			if users[event.peer:index()] ~= nil then
				sendAll("5#"..users[event.peer:index()][1])
				users[event.peer:index()] = nil
				sendAll("4"..getUsersList())
			end
		end
	end
	
	if state == STATE_COUNTING then
		local old = counter
		counter = counter - dt
		if math.floor(old) ~= math.floor(counter) then
			sendAll("3#"..math.floor(old))
		end
		if counter < 0 then
			state = STATE_ACTIVE
			challenge = generateChallenge()
			sendAll("3#New Challenge: "..challenge:getText())
		end
	end
	
	if state == STATE_ACTIVE then
	
		if challenge == nil then
			challengetimer = challengetimer - dt
			if challengetimer < 0 then
				challenge = generateChallenge()
				sendAll("3#New Challenge: "..challenge:getText())
			end
		else
			finished = challenge:update(dt)
			if finished then
				sendAll("3#Challenge finished!")
				challenge = nil
				challengetimer = math.random(30, 100)
			end
		end
		
	end
	
	-- handle bots
	for i,bot in pairs(botlist) do
	
		local alive = bot:update(dt)
		
		if not alive then
			botlist[i] = nil
		end
		
	end
	
	bottimer = bottimer - dt
	if bottimer < 0 then
		table.insert(botlist, Bot())
		bottimer = bottimer + math.random(10, 50)
	end
	
	-- handle timer
	for i=1,host:peer_count() do
	
		local peer = host:get_peer(i)

		if peer:state() == "connected" and users[peer:index()] ~= nil then
			
			users[peer:index()][2] = users[peer:index()][2] - dt
			
			if users[peer:index()][2] <= 0 then
				sendAll(users[peer:index()][2].." ran out of time!")
				ban(peer:index())
			end

		end
	
	end
	
end


function love.draw()
	love.graphics.print("I am a running server application. If you terminate ME, I will terminate YOU!", 50, 50)
end


function love.quit()
	backup()
end
