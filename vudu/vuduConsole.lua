local vd = require(_vdpath .. "vudu")
local vdwin = require(_vdpath .. "vuduWindow")
local vdui = require(_vdpath .. "vuduUI")
local vdutil = require(_vdpath .. "vuduUtil")

vd.console = vdwin.new({
  text = '',
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
}, {
  x = 2,
  y = 450, 
  w = 498, 
  h = 148,
  hasFrame = true
})

function vd.console:load()
  vd.console:addTopWidget()

  vd.console.consoleWidget = vdui.widget.textField.new(28, 130, 472, 16, 6, "", {
    onEntered = vd.console.enterCommand, 
    onResize = function(self) self:insetR(2); self:gravB(2) end
  })
  vd.console.historyFrame = vdui.widget.frame.new(2, 14, 480, 114, 6, {onResize = function(self) self:insetR(16); self:insetB(20) end, scrollable = true})
  vd.console.consoleSlider = vdui.widget.slider.new(490, 20, 0, 102, 6, {
    targetRef = "_vudu.console.historyFrame.toy",
    min = 0,
    max = -20,
    targetValue = 0,
    residual = 0.001,
    onResize = function(self) self.x = self.parent.w - 8; self:insetB(26); self:updatePosition() end,
  })

  local enterButton = vdui.widget.new(2, 130, 24, 16, 6, {
    onPress = function() vd.console.enterCommand(vd.console.consoleWidget) end;
    onResize = function(self) self:gravB(2) end
  })
  
  vd.console.frame:addWidget(vd.console.consoleWidget)
  vd.console.frame:addWidget(vd.console.historyFrame)
  vd.console.frame:addWidget(vd.console.consoleSlider)
  vd.console.frame:addWidget(enterButton)
end

vd.console:setCallback("update", function(self, dt)

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
  local x = isResponse and 2 or vd.console.historyFrame.w-452
  local w = vdui.widget.text.new(x, 2 + 18 * #vd.console.history, 450, 16, 6, text, {
    draw = vd.console._drawBubbleWidget,
    onResize = isResponse and function(self) self:insetR(20); self:insetL(2) end or function(self) self:insetR(2); self:insetL(20) end,
  })
  w.idleColor = color
  w.isResponse = isResponse
  w.drawArrow = #vd.console.history > 0 and vd.console.history[#vd.console.history].isResponse ~= isResponse
  vd.console.historyFrame:addWidget(w)
  w:onResize()
  table.insert(vd.console.history, {text = text, isResponse = isResponse})
  vd.console.historyFrame.toy = math.min(-(2 + 18 * #vd.console.history - vd.console.historyFrame.h), 0)
  vd.console.consoleSlider.max = math.min(-(2 + 18 * #vd.console.history - vd.console.historyFrame.h), 0)
end

local _bpl = 12
function vd.console._drawBubbleWidget(self)
  love.graphics.setColor(self.idleColor)
  love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.r)
  if self.drawArrow then
    if (self.isResponse) then
      local xc, yc = self.x+self.r, self.y
      love.graphics.polygon("fill", xc, yc, xc+_bpl, yc, xc, yc-_bpl)
    else
      local xc, yc = self.x+self.w-self.r, self.y+self.h
      love.graphics.polygon("fill", xc, yc, xc-_bpl, yc, xc, yc+_bpl)
    end
  end
  love.graphics.setColor(vd.console.textColor)
  love.graphics.print(self.text, self.x + self.r, self.y)
end


return vd.console