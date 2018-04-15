local vd = require(_vdpath .. "vudu")
local vdwin = require(_vdpath .. "vuduWindow")
local vdui = require(_vdpath .. "vuduUI")

vd.control = {
  pauseButtons = {}
}

vdwin.setup(vd.control, 296, 148)
vd.control.x = 502
vd.control.y = 450

function vd.control:load()
  vd.control.timeSlider = vdui.widget.slider.new(10, 22, 276, 0, 8, 
    {targetRef = "_vudu.timeScale",
    min = -3,
    max = 3,
    targetValue = 0,
    residual = 0.002 })
  vd.control.ui:addWidget(vd.control.timeSlider)


  local playButton = vdui.widget.new(74, 46, 48, 48, 12,
    {onRelease = function() vd.control.setPauseType("Play", 1) end,
    image = love.graphics.newImage(vd.path .. "Images/Play.png")})

  local zeroButton = vdui.widget.new(124, 46, 48, 48, 12,
    {onRelease = function() vd.control.setPauseType("Zero", 2) end,
    image = love.graphics.newImage(vd.path .. "Images/Pause.png")})
  
  local stopButton = vdui.widget.new(174, 46, 48, 48, 12,
    {onRelease = function() vd.control.setPauseType("Stop", 3) end,
    image = love.graphics.newImage(vd.path .. "Images/Stop.png")})

  vd.control.ui:addWidget(playButton)
  playButton:changeColor(playButton.pressColor, 0)
  vd.control.ui:addWidget(zeroButton)
  vd.control.ui:addWidget(stopButton)

  vd.control.pauseButtons = {playButton, zeroButton, stopButton}

  local resetDTbutton = vdui.widget.new(142, 32, 12, 12, 6,
    {onRelease = function() _vudu.control.timeSlider:gotoValue(0) end})
  vd.control.ui:addWidget(resetDTbutton)
end
  
function vd.control.setPauseType(pauseType, activeIndex)
  for i, v in ipairs(vd.control.pauseButtons) do
    v:changeColor(v.idleColor, .2)
  end
  vd.control.pauseButtons[activeIndex]:changeColor(vd.control.pauseButtons[activeIndex].pressColor, .2)
  vd.pauseType = pauseType
  vd.paused = pauseType ~= "Play"
end






return vd.control