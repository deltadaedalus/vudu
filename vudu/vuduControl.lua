local vd = require(_vdreq .. "vudu")
local vdwin = require(_vdreq .. "vuduWindow")
local vdui = require(_vdreq .. "vuduUI")

vd.control = vdwin.new({
  pauseButtons = {},
}, {
  x = 502, 
  y = 450, 
  w = 296, 
  h = 148,
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
    update = function(self, dt) self.text = tostring(math.floor(vudu.timer/60)) .. ':' ..  tostring(math.floor(vudu.timer%60)) end,
    idleColor = vd.colors.midhighlight,
    onResize = valueResize
  })
  local timeLabel = vdui.widget.text.new(180, 86, 64, 16, 6, 'Elapsed', {alignment = 'right', idleColor = {0,0,0,0}, textColor = vd.colors.label, onResize = labelResize, unClickable = true})


  --pause mode buttons
  local playButton = vdui.widget.new(2, 46, 48, 48, 12,
    {onRelease = function() vd.control.setPauseType("Play", 1) end,
    image = love.graphics.newImage(vd.path .. "Images/Play.png")})

  local zeroButton = vdui.widget.new(52, 46, 48, 48, 12,
    {onRelease = function() vd.control.setPauseType("Zero", 2) end,
    image = love.graphics.newImage(vd.path .. "Images/Pause.png")})
  
  local stopButton = vdui.widget.new(102, 46, 48, 48, 12,
    {onRelease = function() vd.control.setPauseType("Stop", 3) end,
    image = love.graphics.newImage(vd.path .. "Images/Stop.png")})

  local freezeButton = vdui.widget.new(2, 96, 48, 48, 12,
    {onRelease = function() vd.control.setPauseType("Freeze", 4) end,
    image = love.graphics.newImage(vd.path .. "Images/Freeze.png")})
  
  vd.control.pauseButtons = {playButton, zeroButton, stopButton, freezeButton}

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