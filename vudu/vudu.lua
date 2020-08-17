local vdUtil = require(_vdreq .. "vuduutil")

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
    dark = {96, 96, 96, 255},
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
    dark = {3/8, 3/8, 3/8, 255},
    --
    buttonIdle = {3/4, 3/4, 3/4},
    buttonHover = {25/32, 25/32, 25/32},
    buttonPress = {13/16, 3/4, 15/16},
    --
    consoleCommand = {13/16, 27/32, 7/8},
    consoleResponse = {7/8, 29/32, 15/16},
    consoleError = {15/16, 7/8, 29/32},
  },
  font = love.graphics.newFont(_vdpath .. "inconsolata-regular.ttf", 14),
  windows = {},
  timeScale = 0,  --The log2 of the speed at which the game plays
  paused = false, --is the game paused
  pauseType = "Play",
  hidden = false, --is the vudu ui hidden
  timer = 0,      --The total time passed accroding to vudu (i.e. real time)
  gameTimer = 0,  --The total time passed in-game, respectful to fast-forward and slow motion
  path = _vdpath,
  showSettings = false,
  camera = {x = 0, y = 0, r = 0, z = 1, transform = love.math.newTransform()},
}

vd.colors = love._version_major >= 11 and vd.colors or vd.colors_pre11
_G._vudu = vd

vd.vuduUI = require(_vdreq .. "vuduui")
vd.ui = vd.vuduUI.new()

vd.defaultSettings = {
  startHidden = true,
  showFunctions = false,
  showUnderscores = false,
}

vd.savedSettings = love.filesystem.load("vudusettings.lua")

--To be called from love.load, does what it says on the tin
function vd.initialize(settings)
  settings = settings or (vd.savedSettings and vd.savedSettings()) or vd.defaultSettings
  vd.hidden = settings.startHidden or false
  vd.showFunctions = settings.showFunctions
  vd.showUnderscores = settings.showUnderscores
  if settings.theme then vd.setTheme(settings.theme) end

  vd.hook()
  for i, win in ipairs(vd.windows) do win:load() end
  vd._initSettingsUI()
  vd.resize(love.graphics.getWidth(), love.graphics.getHeight())

  vd.camera.x = love.graphics.getWidth()/2
  vd.camera.y = love.graphics.getHeight()/2
end

function vd.initializeDefaultHotkeys(mod)
  mod = mod or 'lalt'
  --Pause/Play
  vd.hotkey.addSequence({mod, 'space'}, function() vd.control.setPauseType(vd.paused and "Play" or "Zero") end)
  vd.hotkey.addSequence({mod, 'p'}, function() vd.control.setPauseType("Zero") end)
  vd.hotkey.addSequence({mod, 'lshift', 'p'}, function() vd.control.setPauseType("Stop") end)
  vd.hotkey.addSequence({mod, '1'}, function() vd.control.setPauseType("Stop"); vd.advanceSingleFrame() end)

  --Speed
  vd.hotkey.addSequence({mod, ','}, function() vd.timeScale = vd.timeScale - 1 end)
  vd.hotkey.addSequence({mod, '.'}, function() vd.timeScale = vd.timeScale + 1 end)
  vd.hotkey.addSequence({mod, '/'}, function() vd.timeScale = 0 end)

  --Camera
  vd.hotkey.addSequence({mod, 'left'}, function() vd.camera.x = vd.camera.x - love.graphics.getWidth() * 0.25 * vd.camera.z; vd._refreshCameraTransform() end)
  vd.hotkey.addSequence({mod, 'right'}, function() vd.camera.x = vd.camera.x + love.graphics.getWidth() * 0.25 * vd.camera.z; vd._refreshCameraTransform() end)
  vd.hotkey.addSequence({mod, 'up'}, function() vd.camera.y = vd.camera.y - love.graphics.getHeight() * 0.25 * vd.camera.z; vd._refreshCameraTransform() end)
  vd.hotkey.addSequence({mod, 'down'}, function() vd.camera.y = vd.camera.y + love.graphics.getHeight() * 0.25 * vd.camera.z; vd._refreshCameraTransform() end)
  vd.hotkey.addSequence({mod, '-'}, function() vd.camera.z = vd.camera.z * 1.25; vd._refreshCameraTransform() end)
  vd.hotkey.addSequence({mod, '='}, function() vd.camera.z = vd.camera.z / 1.25; vd._refreshCameraTransform() end)
  vd.hotkey.addSequence({mod, 'left', 'right'}, function() vd.camera.z = 1; vd.camera.x = love.graphics.getWidth()/2; vd.camera.y = love.graphics.getHeight()/2; vd._refreshCameraTransform() end)
  vd.hotkey.addSequence({mod, 'right', 'left'}, function() vd.camera.z = 1; vd.camera.x = love.graphics.getWidth()/2; vd.camera.y = love.graphics.getHeight()/2; vd._refreshCameraTransform() end)
end

--Creates the settings button
function vd._initSettingsUI()
  local settingsButton = vd.vuduUI.widget.new(778, 2, 20, 20, 6, {
    idleColor = vd.colors.highlight,
    onResize = function(self) self:gravR(2) end,
    onRelease = vd.toggleSettings,
  })
  vd.settingsFrame = vd.vuduUI.widget.frame.new(0, 0, 150, 100, 6, {
    onResize = function(self) self:setY(24); self:gravR(2); self:setH(#self.widgets*9+2) end, 
    idleColor = vd.colors.window
  })
  vd._addSettingsOption(vd.settingsFrame, "Show Functions", "_vudu.showFunctions", 150, 2)
  vd._addSettingsOption(vd.settingsFrame, "Show Underscores", "_vudu.showUnderscores", 150, 18)

  vd.ui:addWidget(settingsButton)
end

--Adds a toggle button to the settings frame
function vd._addSettingsOption(frame, label, ref, x, y)


  local button = vd.vuduUI.widget.checkBox.new(x-17, y+1, 14, 14, 6, {targetRef = ref})
  local label = vd.vuduUI.widget.text.new(x-166, y, 150, 16, 6, label, {alignment = 'right', idleColor = {0,0,0,0}, textColor = vd.colors.label, unClickable = true})
  frame:addWidget(button)
  frame:addWidget(label)
end

--monkeypatches vudu into the game
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
  local _quit = love.quit or dont
  vd._oldOrigin = love.graphics.origin

  vd._update = _update
  vd._draw = _draw
  
  
  love.update = function(dt)
    if not (vd.pauseType == "Stop" or vd.pauseType == "Freeze") then
      _update((vd.pauseType == "Zero" and 0 or dt * 2^vd.timeScale))
    end
    vd.update(dt)
  end

  love.draw = function()
    if vd.pauseType ~= "Freeze" then
      _draw()
    else
      if vd.frozenFrame then love.graphics.draw(vd.frozenFrame) end
    end

    if vd.capFrame then
      _draw()
      love.graphics.captureScreenshot(function (id) _vudu.frozenFrame = love.graphics.newImage(id) end)
      vd.capFrame = nil
    else
      vd.draw()
    end
  end

  love.mousepressed = function(...) if not (vd.pauseType == "Stop" or vd.pauseType == "Freeze") then _mousepressed(...) end; vd.mousepressed(...) end
  love.mousereleased = function(...) if not (vd.pauseType == "Stop" or vd.pauseType == "Freeze") then _mousereleased(...) end; vd.mousereleased(...) end
  love.keypressed = function(...) if not (vd.pauseType == "Stop" or vd.pauseType == "Freeze") then _keypressed(...) end; vd.keypressed(...) end
  love.keyreleased = function(...) if not (vd.pauseType == "Stop" or vd.pauseType == "Freeze") then _keyreleased(...) end; vd.keyreleased(...) end
  love.wheelmoved = function(...) if not (vd.pauseType == "Stop" or vd.pauseType == "Freeze") then _wheelmoved(...) end; vd.wheelmoved(...) end
  love.textinput = function(...) if not (vd.pauseType == "Stop" or vd.pauseType == "Freeze") then _textinput(...) end; vd.textinput(...) end
  love.resize = function(...) _resize(...); vd.resize(...) end
  oldprint = _print
  print = function(...) if not vd.print(...) then _print(...) end end
  love.window.setMode = function(w, h, ...) _setMode(w, h, ...); vd.resize(w, h) end
  love.quit = function(...) vd.quit(); _quit() end
  love.graphics.origin = function() vd._oldOrigin(); vd.origin() end
end

--Internal Callbacks and such
do
  function vd.update(dt)
    vd.timer = vd.timer + dt
    vd.gameTimer = vd.gameTimer + (vd.paused and 0 or dt*(2^vd.timeScale))
    vd.ui:update(dt)
    for i, win in ipairs(vd.windows) do win:update(dt) end
  end

  function vd.draw()
    vd._oldOrigin()
    for i, win in ipairs(vd.windows) do if win.runHidden or not vd.hidden then
      win:draw()
    end end
    if not vd.hidden then vd.ui:draw() end
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

  function vd.print(...)
    if (vd.console) then
      vd.console.addToHistory(..., true)
      oldprint(...)
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

  function vd.quit()
    exportStr = "return {"
    exportStr = exportStr .. "startHidden = " .. (vd.hidden and "true" or "false") .. ',\n'
    exportStr = exportStr .. "showFunctions = " .. (vd.showFunctions and "true" or "false") .. ',\n'
    exportStr = exportStr .. "showUnderscores = " .. (vd.showUnderscores and "true" or "false") .. ',\n'
    exportStr = exportStr .. "}"
    love.filesystem.write("vudusettings.lua", exportStr)
  end

  function vd.origin() 
    love.graphics.applyTransform(vd.camera.transform)
  end

end

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
      vd.browser.ignore[v] = state
    end
  else
    vd.browser.ignore[ig] = state
  end
end

function vd.setTheme(path)
  local theme = love.filesystem.load(path)()
  for i, v in pairs(theme.colors) do vdUtil.copyColor(theme.colors[i], vd.colors[i]) end
  for i, v in pairs(theme.colors_pre11) do vdUtil.copyColor(theme.colors_pre11[i], vd.colors_pre11[i]) end
end

--Adds top widget for watch windows
function vd._addTopWidget(self, title)
  local frame = vd.vuduUI.widget.frame.new(0, 0, self.w, 12, 6, {onResize = function(self) self.w = self.parent.w end})
  frame.idleColor = vd.colors.highlight
  self:addWidget(frame)
  local minimizer = vd.vuduUI.widget.new(0, 0, 12, 12, 6, {
    onRelease = function(self)
      self.target.parent:removeWidget(self.target)
    end
  })
  minimizer.target = self
  minimizer.savedH = 12

  local text = vd.vuduUI.widget.text.new(14, -2, self.w-14, 12, 6, title, {idleColor = {0,0,0,0}, unClickable = true, alignment = "right"})

  local dragger = vd.vuduUI.widget.new(0, 0, self.w, 12, 6, {
    onPress = function(self, x, y)
      self.px, self.py = love.mouse.getPosition()
      self.tx, self.ty = self.target.x, self.target.y
    end,
    whileHeld = function(self, x, y, dt)
      local mx, my = love.mouse.getPosition()
      self.target.x, self.target.y = self.tx + (mx-self.px), self.ty + (my-self.py)
    end,
    idleColor = {0,0,0,0},
    hoverColor = {0,0,0,0},
    pressColor = {0,0,0,0},
  })
  dragger.target = self

  frame:addWidget(minimizer)
  frame:addWidget(dragger)
  frame:addWidget(text)
end

function vd.addWatchWindow(refstr, x, y)
  x, y = x or 300 + math.random(-50, 50), y or 300 + math.random(-50, 50)
  local typ = type(vudu.getByName(refstr))
  local gw, gh = 96, typ == 'number' and 72 or 30
  local panel = vd.vuduUI.widget.frame.new(x, y, gw, gh, 6, {idleColor = vd.colors.window})
  vd.ui:addWidgetFront(panel)

  if typ == 'number' then
    panel:addWidget(vd.vuduUI.widget.vuduGraph.new(2, 14, gw-4, gh-32, 6, refstr))
  end
  panel:addWidget(vd.vuduUI.widget.vuduField.new(2, gh-16, gw-4, 14, 6, refstr, {autoEval = true, fixedSize = true, idleColor = vudu.colors.lowLight}))
  vudu._addTopWidget(panel, refstr)
end

function vd.setCamera(x, y, z, r)
  vd.camera.x = x or vd.camera.x 
  vd.camera.y = y or vd.camera.y 
  vd.camera.z = z or vd.camera.z
  vd.camera.r = r or vd.camera.r 
  vd._refreshCameraTransform()
end

function vd._refreshCameraTransform()
  local baseTransform = love.math.newTransform(-vd.camera.x / vd.camera.z, -vd.camera.y / vd.camera.z, 0, 1/vd.camera.z)
  local rotateCenter = love.math.newTransform(0, 0, vd.camera.r)
  local addCenter = love.math.newTransform(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
  --local subCenter = love.math.newTransform(-love.graphics.getWidth()/2, -love.graphics.getHeight()/2)
  addCenter:apply(rotateCenter)
  addCenter:apply(baseTransform)
  --addCenter:apply(subCenter)
  vd.camera.transform = addCenter
end

function vd.advanceSingleFrame(dt)
  vd._update(love.timer.getDelta() * 2^vd.timeScale)
  vd._draw()
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