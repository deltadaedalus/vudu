local vd = require(_vdreq .. "vudu")
local vdwin = require(_vdreq .. "vuduwindow")
local vdui = require(_vdreq .. "vuduui")

vd.control = vdwin.new({
  pauseButtons = {},
}, {
  x = 502, 
  y = 450, 
  w = 296, 
  h = 148,
  minimizeType = 'bottom',
  hasFrame = true
})


function vd.control:load()
  vd.control:addTopWidget()

  --dt slider
  vd.control.timeSlider = vdui.widget.slider.new(10, 22, 276, 0, 8, {
    targetRef = "_vudu.timeScale",
    min = -3,
    max = 3,
    targetValue = 0,
    residual = 0.002,
    idleColor = vd.colors.buttonPress,
    pressColor = vd.colors.buttonIdle,
    onResize = function(self) self:insetR(10); self:updatePosition() end,
  })

  local resetDTbutton = vdui.widget.new(142, 32, 12, 12, 6, {
    onRelease = function() _vudu.control.timeSlider:gotoValue(0) end,
    onResize = function(self) self:centerX() end
  })
  
  --dt texty bits
  local labelResize = function(self) self:setX(-116) end
  local valueResize = function(self) self:setX(-56) end

  local multText = vdui.widget.text.new(240, 32, 40, 16, 6, 'ye', {
    update = function(self, dt) self.text = string.sub(tostring(2^vd.timeScale), 0, 4) end,
    idleColor = vd.colors.midhighlight,
    onResize = valueResize
  })
  local multLabel = vdui.widget.text.new(180, 32, 64, 16, 6, 'Speed', {alignment = 'right', idleColor = {0,0,0,0}, textColor = vd.colors.label, onResize = labelResize, unClickable = true})

  local deltaText = vdui.widget.text.new(240, 50, 54, 16, 6, 'ye', {
    update = function(self, dt) self.text = string.sub(tostring(love.timer.getDelta()), 0, 6) end,
    idleColor = vd.colors.midhighlight,
    onResize = valueResize
  })
  local deltaLabel = vdui.widget.text.new(180, 50, 64, 16, 6, 'Delta', {alignment = 'right', idleColor = {0,0,0,0}, textColor = vd.colors.label, onResize = labelResize, unClickable = true})

  local fpsText = vdui.widget.text.new(240, 68, 40, 16, 6, 'ye', {
    update = function(self, dt) self.text = string.sub(tostring(love.timer.getFPS()), 0, 4) end,
    idleColor = vd.colors.midhighlight,
    onResize = valueResize
  })
  local fpsLabel = vdui.widget.text.new(180, 68, 64, 16, 6, 'FPS', {alignment = 'right', idleColor = {0,0,0,0}, textColor = vd.colors.label, onResize = labelResize, unClickable = true})

  local timeText = vdui.widget.text.new(240, 86, 54, 16, 6, 'ye', {
    update = function(self, dt) self.text = tostring(math.floor(vd.timer/60)) .. ':' ..  tostring(math.floor(vd.timer%60)) end,
    idleColor = vd.colors.midhighlight,
    onResize = valueResize
  })
  local timeLabel = vdui.widget.text.new(180, 86, 64, 16, 6, 'Elapsed', {alignment = 'right', idleColor = {0,0,0,0}, textColor = vd.colors.label, onResize = labelResize, unClickable = true})


  --pause mode buttons
  local playButton = vdui.widget.new(2, 46, 48, 48, 12,
    {onRelease = function() vd.control.setPauseType("Play", 1) end,
    image = love.graphics.newImage(vd.path .. "images/play.png")})

  local zeroButton = vdui.widget.new(52, 46, 48, 48, 12,
    {onRelease = function() vd.control.setPauseType("Zero", 2) end,
    image = love.graphics.newImage(vd.path .. "images/pause.png")})
  
  local stopButton = vdui.widget.new(102, 46, 48, 48, 12,
    {onRelease = function() vd.control.setPauseType("Stop", 3) end,
    image = love.graphics.newImage(vd.path .. "images/stop.png")})

  local freezeButton = vdui.widget.new(2, 96, 48, 48, 12,
    {onRelease = function() vd.control.setPauseType("Freeze", 4) end,
    image = love.graphics.newImage(vd.path .. "images/freeze.png")})

  local advanceButton = vdui.widget.new(102, 96, 48, 48, 12,
    {onRelease = function() vd.control.setPauseType("Stop", 5); vd.advanceSingleFrame() end,
    image = love.graphics.newImage(vd.path .. "images/frame.png")})
  
  vd.control.pauseButtons = {playButton, zeroButton, stopButton, freezeButton, advanceButton}

  --Camera Controls
  local cameraFrame = vdui.widget.frame.new(158, 104, 100, 40, 6, {
    idleColor = vd.colors.midhighlight,
  })
  local cameraSpeed = 1/16
  local zoomSpeed = 1/256

  local leftButton = vdui.widget.new(5, 10, 15, 20, 6, {
    whileHeld = function(self, dt) vd.camera.x = vd.camera.x - dt*cameraSpeed * vd.camera.z; vd._refreshCameraTransform() end,
    image = love.graphics.newImage(vd.path .. "images/leftarrow.png")
  })
  local rightButton = vdui.widget.new(40, 10, 15, 20, 6, {
    whileHeld = function(self, dt) vd.camera.x = vd.camera.x + dt*cameraSpeed * vd.camera.z; vd._refreshCameraTransform() end,
    image = love.graphics.newImage(vd.path .. "images/rightarrow.png")
  })
  local upButton = vdui.widget.new(20, 5, 20, 15, 6, {
    whileHeld = function(self, dt) vd.camera.y = vd.camera.y - dt*cameraSpeed * vd.camera.z; vd._refreshCameraTransform() end,
    image = love.graphics.newImage(vd.path .. "images/uparrow.png")
  })
  local downButton = vdui.widget.new(20, 20, 20, 15, 6, {
    whileHeld = function(self, dt) vd.camera.y = vd.camera.y + dt*cameraSpeed * vd.camera.z; vd._refreshCameraTransform() end,
    image = love.graphics.newImage(vd.path .. "images/downarrow.png")
  })
  local outButton = vdui.widget.new(55, 20, 20, 15, 6, {
    whileHeld = function(self, dt) vd.camera.z = vd.camera.z * dt^zoomSpeed; vd._refreshCameraTransform() end,
    image = love.graphics.newImage(vd.path .. "images/outarrow.png")
  })
  local inButton = vdui.widget.new(55, 5, 20, 15, 6, {
    whileHeld = function(self, dt) vd.camera.z = vd.camera.z / dt^zoomSpeed; vd._refreshCameraTransform() end,
    image = love.graphics.newImage(vd.path .. "images/inarrow.png")
  })
  local resetButton = vdui.widget.new(75, 10, 20, 20, 6, {
    onRelease = function(self) vd.camera.x = love.graphics.getWidth()/2; vd.camera.y = love.graphics.getHeight()/2; vd.camera.z = 1; vd._refreshCameraTransform() end,
    image = love.graphics.newImage(vd.path .. "images/resetarrow.png")
  })

  cameraFrame:addWidget(resetButton)
  cameraFrame:addWidget(outButton)
  cameraFrame:addWidget(inButton)
  cameraFrame:addWidget(rightButton)
  cameraFrame:addWidget(downButton)
  cameraFrame:addWidget(upButton)
  cameraFrame:addWidget(leftButton)


  --add widgets
  vd.control.frame:addWidget(vd.control.timeSlider)
  vd.control.frame:addWidget(resetDTbutton)

  vd.control.frame:addWidget(multLabel)
  vd.control.frame:addWidget(deltaLabel)
  vd.control.frame:addWidget(fpsLabel)
  vd.control.frame:addWidget(timeLabel)
  vd.control.frame:addWidget(multText)
  vd.control.frame:addWidget(deltaText)
  vd.control.frame:addWidget(fpsText)
  vd.control.frame:addWidget(timeText)

  vd.control.frame:addWidget(playButton)
  playButton:changeColor(playButton.pressColor, 0)
  vd.control.frame:addWidget(zeroButton)
  vd.control.frame:addWidget(stopButton)
  vd.control.frame:addWidget(freezeButton)
  vd.control.frame:addWidget(advanceButton)

  vd.control.frame:addWidget(cameraFrame)
end
  
function vd.control.setPauseType(pauseType, activeIndex)
  activeIndex = activeIndex or 1
  for i, v in ipairs(vd.control.pauseButtons) do
    v:changeColor(v.idleColor, .2)
  end
  vd.control.pauseButtons[activeIndex]:changeColor(vd.control.pauseButtons[activeIndex].pressColor, .2)
  vd.pauseType = pauseType
  vd.paused = pauseType ~= "Play"

  if (pauseType == "Freeze") then
    vd.capFrame = true
  end
end






return vd.control