local vd = require(_vdreq .. "vudu")
local vdui = require(_vdreq .. "vuduUI")
local vdw = vdui.widget

vdw.vuduCanvas = setmetatable({}, vdw)
vdw.vuduCanvas.__index = vdw.vuduCanvas

function vdw.vuduCanvas.new(x, y, w, h, r, refstr, settings)
  settings = settings or {}
  local self = setmetatable(vdw.new(x, y, w, h, r, settings), vdw.vuduCanvas)
  self.refstr = refstr
  return self
end

function vdw.vuduCanvas:draw()
  love.graphics.setColor(1, 1, 1)
  local refCanvas = vd.getByName(self.refstr)

  local sx, sy = self.w / refCanvas:getWidth(), self.h / refCanvas:getHeight()
  local sxy = math.min(sx, sy)
  
  love.graphics.stencil(function() love.graphics.rectangle('fill', self.x, self.y, self.w, self.h * sx/sy, self.r) end, "increment", 1, true)
  local depth = self.parent:getFrameDepth()+1
  local sM, sV = love.graphics.getStencilTest()
  love.graphics.setStencilTest('greater', depth-1)

  love.graphics.draw(refCanvas, self.x, self.y, 0, sx, sx)

  love.graphics.stencil(function() love.graphics.rectangle('fill', self.x, self.y, self.w, self.h * sx/sy, self.r) end, "decrement", 1, true)
  love.graphics.setStencilTest(sM, sV)
end