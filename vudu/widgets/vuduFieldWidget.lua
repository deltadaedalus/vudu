local vd = require(_vdreq .. "vudu")
local vdui = require(_vdreq .. "vuduui")
local vdw = vdui.widget

require(_vdreq .."widgets/textfieldwidget")

vdw.vuduField = setmetatable({}, vdw.textField)
vdw.vuduField.__index = vdw.vuduField

function vdw.vuduField.new(x, y, w, h, r, refstr, settings)
  local refValue = vd.getByName(refstr)
  settings = settings or {}
  local self = setmetatable(vdw.textField.new(x, y, w, h, r, tostring(refValue), settings), vdw.vuduField)
  self.refstr = refstr
  self.refType = type(refValue)
  self.autoEval = settings.autoEval or false
  self.fixedSize = settings.fixedSize or false
  return self
end

function vdw.vuduField:update(dt)
  if self.ui.textTarget ~= self then
    local value = vd.getByName(self.refstr)
    if self.autoEval and type(value) == "function" then value = value() end
    self.text = tostring(value)
  end
  if not self.fixedSize then self.w = vd.font:getWrap(tostring(self.text), 500) + 12 end
end

function vdw.textField:onEntered()
  if self.refType == 'string' then
    vd.setByName(self.refstr, self.text)
  elseif self.refType == 'number' then
    local num = tonumber(self.text)
    if (num) then vd.setByName(self.refstr, num) end
  end
end