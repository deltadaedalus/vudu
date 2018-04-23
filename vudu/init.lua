local path = ... .. '/'
_vdpath = path
local vd = require (path .. "vudu")

require (path .. "Widgets/SliderWidget")
require (path .. "Widgets/TextWidget")
require (path .. "Widgets/TextFieldWidget")
require (path .. "Widgets/vuduFieldWidget")
require (path .. "Widgets/CheckboxWidget")

vd.addWindow(require(path .. "vuduConsole"))
vd.addWindow(require(path .. "vuduBrowser"))
vd.addWindow(require(path .. "vuduControl"))
vd.addWindow(require(path .. "vuduHotkey"))

_vdpath = nil

return vd