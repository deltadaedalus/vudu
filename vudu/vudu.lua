local vdUtil = require(_vdpath .. "vuduUtil")

local vd = {
  _version = '0.1.1',
  colors_pre11 = {
    number = {80, 112, 255, 255},
    string = {128, 32, 16, 255},
    boolean = {127, 32, 96, 255},
    ["function"] = {32, 127, 96, 255},
    table = {96, 96, 96, 255},
    userdata = {192, 160, 48, 255},
    label = {48, 48, 48, 255},
    text = {0, 0, 0, 255},
    --
    window = {250, 250, 250, 255},
    highlight = {128, 96, 192, 255},
    midhighlight = {224, 224, 224, 255},
    lowlight = {128, 128, 128, 255},
    --
    buttonIdle = {192, 192, 192, 255},
    buttonHover = {200, 200, 200, 255},
    buttonPress = {208, 192, 240, 255},
    --
    consoleCommand = {208, 216, 224, 255},
    consoleResponse = {224, 232, 240, 255},
    consoleError = {240, 224, 232, 255},
  },

  colors = {
    number = {5/16, 7/16, 1},
    string = {1/2, 1/8, 1/16},
    boolean = {1/2, 1/8, 3/8},
    ["function"] = {1/8, 1/2, 3/8},
    table = {3/8, 3/8, 3/8},
    userdata = {3/4, 5/8, 3/16},
    label = {3/16, 3/16, 3/16},
    text = {0, 0, 0},
    --
    window = {250/255, 250/255, 250/255},
    highlight = {1/2, 3/8, 3/4},
    midhighlight = {7/8, 7/8, 7/8},
    lowlight = {1/2, 1/2, 1/2},
    --
    buttonIdle = {3/4, 3/4, 3/4},
    buttonHover = {25/32, 25/32, 25/32},
    buttonPress = {13/16, 3/4, 15/16},
    --
    consoleCommand = {13/16, 27/32, 7/8},
    consoleResponse = {7/8, 29/32, 15/16},
    consoleError = {15/16, 7/8, 29/32},
  },
  font = love.graphics.newFont(_vdpath .. "Inconsolata-Regular.ttf", 14),
  windows = {},
  timeScale = 0,  --The log2 of the speed at which the game plays
  paused = false, --is the game paused
  pauseType = "Play",
  hidden = false, --is the vudu ui hidden
  timer = 0,      --The total time passed accroding to vudu (i.e. real time)
  path = _vdpath,
  showSettings = false,
}

vd.colors = love._version_major >= 11 and vd.colors or vd.colors_pre11
_G._vudu = vd

vd.vuduUI = require(_vdpath .. "vuduUI")
vd.ui = vd.vuduUI.new()

vd.defaultSettings = {
  startHidden = true,
  showFunctions = false
}

--To be called from love.load, does what it says on the tin
function vd.initialize(settings)
  settings = settings or vd.defaultSettings
  vd.hidden = settings.startHidden
  vd.showFunctions = settings.showFunctions
  if settings.theme then vd.setTheme(settings.theme) end

  vd.hook()
  for i, win in ipairs(vd.windows) do win:load() end
  vd.initSettingsUI()
  vd.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

function vd.initSettingsUI()
  local settingsButton = vd.vuduUI.widget.new(778, 2, 20, 20, 6, {
    onResize = function(self) self:gravR(2) end,
    onRelease = vd.toggleSettings,
  })
  vd.settingsFrame = vd.vuduUI.widget.frame.new(0, 0, 150, 100, 6, {
    onResize = function(self) self:setY(24); self:gravR(2); self:setH(#self.widgets*9+2) end, 
    idleColor = vd.colors.window
  })
  vd.addSettingsOption(vd.settingsFrame, "Show Functions", "_vudu.showFunctions", 150, 2)

  vd.ui:addWidget(settingsButton)
end

function vd.addSettingsOption(frame, label, ref, x, y)
  local button = vd.vuduUI.widget.checkBox.new(x-17, y+1, 14, 14, 6, {targetRef = ref})
  local label = vd.vuduUI.widget.text.new(x-166, y, 150, 16, 6, label, {alignment = 'right', idleColor = {0,0,0,0}, textColor = vd.colors.label, unClickable = true})
  frame:addWidget(button)
  frame:addWidget(label)
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
  love.mousepressed = function(...) if not (vd.pauseType == "Stop") then _mousepressed(...) end; vd.mousepressed(...) end
  love.mousereleased = function(...) if not (vd.pauseType == "Stop") then _mousereleased(...) end; vd.mousereleased(...) end
  love.keypressed = function(...) if not (vd.pauseType == "Stop") then _keypressed(...) end; vd.keypressed(...) end
  love.keyreleased = function(...) if not (vd.pauseType == "Stop") then _keyreleased(...) end; vd.keyreleased(...) end
  love.wheelmoved = function(...) if not (vd.pauseType == "Stop") then _wheelmoved(...) end; vd.wheelmoved(...) end
  love.textinput = function(...) if not (vd.pauseType == "Stop") then _textinput(...) end; vd.textinput(...) end
  love.resize = function(...) _resize(...); vd.resize(...) end
  print = function(...) if not vd.print(...) then _print(...) end end
  love.window.setMode = function(w, h, ...) _setMode(w, h, ...); vd.resize(w, h) end
end

--Internal Callbacks and such
do
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
    if love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then x, y = y, x end
    if not vd.hidden then vd.ui:wheelmoved(x,y) end
    for i, win in ipairs(vd.windows) do if win.runHidden or not vd.hidden then win:wheelmoved(x, y) end end
  end

  function vd.textinput(text)
    if not vd.hidden then vd.ui:textinput(text) end
    for i, win in ipairs(vd.windows) do if win.runHidden or not vd.hidden then win:textinput(text) end end
  end

  function vd.resize(w, h)
    local vdw = math.min(350, math.max(math.floor(w/3), 200))
    local vdh = math.min(250, math.max(math.floor(h/4), 150))
    vd.browser.frame.w, vd.browser.frame.h = vdw, h - vdh - 6
    vd.control.frame.w, vd.control.frame.h, vd.control.frame.x, vd.control.frame.y = vdw, vdh, 2, h-vdh-2
    vd.console.frame.w, vd.console.frame.h, vd.console.frame.x, vd.console.frame.y = w-vdw-6, vdh, vdw+4, h-vdh-2

    vd.ui:resize(love.graphics.getWidth(), love.graphics.getHeight())
  end

  function vd.toggleSettings()
    vd.showSettings = (not vd.showSettings)
    if vd.showSettings then
      vd.ui:addWidgetFront(vd.settingsFrame)
      vd.settingsFrame:onResize()
      vd.settingsFrame:propagateResize()
    else
      vd.ui:removeWidget(vd.settingsFrame)
    end
  end

  function vd.print(str)
    if (vd.console) then
      vd.console.addToHistory(str, true)
      return true
    end
    return false
  end

  function vd.addWindow(win)
    if (win.hasFrame) then
    vd.ui:addWidget(win.frame)
  end
  table.insert(vd.windows, win)
  end
end

--API
function vd.getByName(refstr, env)
  local cur = env or _G
  if refstr == '' then return cur end
  for v in string.gmatch(refstr, "[^\\.]+") do
    if type(cur) ~= 'table' then return nil end
    v = tonumber(v) or v
    cur = cur[v]
    if cur == nil then return nil end
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

function vd.setIgnore(ig, state)
  state = state == nil and true or false
  if (type(ig) == 'table') then
    for i, v in ipairs(ig) do
      vd.ignore[v] = state
    end
  else
    vd.ignore[ig] = state
  end
end

function vd.setTheme(path)
  local theme = love.filesystem.load(path)()
  for i, v in pairs(theme.colors) do vdUtil.copyColor(theme.colors[i], vd.colors[i]) end
  for i, v in pairs(theme.colors_pre11) do vdUtil.copyColor(theme.colors_pre11[i], vd.colors_pre11[i]) end
end

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