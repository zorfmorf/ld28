-- server
require("enet")

port = 27395

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
	host = enet.host_create("localhost:"..port)
	print("Listening on port "..port)
	users = {}
end

local function sendAll(message)
	for i=1,host:peer_count() do

		local peer = host:get_peer(i)

		if peer:state() == "connected" then

			peer:send(message)

		end
	end
end

local function getUsersList()
	local rets = ""
	for i,u in pairs(users) do
		rets = rets.."#"..u
	end
	return rets
end


function love.update(dt)
	local event = host:service(100)
	if event then 
		if event.type == "receive" then
			print("Got message: ", event.data, event.peer)
			
			t = split(event.data, "#")
			
			if t[1] == "7" and #t == 3 then
				sendAll(event.data)
			end
			
			if t[1] == "6" and #t == 2 then
				users[event.peer:index()] = t[2]
				event.peer:send("4"..getUsersList())
				sendAll("6#"..users[event.peer:index()])
			end
			
		end
		if event.type == "connect" then
			print("Connect: ", event.data, event.peer)		
		end
		if event.type == "disconnect" then
			print("Disconnect: ", event.data, event.peer)
			sendAll("5#"..users[event.peer:index()])
			users[event.peer:index()] = nil
			sendAll("4"..getUsersList())
		end
	end
end

function love.draw()
	love.graphics.print("I am a running server application. If you terminate me, I will terminate you!", 50, 50)
end
