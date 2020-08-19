local vd = require(_vdreq .. "vudu")
local vdui = require(_vdreq .. "vuduui")
local vdUtil = require(_vdreq .. "vuduutil")
local vdw = vdui.widget

require(_vdreq .."Widgets/TextWidget")

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