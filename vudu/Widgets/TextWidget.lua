local vd = require(_vdpath .. "vudu")
local vdui = require(_vdpath .. "vuduUI")
local vdw = vdui.widget

vdw.text = setmetatable({}, vdw)
vdw.text.__index = vdw.text
vdw.text.textColor = {0,0,0}

function vdw.text.new(x, y, w, h, r, text, settings)
  settings = settings or {}
  local self = setmetatable(vdw.new(x, y, w, h, r, settings), vdw.text)
  self.text = text
  self.textColor = settings.textColor
  return self
end

function vdw.text:draw()
  love.graphics.setColor(self.textColor)
  love.graphics.setFont(vd.font)
  love.graphics.printf(self.text, self.x + self.r, self.y, self.w-self.r-self.r, 'left')
end