local vd = require(_vdreq .. "vudu")
local vdui = require(_vdreq .. "vuduui")
local vdw = vdui.widget

vdw.vuduGraph = setmetatable({}, vdw)
vdw.vuduGraph.__index = vdw.vuduGraph

function vdw.vuduGraph.new(x, y, w, h, r, refstr, settings)
  settings = settings or {}
  local self = setmetatable(vdw.new(x, y, w, h, r, settings), vdw.vuduGraph)
  self.backColor = settings.backColor or vd.colors.dark
  self.gridColor = settings.gridColor or vd.colors.midhighlight
  self.lineColor = settings.lineColor or vd.colors.highlight
  self.period = settings.period or 8
  self.data = {}
  self.dataTime = {}
  self.refstr = refstr
  self.hoverPos = {0,0}
  return self
end

function vdw.vuduGraph:update(dt)
  if not vd.paused then
    local refValue = vd.getByName(self.refstr)
    if type(refValue) == "function" then refValue = refValue() end
    table.insert(self.data, refValue)
    table.insert(self.dataTime, vd.gameTimer)

    while self.dataTime[1] < vd.gameTimer-self.period do
      table.remove(self.dataTime, 1)
      table.remove(self.data, 1)
    end
  end
end

function vdw.vuduGraph:whileHovered(x, y, dt)
  self.hoverPos = {x, y}
end

function vdw.vuduGraph:draw()
  love.graphics.setColor(self.backColor)
  love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.r)

  local points = {}
  local minV = math.huge
  local maxV = -math.huge
  for i, v in ipairs(self.data) do
    table.insert(points, self.x + self.w + (self.dataTime[i] - vd.gameTimer)/self.period * self.w)
    table.insert(points, v)
    minV = math.min(v, minV)
    maxV = math.max(v, maxV)
  end
  if (maxV == minV) then minV, maxV = minV-1, maxV+1 end

  for i = 2, #points, 2 do
    points[i] = (self.y + self.h - (self.h-4) * (points[i]-minV) / (maxV-minV) - 2)
  end

  love.graphics.setColor(self.lineColor)
  if (#points >= 4) then
    love.graphics.setLineWidth(1.5)
    love.graphics.setLineJoin("bevel")
    love.graphics.line(points)

    if (self.isHovered) then 
      local x = self.hoverPos[1]
      local xt = vd.gameTimer - self.period * (1-x/self.w)
      local i = 1
      while self.dataTime[i+1] and self.dataTime[i+1] < xt do i = i+1 end
      local px, py = points[i*2-1], points[i*2]
      love.graphics.setColor(self.gridColor)
      love.graphics.line(self.x, py, self.x+self.w, py)
      love.graphics.line(px, self.y, px, self.y+self.h)
      love.graphics.print(self.data[i], 2, self.h-2)
    end
  end
end