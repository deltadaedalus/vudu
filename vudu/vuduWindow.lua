local vdUtil = require "vuduUtil"
local vdui = require "vuduUI"

local vdwin = {
  windowColor_pre11 = {250, 250, 250},
  headerColor_pre11 = {128, 96, 192},
  windowColor = {250/256, 250/256, 250/256},
  headerColor = {1/2, 3/8, 3/4}
}
vdwin.__index = vdwin

function vdwin.new(w, h, settings)
  return vdwin.setup({}, w, h, settings)
end

function vdwin.setup(t, w, h, settings)
  settings = settings or {}
  
  local self = setmetatable(t, vdwin)
  self.x = 0
  self.y = 0
  self.w = w
  self.h = h
  
  self.load = settings.load
  self.update = settings.update
  self.draw = settings.draw
  
  self.ui = vdui.new(self)
  self:addTopWidget()
  self:load()
  
  return self
end

function vdwin:addTopWidget()
  local frame = vdui.widget.frame.new(0, 0, self.w, 12, 6)
  frame.idleColor = self.headerColor
  self.ui:addWidget(frame)
  local minimizer = vdui.widget.new(0, 0, 12, 12, 6, {onRelease = function(self) self.target.h, self.savedH = self.savedH, self.target.h end})
  minimizer.target = self
  minimizer.savedH = 12
  frame:addWidget(minimizer)
end

function vdwin:setCallback(index, func)
  self[index] = func
end

function vdwin:load() end
function vdwin:update(dt) self.ui:update(dt) end
function vdwin:draw() self.ui:draw() end
function vdwin:mousepressed(x, y, button, isTouch) self.ui:mousepressed(x, y, button, isTouch) end
function vdwin:mousereleased(x, y, button, isTouch) self.ui:mousereleased(x, y, button, isTouch) end
function vdwin:keypressed(key, scancode, isrepeat) self.ui:keypressed(key, scancode, isrepeat) end
function vdwin:keyreleased(x, y, button, isTouch) self.ui:keyreleased(key, scancode, isrepeat) end
function vdwin:wheelmoved(x, y) self.ui:wheelmoved(x, y) end
function vdwin:textinput(text) self.ui:textinput(text) end

function vdwin:gotFocus() end
function vdwin:lostFocus() end

function vdwin:startDraw()
  love.graphics.stencil(function() vdUtil.roundRect('fill', self.x, self.y, self.w, self.h, 6) end, "replace", 1, false)
  love.graphics.setStencilTest('equal', 1)
  love.graphics.setColor(self.windowColor)
  vdUtil.roundRect('fill', self.x, self.y, self.w, self.h, 6)
  love.graphics.push()
  love.graphics.translate(self.x, self.y)
end

function vdwin:endDraw()
  love.graphics.setStencilTest()
  love.graphics.pop()
end


return vdwin