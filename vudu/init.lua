local path = ... .. '.'
_vdreq = path
_vdpath = string.gsub(path, "%.", "/")
local vd = require (path .. "vudu")

require (path .. "widgets/sliderwidget")
require (path .. "widgets/textwidget")
require (path .. "widgets/textfieldwidget")
require (path .. "widgets/vudufieldwidget")
require (path .. "widgets/checkboxwidget")
require (path .. "widgets/vudugraphwidget")

vd.addWindow(require(path .. "vuduconsole"))
vd.addWindow(require(path .. "vudubrowser"))
vd.addWindow(require(path .. "vuducontrol"))
vd.addWindow(require(path .. "vuduphysics"))
vd.addWindow(require(path .. "vudugraphics"))
vd.addWindow(require(path .. "vuduhotkey"))

_vdpath = nil
_vdreq = nil

return vd