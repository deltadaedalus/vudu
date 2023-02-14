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
require (path .. "Widgets.vuduCanvasWidget")

vd.addWindow(require(path .. "vuduConsole"))
vd.addWindow(require(path .. "vuduBrowser"))
vd.addWindow(require(path .. "vuduControl"))
vd.addWindow(require(path .. "vuduPhysics"))
vd.addWindow(require(path .. "vuduGraphics"))
vd.addWindow(require(path .. "vuduHotkey"))

vd.errorHandler = require(path .. "errorhandler")

_vdpath = nil
_vdreq = nil

local api = {
  initialize = vd.initialize,
  hook = vd.hook,
  addIgnore = vd.addIgnore,
  watch = vd.addWatchWindow,

  hotkey = {
    addSequence = vd.hotkey.addSequence,
    initializeDefaults = vd.initializeDefaultHotkeys,
  },

  physics = {
    setWorld = vd.physics.setWorld,
    setTransform = vd.physics.setTransformation,
  },

  graphics = {
    drawPoint = vd.graphics.drawPoint,
    drawLine = vd.graphics.drawLine,
    drawCircle = vd.graphics.drawCircle,
    drawText = vd.graphics.drawText,
    drawPing = vd.graphics.drawPing,
    setTransform = vd.graphics.setTransormation,
  },
}

return api