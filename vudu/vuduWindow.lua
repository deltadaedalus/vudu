local vd = require(_vdpath .. "vudu")
local vdUtil = require(_vdpath .. "vuduUtil")
local vdui = require(_vdpath .. "vuduUI")

local vdwin = {}
vdwin.__index = vdwin

function vdwin.new(t, settings)
  settings = settings or {}
  
  local self = setmetatable(t, vdwin)
  self.x = settings.x or 0
  self.y = settings.y or 0
  self.w = settings.w or 20
  self.h = settings.h or 20
  self.hasFrame = settings.hasFrame
  self.runHidden = settings.runHidden
  
  if (self.hasFrame) then
    self.frame = vdui.widget.frame.new(self.x, self.y, self.w, self.h, 6)
    self.frame.idleColor = vd.colors.window
  end
  
  return self
end

function vdwin:addTopWidget()
  local frame = vdui.widget.frame.new(0, 0, self.w, 12, 6, {onResize = function(self) self.w = self.parent.w end})
  frame.idleColor = vd.colors.highlight
  self.frame:addWidget(frame)
  local minimizer = vdui.widget.new(0, 0, 12, 12, 6, {onRelease = function(self) self.target.h, self.savedH = self.savedH, self.target.h end})
  minimizer.target = self
  minimizer.savedH = 12
  frame:addWidget(minimizer)
end

function vdwin:setCallback(index, func)
  self[index] = func
end

function vdwin:load() end
function vdwin:update(dt) end
function vdwin:draw() end
function vdwin:mousepressed(x, y, button, isTouch) end
function vdwin:mousereleased(x, y, button, isTouch) end
function vdwin:keypressed(key, scancode, isrepeat) end
function vdwin:keyreleased(key, scancode, isrepeat) end
function vdwin:wheelmoved(x, y)  end
function vdwin:textinput(text) end


return vdwin