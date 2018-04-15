local vd = require "vudu"
local vdwin = require "vuduWindow"
local vdui = require "vuduUI"

vd.control = {
  pauseButtons = {}
}

vdwin.setup(vd.control, 296, 148)
vd.control.x = 502
vd.control.y = 450

function vd.control:load()
  local timeSlider = vdui.widget.slider.new(10, 22, 276, 0, 8, 
    {targetRef = "_vudu.timeScale",
    min = 0,
    max = 2,
    targetValue = 1,
    residual = 0.01 })
  vd.control.ui:addWidget(timeSlider)


  local playButton = vdui.widget.new(10, 32, 48, 48, 12,
    {onRelease = function() vd.control.setPauseType("Play", 1) end,
    image = love.graphics.newImage("Images/Play.png")})

  local zeroButton = vdui.widget.new(60, 32, 48, 48, 12,
    {onRelease = function() vd.control.setPauseType("Zero", 2) end,
    image = love.graphics.newImage("Images/Pause.png")})
  
  local stopButton = vdui.widget.new(110, 32, 48, 48, 12,
    {onRelease = function() vd.control.setPauseType("Stop", 3) end,
    image = love.graphics.newImage("Images/Stop.png")})

  vd.control.ui:addWidget(playButton)
  playButton:changeColor(playButton.pressColor, 0)
  vd.control.ui:addWidget(zeroButton)
  vd.control.ui:addWidget(stopButton)

  vd.control.pauseButtons = {playButton, zeroButton, stopButton}
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