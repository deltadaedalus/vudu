local path = ... .. '.'
_vdreq = path
_vdpath = string.gsub(path, "%.", "/")
local vd = require (path .. "vudu")

require (path .. "Widgets.SliderWidget")
require (path .. "Widgets.TextWidget")
require (path .. "Widgets.TextFieldWidget")
require (path .. "Widgets.vuduFieldWidget")
require (path .. "Widgets.CheckboxWidget")
require (path .. "Widgets.vuduGraphWidget")

vd.addWindow(require(path .. "vuduConsole"))
vd.addWindow(require(path .. "vuduBrowser"))
vd.addWindow(require(path .. "vuduControl"))
vd.addWindow(require(path .. "vuduPhysics"))
vd.addWindow(require(path .. "vuduGraphics"))
vd.addWindow(require(path .. "vuduHotkey"))

_vdpath = nil
_vdreq = nil

return vd