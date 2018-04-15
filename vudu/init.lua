local path = ... .. '.' 
local vd = (require path .. "vudu")

require (path .. "Widgets/SliderWidget")
require (path .. "Widgets/TextWidget")
require (path .. "Widgets/TextFieldWidget")
require (path .. "Widgets/vuduFieldWidget")

table.insert(vd.windows, require(path .. "vuduConsole"))
table.insert(vd.windows, require(path .. "vuduBrowser"))
table.insert(vd.windows, require(path .. "vuduControl"))

return vd