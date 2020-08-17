local vd = require(_vdreq .. "vudu")
local vdui = require(_vdreq .. "vuduui")
local vdw = vdui.widget

vdw.text = setmetatable({}, vdw)
vdw.text.__index = vdw.text
vdw.text.textColor = vd.colors.text
vdw.text.alignment = 'left'

function vdw.text.new(x, y, w, h, r, text, settings)
  settings = settings or {}
  local self = setmetatable(vdw.new(x, y, w, h, r, settings), vdw.text)
  self.text = text
  self.textColor = settings.textColor
  self.alignment = settings.alignment
  return self
end

function vdw.text:draw()
  vdw.draw(self)
  love.graphics.setColor(self.textColor)
  love.graphics.setFont(vd.font)
  love.graphics.printf(self.text, self.x + self.r, self.y, self.w-self.r-self.r, self.alignment)
end