local vd = require(_vdreq .. "vudu")
local vdui = require(_vdreq .. "vuduui")
local vdw = vdui.widget

vdw.checkBox = setmetatable({}, vdw)
vdw.checkBox.__index = vdw.checkBox

function vdw.checkBox.new(x, y, w, h, r, settings)
  settings = settings or {}
  local self = setmetatable(vdw.new(x, y, w, h, r, settings), vdw.checkBox)

  self.targetRef = settings.targetRef

  return self
end

function vdw.checkBox:onRelease()
  vd.setByName(self.targetRef, not vd.getByName(self.targetRef))
end

function vdw.checkBox:draw()
  love.graphics.setColor(self:getColor())
  love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.r)
  if vd.getByName(self.targetRef) then
    love.graphics.setColor(vd.colors.highlight)
    love.graphics.rectangle("fill", self.x+2, self.y+2, self.w-4, self.h-4, math.max(self.r-2, 0))
  end
end