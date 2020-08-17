local vd = require(_vdreq .. "vudu")
local vdwin = require(_vdreq .. "vuduwindow")
local vdui = require(_vdreq .. "vuduui")
local vdutil = require(_vdreq .. "vuduutil")

vd.console = vdwin.new({
  history = {},
  prevCommands = {},
  historyFrame = nil,
  consoleWidget = nil,
  commandPointer = 0,
}, {
  x = 2,
  y = 450, 
  w = 498, 
  h = 148,
  minimizeType = 'bottom',
  hasFrame = true
})

function vd.console:load()
  vd.console:addTopWidget()

  vd.console.consoleWidget = vdui.widget.textField.new(28, 130, 472, 16, 6, "", {
    onEntered = vd.console.enterCommand, 
    onResize = function(self) self:insetR(2); self:gravB(2) end,
    draw = vd.console._drawConsoleWidget
  })
  vd.console.consoleWidget.keypressed = vd.console._consoleKeypressed
  vd.console.historyFrame = vdui.widget.frame.new(2, 14, 480, 114, 6, {onResize = function(self) self:insetR(16); self:insetB(20) end, scrollable = true})
  vd.console.consoleSlider = vdui.widget.slider.new(490, 20, 0, 102, 6, {
    targetRef = "_vudu.console.historyFrame.toy",
    min = 0,
    max = -20,
    targetValue = 0,
    residual = 0.001,
    idleColor = vd.colors.buttonPress,
    pressColor = vd.colors.buttonIdle,
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
  vd.console.suggestions = vd.console.updateSuggestions()
end)


function vd.console.enterCommand(textField)
  vd.console.addToHistory(textField.text, false)
  table.insert(vd.console.prevCommands, textField.text)
  vd.console.commandPointer = 0
  
  local cmd, err = loadstring(textField.text)
  if cmd then
    local success, result = pcall(cmd)
    if not success then
      vd.console.addToHistory(tostring(result), true, vd.colors.consoleError)
    elseif result ~= nil then
      vd.console.addToHistory(tostring(result), true)
    end
  else
    vd.console.addToHistory(tostring(err), true, vd.colors.consoleError)
  end
  
  textField.text = ""
  textField.cursor = 0
end

function vd.console.addToHistory(text, isResponse, color)
  text = tostring(text)
  color = color or isResponse and vd.colors.consoleResponse or vd.colors.consoleCommand
  local x = isResponse and 2 or vd.console.historyFrame.w-452
  local w = vdui.widget.text.new(x, 2 + 18 * #vd.console.history, 450, 16, 6, text, {
    draw = vd.console._drawBubbleWidget,
    onResize = isResponse and function(self) self:insetR(20); self:insetL(2) end or function(self) self:insetR(2); self:insetL(20) end,
    onPress = vd.console._bubblePressed,
    idleColor = color,
    hoverColor = vd.colors.midhighlight
  })
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
  love.graphics.setColor(self:getColor())
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
  love.graphics.setColor(vd.colors.text)
  love.graphics.print(self.text, self.x + self.r, self.y)
end

function vd.console._consoleKeypressed(self, key, scancode, isRepeat)
  vdui.widget.textField.keypressed(self, key, scancode, isRepeat)
  if #vd.console.prevCommands > 0 then
    if key == 'up' then
      if vd.console.commandPointer == 0 then
        if self.text == "" then
          vd.console.commandPointer = #vd.console.prevCommands+1
        else
          table.insert(vd.console.prevCommands, self.text)
          vd.console.commandPointer = #vd.console.prevCommands
        end
      elseif vd.console.commandPointer == #vd.console.prevCommands then
        vd.console.prevCommands[#vd.console.prevCommands] = self.text
      end
      vd.console.commandPointer = math.max(vd.console.commandPointer - 1, 1)
      self.text = vd.console.prevCommands[vd.console.commandPointer]
    elseif key == 'down' then
      if vd.console.commandPointer == #vd.console.prevCommands then
        self.text = ""
        vd.console.commandPointer = 0
      elseif vd.console.commandPointer ~= 0 then
        vd.console.commandPointer = math.min(vd.console.commandPointer + 1, #vd.console.prevCommands)
        self.text = vd.console.prevCommands[vd.console.commandPointer]
      end
    end
  end

  if key == 'tab' and #vd.console.suggestions > 0 then
    local text = self.text:sub(1, vd.console.suggestions.left-1) .. vd.console.suggestions[1]
    self.cursor = #text
    text = text .. self.text:sub(vd.console.suggestions.right+1, -1)
    self.text = text
  end
end

function vd.console._drawConsoleWidget(self)
  vdui.widget.textField.draw(self)
  local sugNum = math.min(#vd.console.suggestions, 5)
  if sugNum > 0 and self.ui.textTarget == self then
    local maxChars = 0
    local maxSug = vd.console.suggestions[1]
    for i = 1, sugNum do if #vd.console.suggestions[i] > maxChars then
      maxChars = #vd.console.suggestions[i]
      maxSug = vd.console.suggestions[i]
    end end
    local sw = vd.font:getWrap(maxSug, 1000)+12
    local sx = vd.font:getWrap(string.sub(self.text, 0, self.cursor), 1000)
    love.graphics.setColor(self.pressColor)
    love.graphics.rectangle("fill", sx-6, self.y-4-sugNum*18, sw, sugNum*18+2, 6)
    love.graphics.setColor(self.textColor)
    for i = 1, sugNum do
      love.graphics.print(vd.console.suggestions[i], sx, self.y - 2 - 18*i)
    end
  end
end

function vd.console._bubblePressed(self)
  love.system.setClipboardText(self.text)
end

function vd.console.updateSuggestions()
  local text = vd.console.consoleWidget.text:sub(1, vd.console.consoleWidget.cursor)
  local suggestions = {}
  local curRef = ""
  local curStart = 1
  local i, j = 0, 0
  local pj = -1
  local cont = true
  while (j < #text and j ~= nil and pj ~= j) do
    local ni, nj = text:find("%w+%.?", j+1)
    if ni == nil then break end
    if cont and ni == j+1 then
      curRef = curRef .. text:sub(ni, nj)
    else
      curRef = text:sub(ni, nj)
      curStart = ni
    end
    cont = text:sub(nj, nj) == '.'
    pj = j
    i, j = ni, nj
    --table.insert(suggestions, text:sub(ni, nj))
  end

  local ei, ej = curRef:find("%w+$")
  ei = ei or #curRef+1
  ej = ej or ei-1
  local contextStr = curRef:sub(1, math.max(ei-2, 0))
  local match = curRef:sub(ei, ej)
  local context = vd.getByName(contextStr)
  if context == nil or contextStr == "" and match == "" or type(context) ~= 'table' or curStart + ej - 1 ~= #text then return {} end


  for i, v in pairs(context) do
    if type(i) == "string" and (match == "" or i:find(match)) then
      table.insert(suggestions, i)
    end
  end

  table.sort(suggestions, function(u, v) 
      local appDiff = v:find(match) - u:find(match)
      if appDiff > 0 then return true end
      if appDiff == 0 then return #u < #v end
      return false
    end
  )

  suggestions.left = curStart + ei - 1
  suggestions.right = curStart + ej - 1
  if #suggestions == 1 and suggestions[1] == curRef:sub(ei, ej) then return {} end
  return suggestions
end


return vd.console