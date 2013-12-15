
local messages = {}
users = {}

local timer = 0

local blink = false

local function getMssg(index)
  if messages[index][1] == nil then
    return messages[index][2]
  end
  return messages[index][1]..": "..messages[index][2]
end

function chatHandler_init()
  
  name = "Anonymous"
  
  input = ""
  
  font = love.graphics.newFont( "res/Xolonium-Regular.otf", love.graphics:getHeight() / 40 )
  
end

function chatHandler_update(dt)
  
  local old = timer
  timer = timer + dt
  
  if math.floor(timer) ~= math.floor(old) then blink = not blink end
  
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
  love.graphics.rectangle("line", xpad, yw - ypad - yw / 20, xw - xpad * 2, yw / 20 )
  
  local ti = input
  if blink then ti = ti.."|" end
  
  love.graphics.print(ti, xpad * 2, yw - ypad * 0.5 - yw / 20)
  
  if nameset then
  
    -- draw users box
  
    love.graphics.rectangle("line", xw - xw * 0.2, ypad, xw * 0.2 - xpad, yw - ypad * 3 - yw / 20 )
    local delim = ypad
    for i,u in pairs(users) do
      love.graphics.print(u, xw - xw * 0.2 + 5, delim)
      delim = delim + font:getHeight()
      if delim > yw - ypad * 5 - yw / 20 then 
        love.graphics.print("...", xw - xw * 0.2 + 5, delim)
        break
      end
    end
  
  
    -- draw message box
    
    local mbw = xw * 0.8 - xpad * 2
    love.graphics.rectangle("line", xpad, ypad, mbw, yw - ypad * 3 - yw / 20 )
    local delim = ypad + yw - ypad * 3 - yw / 20
    for i=#messages,1, -1 do
      local w,l = font:getWrap(getMssg(i), mbw)
      delim = delim - font:getHeight() * l
      if delim < ypad then break end
      love.graphics.printf( getMssg(i), xpad + 5, delim, mbw, "left" )
    end
  else
    love.graphics.print("Enter a name of at least 4 digits and press enter", 100, 100)
  end
end

function chatHandler_input(key)
  if key == "return" and ((nameset and input:len() > 0) or (not nameset and input:len() > 4)) then
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
  elseif key:len() == 1 and key ~= "#" then
     input = input..key
  end
  return nil
end

function chatHandler_add(mssg, id)
  messages[#messages + 1] = {id, mssg} 
end
