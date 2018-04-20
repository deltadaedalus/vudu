local vdUtil = require(_vdpath .. "vuduUtil")
local vdui = require(_vdpath .. "vuduUI")

local vdwin = {
  windowColor_pre11 = {250, 250, 250},
  headerColor_pre11 = {128, 96, 192},
  windowColor = {250/256, 250/256, 250/256},
  headerColor = {1/2, 3/8, 3/4}
}
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
    self.frame.idleColor = vdwin.windowColor
  end
  
  return self
end

function vdwin:addTopWidget()
  local frame = vdui.widget.frame.new(0, 0, self.w, 12, 6, {onResize = function(self) self.w = self.parent.w end})
  frame.idleColor = self.headerColor
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

function vdwin:startDraw()
  love.graphics.stencil(function() love.graphics.rectangle('fill', self.x, self.y, self.w, self.h, 6) end, "replace", 1, false)
  love.graphics.setStencilTest('equal', 1)
  love.graphics.setColor(self.windowColor)
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h, 6)
  love.graphics.push()
  love.graphics.translate(self.x, self.y)
end

function vdwin:endDraw()
  love.graphics.setStencilTest()
  love.graphics.pop()
end


return vdwin