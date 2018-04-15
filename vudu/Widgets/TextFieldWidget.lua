local vd = require "vudu"
local vdui = require "vuduUI"
local vdw = vdui.widget

require "Widgets/TextWidget"

vdw.textField = setmetatable({}, vdw.text)
vdw.textField.__index = vdw.textField

function vdw.textField.new(x, y, w, h, r, text, settings)
  local self = setmetatable(vdw.text.new(x, y, w, h, r, text, settings), vdw.textField)
  self.onSelected = settings.onSelected
  self.onEntered = settings.onEntered
  self.cursor = 0
  return self
end

function vdw.textField:onSelected() end
function vdw.textField:onEntered() end

function vdw.textField:draw()
  vdw.draw(self)
  vdw.text.draw(self)
  if self.ui.textTarget == self then
    local cx = vd.font:getWrap(string.sub(self.text, 0, self.cursor), 1000)
    love.graphics.setLineWidth(2)
    love.graphics.line(self.x+self.r+cx, self.y+1, self.x+self.r+cx, self.y+15)
  end
end

function vdw.textField:onRelease()
  self:onSelected()
  self.ui.textTarget = self
end

function vdw.textField:textinput(text)
  self.text = string.sub(self.text, 1, self.cursor) .. text .. string.sub(self.text, self.cursor+1, -1)
  self.cursor = self.cursor + #text
end

function vdw.textField:keypressed(key, scancode, isrepeat)
  if key == 'return' then
    self:onEntered()
  elseif key == 'left' then
    self.cursor = math.max(0, self.cursor-1)
  elseif key == 'right' then
    self.cursor = math.min(#self.text, self.cursor+1)
  elseif key == 'v' and (love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')) then
    local clip = love.system.getClipboardText()
    self:textInput(clip)
  elseif key == 'backspace' and self.cursor ~= 0 then
    self.text = string.sub(self.text, 1, self.cursor-1) .. string.sub(self.text, self.cursor+1, -1)
    self.cursor = math.max(0, self.cursor-1)
  elseif key == 'delete' then
    self.text = string.sub(self.text, 1, self.cursor) .. string.sub(self.text, self.cursor+2, -1)
  elseif key == 'end' then
    self.cursor = #self.text
  elseif key == 'home' then
    self.cursor = 0
  elseif key == 'escape' then
    self.ui.textTarget = nil
  end
end

function vdw.textField:keyreleased(key, scancode, isrepeat)
  
end