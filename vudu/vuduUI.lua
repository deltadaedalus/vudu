local vdUtil = require(_vdpath .. "vuduUtil")
local vd = require(_vdpath .. "vudu")

local vdui = {
  releaseFade = 0.5,
  pressFade = 0.1
}
vdui.__index = vdui

function vdui.new(window)
  local self = setmetatable({}, vdui)
  self.heldWidget = nil
  
  self.widgets = {}
  self.all = {}
  self.textTarget = nil
  self.window = window
  
  return self
end

function vdui:update(dt)
  
  if self.heldWidget then
    local cx, cy = self.heldWidget:getRealPosition();
    local mx, my = love.mouse.getPosition();
    self.heldWidget:whileHeld(mx - cx - self.window.x, my - cy - self.window.y, dt)
  end
  for i, w in ipairs(self.widgets) do
    w:update(dt)
  end
end

function vdui:draw()
  for i, v in ipairs(self.widgets) do
    v:draw()
  end
end

function vdui:mousepressed(x, y, button, isTouch)
  for i, w in ipairs(self.widgets) do
    if w:checkContains(x, y) then
      w:changeColor(w.pressColor, vdui.pressFade)
      self.heldWidget = w
      break;
    end
  end
  
  if self.heldWidget ~= nil then
    self.heldWidget:onPress(x - self.heldWidget.x, y - self.heldWidget.y)
  end
end

function vdui:mousereleased(x, y, button, isTouch)
  if self.heldWidget then
    self.heldWidget:changeColor(self.heldWidget.idleColor, vdui.releaseFade)
    self.heldWidget:onRelease(x, y, button, isTouch)
    self.heldWidget = nil
  else
    for i, w in ipairs(self.widgets) do
      if w:checkContains(x, y) then
        w:onRelease(x, y, button, isTouch)
        break;
      end

    end
  end

end

function vdui:keypressed(key, scancode, isrepeat)
  if self.textTarget ~= nil and self.textTarget.keypressed then
    self.textTarget:keypressed(key, scancode, isrepeat)
  end
end

function vdui:keyreleased(key, scancode, isrepeat)
  if self.textTarget ~= nil and self.textTarget.keyreleased then
    self.textTarget:keyreleased(key, scancode, isrepeat)
  end
end

function vdui:wheelmoved(x, y)
  local mx, my = love.mouse.getPosition()
  mx = mx - self.window.x
  my = my - self.window.y
  for i, w in ipairs(self.widgets) do
    if w:checkContains(mx, my) then w:wheelmoved(x, y) end
  end
end

function vdui:textinput(text)
  if self.textTarget ~= nil then
    self.textTarget:textinput(text)
  end
end

function vdui:addWidget(w)
  table.insert(self.widgets, w)
  w.ui = self
end

function vdui:removeWidget(w)
  for i, v in ipairs(self.all) do
    if v == w then
      table.remove(self.all, i)
      break;
    end
  end
  w.ui = nil
end





local vdwg = {
  idleColor_pre11 = {192, 192, 192},
  hoverColor_pre11 = {200, 200, 200},
  pressColor_pre11 = {192, 192, 224},
  idleColor = {3/4, 3/4, 3/4},
  hoverColor = {25/32, 25/32, 25/32},
  pressColor = {3/4, 3/4, 7/8},
}
vdwg.__index = vdwg

vdui.widget = vdwg

function vdwg.new(x, y, w, h, r, settings)
  settings = settings or {}
  local self = setmetatable({}, vdwg)
  self.widgets = {}

  self.x = x
  self.y = y
  self.w = w or 32
  self.h = h or 32
  self.r = r or 6
  
  self.onPress = settings.onPress
  self.onRelease = settings.onRelease
  self.whileHeld = settings.whileHeld
  self.draw = settings.draw
  self.idleColor = settings.idleColor
  self.hoverColor = settings.hoverColor
  self.pressColor = settings.pressColor
  self.image = settings.image
  
  self.isHovered = false
  self.colorStartTime = 0
  self.colorEndTime = 1
  self.startColor = self.idleColor
  self.endColor = self.idleColor
  
  return self
end

function vdwg:onPress(x, y, button, isTouch) end
function vdwg:whileHeld(x, y, dt) end
function vdwg:onRelease(x, y, button, isTouch) end
function vdwg:update(dt) end
function vdwg:wheelmoved(x, y) end

function vdwg:changeColor(targetColor, dt)
  dt = dt or 0
  self.startColor = self:getColor()
  self.colorStartTime = vd.timer
  self.colorEndTime = vd.timer + dt
  self.endColor = targetColor
end

function vdwg:getColor()
  local diff = math.min((vd.timer - self.colorStartTime) / (self.colorEndTime - self.colorStartTime), 1)
  local color = vdUtil.lerpColor(diff, self.startColor, self.endColor)
  return color
end

function vdwg:draw()
  love.graphics.setColor(self:getColor())
  if (self.image) then love.graphics.draw(self.image, self.x, self.y)
  else vdUtil.roundRect("fill", self.x, self.y, self.w, self.h, self.r)
  end
end

function vdwg:checkContains(x, y)
  return vdUtil.roundRectContains(x, y, self.x, self.y, self.w, self.h, self.r)
end

function vdwg:getRealPosition()
  local cur = self
  local cx, cy = 0,0
  repeat
    cx, cy = cx + cur.x, cy + cur.y
    cur = cur.parent
  until cur == nil
  return cx, cy
end














--
--
--vudu frame widget
--A frame is like a sub-UI
--It passes callbacks down into its child widgets
--
--
vdwg.frame = setmetatable({}, vdwg)
vdwg.frame.__index = vdwg.frame

function vdwg.frame.new(x, y, w, h, r)
  local self = setmetatable(vdwg.new(x, y, w, h, r), vdwg.frame)
  self.heldWidget = nil
  self.tox, self.toy = 0,0
  self.ox, self.oy = 0,0
  
  return self
end

function vdwg.frame:onPress(x, y)
  for i, w in ipairs(self.widgets) do
    if w:checkContains(x - self.ox, y - self.oy) then
      w:changeColor(w.pressColor, vdui.pressFade)
      self.heldWidget = w
      break;
    end
  end
  
  if self.heldWidget ~= nil then
    self.heldWidget:onPress(x - self.ox - self.heldWidget.x, y - self.oy - self.heldWidget.y)
  end
end

function vdwg.frame:whileHeld(...)
  if self.heldWidget then self.heldWidget:whileHeld(...) end
end

function vdwg.frame:onRelease(x, y)
  if self.heldWidget ~= nil then
    self.heldWidget:changeColor(self.heldWidget.idleColor, vdui.releaseFade)
    self.heldWidget:onRelease(x - self.ox - self.heldWidget.x, y - self.oy - self.heldWidget.y)
    self.heldWidget = nil
  end
end

function vdwg.frame:update(dt)
  self.ox = (self.tox + self.ox * 9) / 10
  self.oy = (self.toy + self.oy * 9) / 10
  
  for i, w in ipairs(self.widgets) do
    w:update(dt)
  end
end

function vdwg.frame:draw()
  love.graphics.stencil(function() vdUtil.roundRect('fill', self.x, self.y, self.w, self.h, self.r) end, "replace", 1, false)
  love.graphics.setStencilTest('equal', 1)
  love.graphics.setColor(self.idleColor)
  vdUtil.roundRect('fill', self.x, self.y, self.w, self.h, self.r)
  
  love.graphics.push()
  love.graphics.translate(self.x + self.ox, self.y + self.oy)
  for i, w in ipairs(self.widgets) do
    love.graphics.setColor(1, 1, 1)
    w:draw()
  end
  love.graphics.pop()
  
  love.graphics.setStencilTest()
end

function vdwg.frame:addWidget(w)
  if w.ui ~= nil and w.ui ~= self.ui then
    error("Trying to add widget cross-ui")
  end
  table.insert(self.widgets, w)
  table.insert(self.ui.all, w)
  w.ui = self.ui
  w.parent = self
end

function vdwg.frame:removeWidget(w)
  if w.parent ~= self then return end
  for i, v in ipairs(self.widgets) do
    if v == w then table.remove(self.widgets, i); break end
  end
  w.parent = nil
end

function vdwg.frame:wheelmoved(x, y)
  self.tox, self.toy = self.tox + x*20, self.toy + y*20
end




--
--That's all folks
--

return vdui