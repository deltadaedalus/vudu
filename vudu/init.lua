local vd = require "vudu"

require "Widgets/SliderWidget"
require "Widgets/TextWidget"
require "Widgets/TextFieldWidget"
require "Widgets/vuduFieldWidget"

table.insert(vd.windows, require("vuduConsole"))
table.insert(vd.windows, require("vuduBrowser"))
table.insert(vd.windows, require("vuduControl"))

return vd