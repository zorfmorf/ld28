
require 'chatHandler'
require("enet")
require 'text'

local host = nil
local client = nil
nameset = false
banned = false
name = "Anonymous"
globaltimer = 110

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
  
  host = enet.host_create()
  client = host:connect("85.214.38.169:4419")
  chatHandler_init()
  
  	
	-- all audio shit
	abanned = love.audio.newSource("res/banned.ogg")
	abell = love.audio.newSource("res/bell.ogg")
	amessage = love.audio.newSource("res/message.ogg")
	atheme = love.audio.newSource("res/theme.ogg")
	atheme:setLooping(true)
	atheme:play()
end


function love.update(dt)
    chatHandler_update(dt)
    if nameset and not banned then
      local event = host:service()
      if event then
        if event.type == "connect" then
          chatHandler_add("Connected to "..tostring(event.peer))
          client:send("6#"..name.."#false")
        elseif event.type == "receive" then
          print(event.data)
          t = split(event.data, "#")
          if t[1] == "7" then
             chatHandler_add(t[3], t[2])
             amessage:play()
          elseif t[1] == "5" then
            chatHandler_add("User "..t[2].." disconnected")
          elseif t[1] == "6" then
            chatHandler_add("User "..t[2].." connected")
          elseif t[1] == "3" then
            chatHandler_add("Server: "..t[2])
          elseif t[1] == "2" then
            chatHandler_add("Server: "..t[2])
            banned = true
            abanned:play()
          elseif t[1] == "9" then
            if tonumber(t[2]) > globaltimer then
              timerred = 1
              abell:play()
            else
              timerred = -1
            end
            globaltimer = t[2]
          elseif t[1] == "4" then
            users = {}
            for i,u in pairs(t) do
              if u ~= "4" then
                users[i-1] = u
              end
            end
          else
            chatHandler_add(event.data)
          end
        end
      end
      globaltimer = math.max(0, globaltimer - dt)
    end
end

function love.draw()
  
  chatHandler_draw()
  
end

function love.keypressed(key, isrepeat)
  
  if not banned then
    local m, n = chatHandler_input(key)
    
    if m ~= nil then
      client:send("7#"..n.."#"..m)
    end
  end
  
end

function love.quit()
  client:disconnect()
  host:flush()
end
