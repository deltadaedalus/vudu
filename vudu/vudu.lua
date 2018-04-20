local vd = {
  _version = '0.1.1',
  colors_pre11 = {
    number = {80,112,255},
    string = {128, 32, 16},
    boolean = {127, 32, 96},
    ["function"] = {32, 127, 96},
    table = {96, 96, 96},
    userdata = {192, 160, 48},
    label = {48, 48, 48},
    index = {192, 192, 192},
  },

  colors = {
    number = {5/16, 7/16, 1},
    string = {1/2, 1/8, 1/16},
    boolean = {1/2, 1/8, 3/8},
    ["function"] = {1/8, 1/2, 3/8},
    table = {3/8, 3/8, 3/8},
    userdata = {3/4, 5/8, 3/16},
    label = {3/16, 3/16, 3/16},
    index = {3/4, 3/4, 3/4},
  },
  font = love.graphics.newFont(_vdpath .. "Inconsolata-Regular.ttf", 14),
  windows = {},
  timeScale = 0,  --The log2 of the speed at which the game plays
  paused = false, --is the game paused
  pauseType = "Play",
  hidden = false, --is the vudu ui hidden
  timer = 0,      --The total time passed accroding to vudu (i.e. real time)
  path = _vdpath,
}

vd.vuduUI = require(_vdpath .. "vuduUI")
vd.ui = vd.vuduUI.new()

vd.defaultSettings = {
  startHidden = true
}

--To be called from love.load, does what it says on the tin
function vd.initialize(settings)
  settings = settings or vd.defaultSettings
  vd.hidden = settings.startHidden

  vd.hook()
  for i, win in ipairs(vd.windows) do win:load() end
  vd.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

--injects vudu into the game
function vd.hook()
  local function dont() end
  local _update = love.update or dont
  local _draw = love.draw or dont
  local _mousepressed = love.mousepressed or dont
  local _mousereleased = love.mousereleased or dont
  local _keypressed = love.keypressed or dont
  local _keyreleased = love.keyreleased or dont
  local _wheelmoved = love.wheelmoved or dont
  local _textinput = love.textinput or dont
  local _resize = love.resize or dont
  local _print = print
  local _setMode = love.window.setMode
  
  
  love.update = function(dt)
    if not (vd.pauseType == "Stop") then
      _update((vd.pauseType == "Zero" and 0 or dt * 2^vd.timeScale))
    end
    vd.update(dt)
  end
  love.draw = function() _draw(); vd.draw() end
  love.mousepressed = function(...) _mousepressed(...); vd.mousepressed(...) end
  love.mousereleased = function(...) _mousereleased(...); vd.mousereleased(...) end
  love.keypressed = function(...) _keypressed(...); vd.keypressed(...) end
  love.keyreleased = function(...) _keyreleased(...); vd.keyreleased(...) end
  love.wheelmoved = function(...) _wheelmoved(...); vd.wheelmoved(...) end
  love.textinput = function(...) _textinput(...); vd.textinput(...) end
  love.resize = function(...) _resize(...); vd.resize(...) end
  print = function(...) if not vd.print(...) then _print(...) end end
  love.window.setMode = function(w, h, ...) _setMode(w, h, ...); vd.resize(w, h) end
end


function vd.update(dt)
  vd.timer = vd.timer + dt
  vd.ui:update(dt)
  for i, win in ipairs(vd.windows) do win:update(dt) end
end

function vd.draw()
  love.graphics.origin()
  if not vd.hidden then vd.ui:draw() end
  for i, win in ipairs(vd.windows) do if win.runHidden or not vd.hidden then
    win:draw()
  end end
end

function vd.mousepressed(x, y, button, isTouch)
  if not vd.hidden then vd.ui:mousepressed(x, y, button, isTouch) end
  for i, win in ipairs(vd.windows) do if win.runHidden or not vd.hidden then win:mousepressed(x - win.x, y - win.y, button, isTouch) end end
end

function vd.mousereleased(x, y, button, isTouch)
  if not vd.hidden then vd.ui:mousereleased(x, y, button, isTouch) end
  for i, win in ipairs(vd.windows) do if win.runHidden or not vd.hidden then win:mousereleased(x - win.x, y - win.y, button, isTouch) end end
end

function vd.keypressed(key, scancode, isrepeat)
  if (key == '`') then
    vd.hidden = not vd.hidden
  end
  if not vd.hidden then vd.ui:keypressed(key, scancode, isrepeat) end
  for i, win in ipairs(vd.windows) do  if win.runHidden or not vd.hidden then win:keypressed(key, scancode, isrepeat) end end
end

function vd.keyreleased(key, scancode, isrepeat)
  if not vd.hidden then vd.ui:keyreleased(key, scancode, isrepeat) end
  for i, win in ipairs(vd.windows) do if win.runHidden or not vd.hidden then win:keyreleased(key, scancode, isrepeat) end end
end

function vd.wheelmoved(x, y)
  if not vd.hidden then vd.ui:wheelmoved(x,y) end
  for i, win in ipairs(vd.windows) do if win.runHidden or not vd.hidden then win:wheelmoved(x, y) end end
end

function vd.textinput(text)
  if not vd.hidden then vd.ui:textinput(text) end
  for i, win in ipairs(vd.windows) do if win.runHidden or not vd.hidden then win:textinput(text) end end
end

function vd.resize(w, h)
  
end

function vd.addWindow(win)
   if (win.hasFrame) then
    vd.ui:addWidget(win.frame)
  end
  table.insert(vd.windows, win)
end

function vd.print(str)
  if (vd.console) then
    vd.console.addToHistory(str, true)
    return true
  end
  return false
end

function vd.getByName(refstr, env)
  local cur = env or _G
  for v in string.gmatch(refstr, "[^\\.]+") do
    v = tonumber(v) or v
    cur = cur[v]
  end
  return cur
end

function vd.setByName(refstr, value, env)
  local cur = env or _G
  local prev = nil
  local curV = nil
  for v in string.gmatch(refstr, "[^\\.]+") do
    v = tonumber(v) or v
    prev = cur
    cur = cur[v]
    curV = v
  end

  prev[curV] = value
end

function vd.resize(w, h)
  local vdw = math.min(350, math.max(math.floor(w/3), 200))
  local vdh = math.min(250, math.max(math.floor(h/4), 150))
  vd.browser.frame.w, vd.browser.frame.h = vdw, h - vdh - 6
  vd.control.frame.w, vd.control.frame.h, vd.control.frame.x, vd.control.frame.y = vdw, vdh, 2, h-vdh-2
  vd.console.frame.w, vd.console.frame.h, vd.console.frame.x, vd.console.frame.y = w-vdw-6, vdh, vdw+4, h-vdh-2

  vd.ui:resize(love.graphics.getWidth(), love.graphics.getHeight())
end

_G._vudu = vd

return vd


--[[
function vd.drawTable(t, x, y)
  love.graphics.setFont(vd.font)
  --print named elements
  for i, v in pairs(t) do if type(i) ~= 'number' and i ~= "vd_expand" then
    typ = type(v)
    love.graphics.print({vd.colors.label, i .. ': ', vd.colors[typ], tostring(v) .. ""}, x, y)
    if typ == 'table' and rawget(v, "vd_expand") or i == 'love' then
      y = vd.drawTable(v, x + 32, y + 14)
    end
    
    y = y + 14
  end end
  
  --print numbered elements
  for i, v in ipairs(t) do
    love.graphics.setColor(vd.colors[type(v)])
    love.graphics.print(tostring(v) .. "", x, y)
    love.graphics.setColor(vd.colors.index)
    love.graphics.printf(tostring(i), x - 104, y, 100, 'right')
    
    typ = type(v)
    if typ == 'table' and rawget(v, "vd_expand") or i == 'love' then
      y = vd.drawTable(v, x + 32, y + 14)
    end
    
    y = y + 14
  end
  
  return y - 14
end]]