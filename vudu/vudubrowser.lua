local vd = require(_vdreq .. "vudu")
local vdwin = require(_vdreq .. "vuduwindow")
local vdui = require(_vdreq .. "vuduui")
local vdutil = require(_vdreq .. "vuduutil")

vd.browser = vdwin.new({
  ySpace = 16,
  xSpace = 16,
  
  contextString = "",
  ignore = love.filesystem.load(vd.path .."vdignore.lua")(),
  expand = {},
  bakedContext = {},
  hoverIndex = 1,
  
  editingPath = '',   --index path to the variable being edited from the current context 
  editingType = '',   --type of the variable being edited
  editingValue = '',  --current value being edited
  
  browserFrame = nil,
  widgetCache = {},
}, {
  x = 2, 
  y = 2, 
  w = 246, 
  h = 446, 
  hasFrame = true
})

function vd.browser:load()
  vd.browser:addTopWidget()
  
  vd.browser.browserFrame = vdui.widget.frame.new(2, 20, 228, 424, 6, {
    onResize = function(self) self:edgeL(2); self:edgeT(20); self:insetB(2); self:insetR(16) end,
    scrollable = true,
    shufflable = true
  })
  
  vd.browser.browserSlider = vdui.widget.slider.new(238, 26, 0, 412, 6, {
    targetRef = "_vudu.browser.browserFrame.toy",
    min = 0,
    max = -20,
    targetValue = 0,
    residual = 0.001,
    idleColor = vd.colors.buttonPress,
    pressColor = vd.colors.buttonIdle,
    onResize = function(self) self:setX(-8); self:insetB(8) self:updatePosition() end,
  })
  
  vd.browser.frame:addWidget(vd.browser.browserSlider)
  vd.browser.frame:addWidget(vd.browser.browserFrame)

  vd.browser._loadRightClickMenu()

  vd.browser.bakedContext = vd.browser.bakeTable(_G)
  vd.browser.bakeUI()
end


function vd.browser:update(dt)
  vd.browser.bakedContext = vd.browser.bakeTable(_G)
  vd.browser.bakeUI()
end


function vd.browser.bakeTable(t, context, list, depth)
  context = context and (context .. '.') or ""
  list = list or {}
  depth = depth or 0
  
  --Associative segment of table
  for i, v in pairs(t) do
    if type(i)~="userdata" and not vd.browser.ignore[context..i] then -- igonre userdata to avoid crash
    local typ = type(v)
    if type(i) == "number" then
      local typ = type(v)
      table.insert(list, {label = i, value = v, depth = depth, ref = context .. i})
      if typ == 'table' and vd.browser.expand[context .. i] then
        vd.browser.bakeTable(v, context .. i, list, depth+1)
      end
    else
      if not ( (typ == 'function' and not vd.showFunctions) or (i:sub(1,1) == '_' and not vd.showUnderscores) ) then
        table.insert(list, {label = i, value = v, depth = depth, ref = context .. i})
        if typ == 'table' and vd.browser.expand[context .. i] then
          vd.browser.bakeTable(v, context .. i, list, depth+1)
        end
      end
    end
  end end
  
  --Indexed segment of table
  for i, v in pairs(t) do
    
  end
  
  return list
end


function vd.browser.bakeUI()
  vd.browser.browserFrame.widgets = {}
  local y = vd.browser.ySpace + 1
  for i, v in ipairs(vd.browser.bakedContext) do
    vd.browser.addBrowserWidget(v, vd.browser.ySpace + 1 + v.depth * vd.browser.xSpace, y)
    y = y + vd.browser.ySpace
  end
  vd.browser.browserSlider.max = math.min(0, vd.browser.browserFrame.h - y - vd.browser.ySpace)
end


function vd.browser.addBrowserWidget(widgetDat, x, y)
  local label = widgetDat.label
  local value = widgetDat.value
  local typ = type(value)
  local labelLen = vd.font:getWrap(label, 500)
  local valueLen = vd.font:getWrap(tostring(value), 500)
  local frame = vd.browser.browserFrame
  
  if vd.browser.widgetCache[widgetDat.ref] == nil then
    local cache = {}
    
    local labelText = vdui.widget.text.new(x, y+1, labelLen + 12, vd.browser.ySpace-2, 6, label, {textColor = vd.colors.label, onPress = vd.browser._menuCallback})
    labelText.target = widgetDat.ref
    table.insert(cache, labelText)
    
    if typ == 'table' then
      local expButton = vdui.widget.new(x - vd.browser.ySpace, y+1, vd.browser.ySpace-2, vd.browser.ySpace-2, vd.browser.ySpace/2-1, {
        onRelease = vd.browser._expandCallback,
        idleColor = vd.colors.highlight
      })
      expButton.target = widgetDat.ref
      table.insert(cache, expButton)
      
      --frame:addWidget(vdui.widget.text.new(x + labelLen + 12, y+1, valueLen + 12, vd.browser.ySpace-2, 6, tostring(value), {textColor = vd.colors[typ]}))
    elseif typ == 'string' or typ == 'number' then
      local valueWidget = vdui.widget.vuduField.new(x + labelLen + 12, y+1, valueLen + 12, vd.browser.ySpace-2, 6, widgetDat.ref, {textColor = vd.colors[typ], idleColor = vd.colors.midhighlight})
      table.insert(cache, valueWidget)
    elseif typ == 'boolean' then
      local valueWidget = vdui.widget.checkBox.new(x + labelLen + 12, y+1, vd.browser.ySpace-2, vd.browser.ySpace-2, 6, {idleColor = vd.colors.midhighlight, targetRef = widgetDat.ref})
      table.insert(cache, valueWidget)
    else
      local valueText = vdui.widget.text.new(x + labelLen + 12, y+1, valueLen + 12, vd.browser.ySpace-2, 6, tostring(value), {textColor = vd.colors[typ]})
      table.insert(cache, valueText)
    end
    
    vd.browser.widgetCache[widgetDat.ref] = cache
  end
  
  for i, w in ipairs(vd.browser.widgetCache[widgetDat.ref]) do
    w.y = y + 1
    frame:addWidget(w)
  end
end


function vd.browser._expandCallback(self, x, y, button, isTouch)
  vd.browser.expand[self.target] = not vd.browser.expand[self.target]
  self.idleColor = vd.browser.expand[self.target] and vd.colors.lowlight or vd.colors.highlight
end

function vd.browser._menuCallback(self, x, y, button, isTouch)
  vd.browser.rightClickMenu.target = self.target
  vd.browser.rightClickMenu.foreFrame.x, vd.browser.rightClickMenu.foreFrame.y = love.mouse.getPosition()
  vd.ui:addWidgetFront(vd.browser.rightClickMenu)
end

function vd.browser._loadRightClickMenu()
  local backFrame = vdui.widget.frame.new(0, 0, vd.ui.w, vd.ui.h, 0, {
    idleColor = {0, 0, 0, 0}, hoverColor = {0, 0, 0, 0}, pressColor = {0, 0, 0, 0}
  })
  
  local backButton = vdui.widget.new(0, 0, vd.ui.w, vd.ui.h, 0, {
    idleColor = {0, 0, 0, 0}, hoverColor = {0, 0, 0, 0}, pressColor = {0, 0, 0, 0},
    onPress = function(self, x, y, button, isTouch)
      vd.ui:removeWidget(vd.browser.rightClickMenu)
      vd.ui.heldWidget = nil
      vd.browser.rightClickMenu.unClickable = false
    end
  })

  local watchOption = vdui.widget.text.new(0, 0, 120, 14, 6, "Watch", {
    onRelease = function(self, x, y, button, isTouch)
      local mx, my = love.mouse.getPosition()
      vd.ui:removeWidget(vd.browser.rightClickMenu)
      vd.addWatchWindow(vd.browser.rightClickMenu.target, mx - 20, my - 6)
    end
  })
  local ignoreOption = vdui.widget.text.new(0, 0, 120, 14, 6, "Ignore", {
    onRelease = function(self, x, y, button, isTouch)
      vd.ui:removeWidget(vd.browser.rightClickMenu)
      vd.setIgnore(vd.browser.rightClickMenu.target)
    end,
  })

  local foreFrame = vdutil.autoFrameColumn(0, 0, {watchOption, ignoreOption})
  backFrame.foreFrame = foreFrame
  backFrame:addWidget(foreFrame)
  backFrame:addWidget(backButton)

  vd.browser.rightClickMenu = backFrame
end



























return vd.browser
