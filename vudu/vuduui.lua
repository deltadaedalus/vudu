local vdUtil = require(_vdreq .. "vuduutil")

local vdui = {
  releaseFade = 0.2,
  pressFade = 0.05,
  hoverFade = 0.1
}
vdui.__index = vdui

function vdui.new()
  local self = setmetatable({}, vdui)
  self.heldWidget = nil
  self.hoverWidget = nil
  
  self.widgets = {}
  self.all = {}
  self.textTarget = nil
  self.x = 0
  self.y = 0
  self.w = love.graphics.getWidth()
  self.h = love.graphics.getHeight()
  
  return self
end

function vdui:update(dt)
  local mx, my = love.mouse.getPosition()

  if self.hoverWidget and not self.hoverWidget:checkContains(mx, my) then
    self.hoverWidget:changeColor(self.hoverWidget.idleColor, vdui.hoverFade)
    self.hoverWidget:onUnHover()
    self.hoverWidget = nil
  end

  for i, w in ipairs(self.widgets) do
    if (not w.unClickable) and self.hoverWidget ~= w and self.heldWidget ~= w and w:checkContains(mx, my) then
      if self.hoverWidget then
        self.hoverWidget:changeColor(self.hoverWidget.idleColor, vdui.hoverFade)
        self.hoverWidget:onUnHover()
      end
      w:changeColor(w.hoverColor, vdui.hoverFade)
      w:onHover()
      self.hoverWidget = w
      break;
    end
  end

  if self.hoverWidget then self.hoverWidget:whileHovered(mx - self.hoverWidget.x, my - self.hoverWidget.y, dt) end
  
  if self.heldWidget then
    local cx, cy = self.heldWidget:getRealPosition();
    local mx, my = love.mouse.getPosition();
    self.heldWidget:whileHeld(mx - cx, my - cy, dt)
  end
  for i, w in ipairs(self.widgets) do
    w:update(dt)
  end
end

function vdui:draw()
  for i = #self.widgets, 1, -1 do
    self.widgets[i]:draw()
  end
end

function vdui:mousepressed(x, y, button, isTouch)
  for i, w in ipairs(self.widgets) do
    if (not w.unClickable) and w:checkContains(x, y) then
      w:changeColor(w.pressColor, vdui.pressFade)
      self.heldWidget = w
      break;
    end
  end

  if self.heldWidget ~= self.textTarget then self.textTarget = nil end
  
  if self.heldWidget ~= nil then
    self.heldWidget:onPress(x - self.heldWidget.x, y - self.heldWidget.y)
  end
end

function vdui:mousereleased(x, y, button, isTouch)
  if self.heldWidget then
    self.heldWidget:onRelease(x - self.heldWidget.x, y - self.heldWidget.y, button, isTouch)
    self.heldWidget:changeColor(self.heldWidget:checkContains(x, y) and self.heldWidget.hoverColor or self.heldWidget.idleColor, vdui.releaseFade)
    self.heldWidget = nil
  else
    for i, w in ipairs(self.widgets) do
      if (not w.unClickable) and w:checkContains(x, y) then
        w:onRelease(x - w.x, y - w.y, button, isTouch)
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
  table.insert(self.all, w)
  w.ui = self
  w.parent = self
end

function vdui:addWidgetFront(w)
  table.insert(self.widgets, 1, w)
  table.insert(self.all, w)
  w.ui = self
  w.parent = self
end

function vdui:removeWidget(w)
  for i, v in ipairs(self.all) do
    if v == w then
      table.remove(self.all, i)
      break;
    end
  end
  
  for i, v in ipairs(w.parent.widgets) do
    if v == w then
      table.remove(w.parent.widgets, i)
      break;
    end
  end

  w.ui = nil
end

function vdui:resize(w, h)
  self.bounds = {x = 0, y = 0, w = love.graphics.getWidth(), h = love.graphics.getHeight()}
  for i, w in ipairs(self.widgets) do
    if w.onResize then w:onResize() end
    w:propagateResize()
  end
end





local vdwg = {
  idleColor = _vudu.colors.buttonIdle,
  hoverColor = _vudu.colors.buttonHover,
  pressColor = _vudu.colors.buttonPress
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
  
  self.update = settings.update
  self.onPress = settings.onPress
  self.onRelease = settings.onRelease
  self.whileHeld = settings.whileHeld
  self.onResize = settings.onResize
  self.draw = settings.draw
  self.idleColor = settings.idleColor
  self.hoverColor = settings.hoverColor
  self.pressColor = settings.pressColor
  self.image = settings.image
  self.unClickable = settings.unClickable
  
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
function vdwg:onResize() return true end
function vdwg:onHover() end
function vdwg:whileHovered(x, y, dt) end
function vdwg:onUnHover() end

function vdwg:changeColor(targetColor, dt)
  dt = dt or 0
  self.startColor = self:getColor()
  self.colorStartTime = _vudu.timer
  self.colorEndTime = _vudu.timer + dt
  self.endColor = targetColor
end

function vdwg:getColor()
  local diff = math.min((_vudu.timer - self.colorStartTime) / (self.colorEndTime - self.colorStartTime), 1)
  local color = vdUtil.lerpColor(diff, self.startColor, self.endColor)
  return color
end

function vdwg:draw()
  local color = self:getColor()
  if (self.image) then
    love.graphics.setColor(love._version_major >= 11 and {0, 0, 0, color[4] == 0 and 0 or 1/16} or {0, 0, 0, color[4] == 0 and 0 or 16})
    love.graphics.rectangle("fill", self.x-1, self.y+2, self.w, self.h, self.r)
    love.graphics.setColor(color)
    love.graphics.draw(self.image, self.x, self.y)
  else 
    love.graphics.setColor(love._version_major >= 11 and {0, 0, 0, color[4] == 0 and 0 or 1/16} or {0, 0, 0, color[4] == 0 and 0 or 16})
    love.graphics.rectangle("fill", self.x-1, self.y+2, self.w, self.h, self.r)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.r)
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

function vdwg:propagateResize()
  for i, w in ipairs(self.widgets) do
    if w.onResize then w:onResize() end
    w:propagateResize()
  end
end

--Position mutators
--edge_ sets the position of the _ edge while keeping the position of the opposite edge constant
function vdwg:edgeL(v) self.w, self.x = math.max(self.x+self.w-v, self.r*2), v end
function vdwg:edgeR(v) self.w = math.max(v-self.x, self.r*2); self.x = v-self.w end
function vdwg:edgeT(v) self.h, self.y = math.max(self.y+self.h-v, self.r*2), v end
function vdwg:edgeB(v) self.h = math.max(v-self.y, self.r*2); self.y = v-self.h end
--move_ moves the object such that the _ edge is at the given value while keeping size constant
function vdwg:moveL(v) self.x = v end
function vdwg:moveR(v) self.x = v - self.w end
function vdwg:moveT(v) self.y = v end
function vdwg:moveB(v) self.y = v - self.h end
function vdwg:moveCX(v) self.x = v - self.w/2-2 end
function vdwg:moveCY(v) self.y = v - self.h/2-2 end
--set_ simply sets the _ parameter, % the size of the window, so negative numbers wrap
function vdwg:setX(v) self.x = v % self.parent.w end
function vdwg:setY(v) self.y = v % self.parent.w end
function vdwg:setW(v) self.w = v end
function vdwg:setH(v) self.h = v end

--Fancier mutators
--inset_ insets the _ edge[s] from the _ side of the parent widget
function vdwg:inset(b) self:insetX(b); self:insetY(b) end
function vdwg:insetX(b) self.x = b; self.w = self.parent.w-b-b end
function vdwg:insetY(b) self.y = b; self.h = self.parent.h-b-b end
function vdwg:insetL(b) self:edgeL(b) end
function vdwg:insetR(b) self:edgeR(self.parent.w-b) end
function vdwg:insetT(b) self:edgeT(b) end
function vdwg:insetB(b) self:edgeB(self.parent.h-b) end
--grav_ moves the _ edge to b distance from the parent's edge
function vdwg:gravL(b) self.x = self.parent.x + b end
function vdwg:gravR(b) self.x = self.parent.w-self.w-b end
function vdwg:gravT(b) self.y = self.parent.y + b end
function vdwg:gravB(b) self.y = self.parent.h-self.h-b end
--center_ centers on the _ axis without changing size
function vdwg:centerX(w) self:moveCX((w or self.parent):getCX()) end
function vdwg:centerY(w) self:moveCY((w or self.parent):getCY()) end

--Position getters
function vdwg:getL() return self.x end
function vdwg:getR() return self.x + self.w end
function vdwg:getT() return self.y end
function vdwg:getB() return self.y + self.h end
function vdwg:getCX() return self.x + self.w/2 end
function vdwg:setCY() return self.y + self.h/2 end













--
--
--vudu frame widget
--A frame is like a sub-UI
--It passes callbacks down into its child widgets
--
--
vdwg.frame = setmetatable({
  isFrame = true
}, vdwg)
vdwg.frame.__index = vdwg.frame

function vdwg.frame.new(x, y, w, h, r, settings)
  settings = settings or {}
  local self = setmetatable(vdwg.new(x, y, w, h, r, settings), vdwg.frame)
  self.heldWidget = nil
  self.tox, self.toy = 0,0
  self.ox, self.oy = 0,0
  self.scrollable = settings.scrollable
  self.shufflable = settings.shufflable
  
  return self
end

function vdwg.frame:onPress(x, y)
  for i, w in ipairs(self.widgets) do
    if (not w.unClickable) and w:checkContains(x - self.ox, y - self.oy) then
      self.heldWidget = w
      break;
    end
  end
  
  if self.heldWidget ~= nil then
    self.heldWidget:onPress(x - self.ox - self.heldWidget.x, y - self.oy - self.heldWidget.y)
    self.heldWidget:changeColor(self.heldWidget.pressColor, vdui.pressFade)
  end
end

function vdwg.frame:whileHeld(...)
  if self.heldWidget then self.heldWidget:whileHeld(...) end
end

function vdwg.frame:onRelease(x, y)
  if self.heldWidget ~= nil then
    self.heldWidget:onRelease(x - self.ox - self.heldWidget.x, y - self.oy - self.heldWidget.y)
    if (self.heldWidget:checkContains(x-self.ox, y-self.oy)) then
      self.heldWidget:changeColor(self.heldWidget.hoverColor, vdui.hoverFade)
    else
      self.heldWidget:changeColor(self.heldWidget.idleColor, vdui.releaseFade)
    end
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
  love.graphics.setColor(love._version_major >= 11 and {0, 0, 0, self.idleColor[4] == 0 and 0 or 1/16} or {0, 0, 0, self.idleColor[4] == 0 and 0 or 16})
  love.graphics.rectangle("fill", self.x-1, self.y+2, self.w, self.h, self.r)
  love.graphics.setColor(self.idleColor)
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h, self.r)
  
  love.graphics.stencil(function() love.graphics.rectangle('fill', self.x, self.y, self.w, self.h, self.r) end, "increment", 1, true)
  local depth = self:getFrameDepth()
  love.graphics.push()
  love.graphics.translate(self.x + self.ox, self.y + self.oy)
  for i = #self.widgets, 1, -1 do
    love.graphics.setStencilTest('greater', depth-1)
    love.graphics.setColor(255, 255, 255)
    self.widgets[i]:draw()
  end
  love.graphics.pop()
  
  love.graphics.stencil(function() love.graphics.rectangle('fill', self.x, self.y, self.w, self.h, self.r) end, "decrement", 1, true)
  love.graphics.setStencilTest()
end

function vdwg.frame:getFrameDepth()
  local count = 1
  local cur = self.parent
  while cur do
    if cur.isFrame then count = count + 1 end
    cur = cur.parent
  end
  return count
end

function vdwg.frame:addWidget(w, front)
  if w.ui ~= nil and w.ui ~= self.ui then
    error("Trying to add widget cross-ui")
  end
  if front then table.insert(self.widgets, 1, w) else table.insert(self.widgets, w) end
  if self.ui then table.insert(self.ui.all, w) end
  w.ui = self.ui
  w.parent = self
end

function vdwg.frame:addWidgetFront(w)
  self:addWidget(w, true)
end

function vdwg.frame:removeWidget(w)
  if w.parent ~= self then return end
  for i, v in ipairs(self.widgets) do
    if v == w then table.remove(self.widgets, i); break end
  end
  w.parent = nil
end

function vdwg.frame:wheelmoved(x, y)
  if self.scrollable then self.toy = self.toy + y*20 end
  if self.shufflable then self.tox = self.tox + x*20 end
  for i, w in ipairs(self.widgets) do --Todo: contain check
    w:wheelmoved(self.shufflable and 0 or x, self.scrollable and 0 or y)
  end
end

function vdwg.frame:onHover() end
function vdwg.frame:whileHovered(x, y, dt)
  if self.hoverWidget and not self.hoverWidget:checkContains(x-self.ox, y-self.oy) then
    self.hoverWidget:changeColor(self.hoverWidget.idleColor, vdui.hoverFade)
    self.hoverWidget:onUnHover()
    self.hoverWidget.isHovered = false
    self.hoverWidget = nil
  end

  for i, w in ipairs(self.widgets) do
    if (not w.unClickable) and self.hoverWidget ~= w and self.heldWidget ~= w and w:checkContains(x - self.ox, y - self.oy) then
      if self.hoverWidget then
        self.hoverWidget:changeColor(self.hoverWidget.idleColor, vdui.hoverFade)
        self.hoverWidget:onUnHover()
        self.hoverWidget.isHovered = false
      end
      w:changeColor(w.hoverColor, vdui.hoverFade)
      w:onHover()
      w.isHovered = true
      self.hoverWidget = w
      break;
    end
  end

  if self.hoverWidget then self.hoverWidget:whileHovered(x - self.ox - self.hoverWidget.x, y - self.oy - self.hoverWidget.y, dt) end
end

function vdwg.frame:onUnHover()
  if self.hoverWidget then
    self.hoverWidget:onUnHover()
    self.hoverWidget.isHovered = false
    self.hoverWidget = nil
  end
end

return vdui