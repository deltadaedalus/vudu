local vd = require(_vdpath .. "vudu")
local vdui = require(_vdpath .. "vuduUI")
local vdUtil = require(_vdpath .. "vuduUtil")
local vdw = vdui.widget

require(_vdpath .."Widgets/TextWidget")

vdw.referenceText = setmetatable({}, vdw.text)
vdw.referenceText.__index = vdw.referenceText

function vdw.referenceText.new(x, y, w, h, r, settings)
  settings = settings or {}
  local self = setmetatable(vdw.text.new())

  self.targetRef = settings.targetRef

  return self
end

function vdw.referenceText:update(dt)
  self.text = tostring(vudu.getByName(self.targetRef))
end