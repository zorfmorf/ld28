
local messages = {}
users = {}

local timer = 0
local bantimer = 0

local blink = false

-- returns message and if the message is a server message
local function getMssg(index)
  if messages[index][1] == nil then
    return " > "..messages[index][2], true
  end
  return messages[index][1]..": "..messages[index][2], false
end

function chatHandler_init()
  
  name = "Anonymous"
  
  input = ""
  
  font = love.graphics.newFont( "res/Xolonium-Regular.otf", love.graphics:getHeight() / 40 )
  fontOver = love.graphics.newFont( "res/Xolonium-Regular.otf", love.graphics:getHeight() / 5 )
  fontTitle = love.graphics.newFont( "res/Xolonium-Regular.otf", love.graphics:getHeight() / 9 )
  fontNumber = love.graphics.newFont( "res/Xolonium-Regular.otf", love.graphics:getHeight() / 20 )
  
end

function chatHandler_update(dt)
  
  local old = timer
  timer = timer + dt
  
  if math.floor(timer) ~= math.floor(old) then blink = not blink end
  
  if banned then
     bantimer = bantimer + dt
  end
  
end

function chatHandler_draw()
  
  love.graphics.setBackgroundColor(53, 90 + 70 * math.sin(timer / 8), 120 + 120 * math.sin(timer / 5), 255)
  love.graphics.setFont( font )
  
  local xw = love.graphics:getWidth()
  local yw = love.graphics:getHeight()
  local xpad = xw / 80
  local ypad = yw / 50
  
  -- draw input box
  
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.rectangle("line", xpad, yw - ypad - yw / 20, xw * 0.9 - xpad * 2, yw / 20 )
  
  local ti = input
  if blink then ti = ti.."|" end
  
  love.graphics.print(ti, xpad * 2, yw - ypad * 0.5 - yw / 20)

  
  if nameset then
    
    -- timer 
    
    love.graphics.setFont(fontNumber)
    love.graphics.printf(math.floor(globaltimer), xw - xw * 0.1, yw - ypad * 1.5 - yw / 20, xw * 0.1, "center")
    love.graphics.setFont( font )
  
    -- draw users box
  
    love.graphics.rectangle("line", xw - xw * 0.25, ypad, xw * 0.25 - xpad, yw - ypad * 3 - yw / 20 )
    local delim = ypad
    for i,u in pairs(users) do
      love.graphics.print(u, xw - xw * 0.25 + 10, delim)
      delim = delim + font:getHeight()
      if delim > yw - ypad * 5 - yw / 20 then 
        love.graphics.print("...", xw - xw * 0.25 + 5, delim)
        break
      end
    end
  
  
    -- draw message box
    
    local mbw = xw * 0.75 - xpad * 2
    love.graphics.rectangle("line", xpad, ypad, mbw, yw - ypad * 3 - yw / 20 )
    local delim = ypad + yw - ypad * 3 - yw / 20
    for i=#messages,1, -1 do
      love.graphics.setColor(255, 255, 255, 255)
      local m, serv = getMssg(i)
      if serv then
        love.graphics.setColor(200, 200, 200, 255)
      end
      local w,l = font:getWrap(m, mbw)
      delim = delim - font:getHeight() * l - 5
      if delim < ypad then break end
      love.graphics.printf( m, xpad, delim, mbw, "left" )
    end
  else
    love.graphics.setFont(fontTitle)
    love.graphics.print(text_title, xw / 2, yw / 10, 0, 1, 1, fontTitle:getWidth(text_title) / 2)
    love.graphics.setFont( font )
    love.graphics.printf(text_tutorial, xw / 5, yw / 5 * 2, xw / 5 * 3, "left")
  end
  
  -- ban box
  if banned then
    love.graphics.setFont(fontOver)
    love.graphics.setColor(0, 0, 0, 200 * math.sin(math.min(math.pi / 2, bantimer * 0.3)))
    love.graphics.rectangle("fill", 0, 0, xw, yw)
    love.graphics.setColor(255, 255, 255, math.min(20 * bantimer, 255))
    love.graphics.printf("Banned", xw / 2 - fontOver:getWidth("Banned") / 2, yw/2 - fontOver:getHeight() / 2, 
      xw, "left", 0, 1, 1, 0, 0, math.sin(bantimer * 0.4) * 0.25, math.cos(bantimer * 0.3) * 0.25)
  end
end

local function validKey(key)  
  
  for i=97,122 do
     if string.char(i) == key then return true end
  end
  
  for i=48,57 do
     if string.char(i) == key then return true end
  end
  
  if key == " " or key == "?" or key == "!" then return true end
  
  return false
end

function chatHandler_input(key)
  if key == "return" and ((nameset and input:len() > 0) or (not nameset and input:len() > 3)) then
     local retm = input
     input = ""
     if nameset then
      return retm, name
     else
       name = retm
       nameset = true
     end
  elseif key == "backspace" then
     input = input:sub(1, input:len() - 1)
  elseif key:len() == 1 and validKey(key) and input:len() < 100 then
     input = input..key
  end
  return nil
end

function chatHandler_add(mssg, id)
  messages[#messages + 1] = {id, mssg} 
end
