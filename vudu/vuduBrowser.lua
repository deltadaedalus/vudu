local vd = require(_vdpath .. "vudu")
local vdwin = require(_vdpath .. "vuduWindow")
local vdui = require(_vdpath .. "vuduUI")

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

  expColor_pre11 = {128, 128, 128},
  expColor = {1/2, 1/2, 1/2},
  fieldColor = {7/8, 7/8, 7/8}
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
    scrollable = true
  })
  
  vd.browser.browserSlider = vdui.widget.slider.new(238, 26, 0, 412, 6, {
    targetRef = "_vudu.browser.browserFrame.toy",
    min = 0,
    max = -20,
    targetValue = 0,
    residual = 0.001,
    onResize = function(self) self:setX(-8); self:insetB(8) self:updatePosition() end,
  })
  
  vd.browser.frame:addWidget(vd.browser.browserSlider)
  vd.browser.frame:addWidget(vd.browser.browserFrame)

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
  
  for i, v in pairs(t) do if type(i) ~= 'number' and not vd.browser.ignore[context .. i] then
    local typ = type(v)
    table.insert(list, {label = i, value = v, depth = depth, ref = context .. i})
    if typ == 'table' and vd.browser.expand[context .. i] then
      vd.browser.bakeTable(v, context .. i, list, depth+1)
    end
  end end
  
  for i, v in ipairs(t) do
    local typ = type(v)
    table.insert(list, {label = i, value = v, depth = depth, ref = context .. i})
    if typ == 'table' and vd.browser.expand[context .. i] then
      vd.browser.bakeTable(v, context .. i, list, depth+1)
    end
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
    
    local labelText = vdui.widget.text.new(x, y+1, labelLen + 12, vd.browser.ySpace-2, 6, label, {textColor = vd.colors.label})
    table.insert(cache, labelText)
    
    if typ == 'table' then
      local expButton = vdui.widget.new(x - vd.browser.ySpace, y+1, vd.browser.ySpace-2, vd.browser.ySpace-2, vd.browser.ySpace/2-1, {
        onRelease = vd.browser.expandCallback,
        idleColor = vd.browser.expColor
      })
      expButton.target = widgetDat.ref
      table.insert(cache, expButton)
      
      --frame:addWidget(vdui.widget.text.new(x + labelLen + 12, y+1, valueLen + 12, vd.browser.ySpace-2, 6, tostring(value), {textColor = vd.colors[typ]}))
    elseif typ == 'string' or typ == 'number' then
      local valueWidget = vdui.widget.vuduField.new(x + labelLen + 12, y+1, valueLen + 12, vd.browser.ySpace-2, 6, widgetDat.ref, {textColor = vd.colors[typ], idleColor = vd.browser.fieldColor})
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


function vd.browser.expandCallback(self, x, y, button, isTouch)
  vd.browser.expand[self.target] = not vd.browser.expand[self.target]
end


function vd.browser.drawBaked(list, x, y)
  for i, v in ipairs(list) do
    if i == vd.browser.hoverIndex then
      love.graphics.setColor(224, 224, 224)
      love.graphics.rectangle("fill", 0, y + (i - 1)*vd.browser.ySpace, 500, vd.browser.ySpace)
    end
    
    if type(v.label) ~= 'number' then
      local typ = type(v.value)
      love.graphics.setColor(255, 255, 255)
      love.graphics.print({vd.colors.label, v.label .. ': ', vd.colors[typ], tostring(v.value) .. ""}, x + v.depth*vd.browser.xSpace, y + (i - 1)*vd.browser.ySpace)
    else
      love.graphics.setColor(vd.colors[type(v.value)])
      love.graphics.print(tostring(v.value) .. "", x + v.depth*vd.browser.xSpace, y + (i - 1)*vd.browser.ySpace)
      love.graphics.setColor(vd.colors.index)
      love.graphics.printf(tostring(v.label), x + v.depth*vd.browser.xSpace - 104, y + (i - 1)*vd.browser.ySpace, 100, 'right')
    end
  end
end




























return vd.browser