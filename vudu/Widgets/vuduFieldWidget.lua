local vd = require "vudu"
local vdui = require "vuduUI"
local vdw = vdui.widget

require "Widgets/TextFieldWidget"

vdw.vuduField = setmetatable({}, vdw.textField)
vdw.vuduField.__index = vdw.vuduField

function vdw.vuduField.new(x, y, w, h, r, refstr, settings)
  local refValue = vd.getByName(refstr)
  local self = setmetatable(vdw.textField.new(x, y, w, h, r, tostring(refValue), settings), vdw.vuduField)
  self.refstr = refstr
  self.refType = type(refValue)
  return self
end

function vdw.vuduField:update(dt)
  if self.ui.textTarget ~= self then
    self.text = tostring(vd.getByName(self.refstr))
    self.w = vd.font:getWrap(tostring(self.text), 500) + 12
  end
end

function vdw.textField:onEntered()
  if self.refType == 'string' then
    vd.setByName(self.refstr, self.text)
  elseif self.refType == 'number' then
    local num = tonumber(self.text)
    if (num) then vd.setByName(self.refstr, num) end
  end
end