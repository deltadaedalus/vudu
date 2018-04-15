local vd = require(_vdpath .. "vudu")
local vdwin = require(_vdpath .. "vuduWindow")
local vdui = require(_vdpath .. "vuduUI")
local vdutil = require(_vdpath .. "vuduUtil")

vd.console = {
  text = '',
  flashTimer = 0,
  flashPeriod = 1,
  history = {},
  historyFrame = nil,
  consoleWidget = nil,

  commandColor_pre11 = {208, 216, 224},
  responseColor_pre11 = {224, 232, 240},
  errorColor_pre11 = {240, 224, 232},
  textColor_pre11 = {0,0,0},
  commandColor = {13/16, 27/32, 7/8},
  responseColor = {7/8, 29/32, 15/16},
  errorColor = {15/16, 7/8, 29/32},
  textColor = {0,0,0}
}

vdwin.setup(vd.console, 496, 148)
vd.console.x = 2
vd.console.y = 450

function vd.console:load()
  vd.console.consoleWidget = vdui.widget.textField.new(2, 130, 400, 16, 6, "", {onEntered = vd.console.enterCommand})
  vd.console.historyFrame = vdui.widget.frame.new(2, 16, 400, 110, 6, {})
  
  vd.console.ui:addWidget(vd.console.consoleWidget)
  vd.console.ui:addWidget(vd.console.historyFrame)
end

vd.console:setCallback("update", function(self, dt)
  vd.console.flashTimer = vd.console.flashTimer + dt
  self.ui:update(dt)
end)

vd.console:setCallback("draw", function(self, x, y)
  self.ui:draw()
end)

function vd.console.enterCommand(textField)
  vd.console.addToHistory(textField.text, false)
  
  local cmd, err = loadstring(textField.text)
  if cmd then
    local result = cmd()
    if result ~= nil then
      vd.console.addToHistory(tostring(result), true)
    end
  else
    vd.console.addToHistory(tostring(err), true, vd.console.errorColor)
  end
  
  textField.text = ""
  textField.cursor = 0
end

function vd.console.addToHistory(text, isResponse, color)
  text = tostring(text)
  color = color or isResponse and vd.console.responseColor or vd.console.commandColor
  local x = isResponse and 2 or vd.console.historyFrame.w-352
  local w = vdui.widget.text.new(x, 2 + 20 * #vd.console.history, 350, 16, 6, text, {draw = vd.console._drawBubbleWidget})
  w.idleColor = color
  w.isResponse = isResponse
  vd.console.historyFrame:addWidget(w)
  table.insert(vd.console.history, text)
  vd.console.historyFrame.toy = math.min(-(2 + 20 * #vd.console.history - vd.console.historyFrame.h), 0)
end

local _bpl = 12
function vd.console._drawBubbleWidget(self)
  love.graphics.setColor(self.idleColor)
  vdutil.roundRect("fill", self.x, self.y, self.w, self.h, self.r)
  if (self.isResponse) then
    local xc, yc = self.x+self.r, self.y
    love.graphics.polygon("fill", xc, yc, xc+_bpl, yc, xc, yc-_bpl)
  else
    local xc, yc = self.x+self.w-self.r, self.y+self.h
    love.graphics.polygon("fill", xc, yc, xc-_bpl, yc, xc, yc+_bpl)
  end
  love.graphics.setColor(vd.console.textColor)
  love.graphics.print(self.text, self.x + self.r, self.y)
end


return vd.console