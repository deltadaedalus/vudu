local vd = require(_vdreq .. "vudu")
local vdwin = require(_vdreq .. "vuduwindow")
local vdui = require(_vdreq .. "vuduui")

vd.graphics = vdwin.new({
  afterImages = {},
  transform = {x = 0, y = 0, z = 1, r = 0},
}, {
  runHidden = true
})

function vd.graphics:load()

end

function vd.graphics:update(dt)
  
end

function vd.graphics:draw()
  love.graphics.push()
  love.graphics.origin()
  love.graphics.scale(self.transform.z)
  love.graphics.translate(-self.transform.x, -self.transform.y)
  love.graphics.rotate(self.transform.r)

  for i, v in ipairs(self.afterImages) do
    v.draw(v)
  end

  for i = #self.afterImages, 1, -1 do
    if vd.timer > self.afterImages[i].expire then
      table.remove(self.afterImages, i)
    end
  end

  love.graphics.pop()
end

function vd.graphics.setTransformation(x, y, z, r)
  vd.graphics.transform = {x=x or 0, y=y or 0, z=z or 0, r=r or 0}
end

---
---
---

vd.graphics.afterImage = {}
vd.graphics.afterImage.__index = vd.graphics.afterImage

function vd.graphics.afterImage.new(color, duration, draw)
  settings = settings or {}
  local self = setmetatable({}, vd.graphics.afterImage)
  self.start = vd.timer
  self.expire = vd.timer + duration
  self.color = color
  self.draw = draw
  table.insert(vd.graphics.afterImages, self)
  return self
end

function vd.graphics.afterImage:setColor()
  if (self.color == nil) then error('nil color') end
  if self.expire == self.start then
    love.graphics.setColor(self.color)
  else
    love.graphics.setColor(vdUtil.lerpColor((vd.timer-self.start) / (self.expire-self.start), self.color, {self.color[1], self.color[2], self.color[3], 0}))
  end
end

---
---
---

function vd.graphics.drawPoint(color, duration, x, y, w)
  local self = vd.graphics.afterImage.new(color, duration, vd.graphics._drawPoint)
  self.x = x
  self.y = y
  self.w = w or 2
end

function vd.graphics.drawLine(color, duration, sx, sy, ex, ey, w)
  local self = vd.graphics.afterImage.new(color, duration, vd.graphics._drawLine)
  self.sx = sx
  self.sy = sy
  self.ex = ex
  self.ey = ey
  self.w = w or 1
end

function vd.graphics.drawCircle(color, duration, x, y, r, w)
  local self = vd.graphics.afterImage.new(color, duration, vd.graphics._drawCircle)
  self.x = x
  self.y = y
  self.r = r
  self.w = w or 1
end

function vd.graphics.drawText(color, duration, x, y, text)
  local self = vd.graphics.afterImage.new(color, duration, vd.graphics._drawText)
  self.x = x
  self.y = y
  self.text = text
end

function vd.graphics.drawPing(color, duration, x, y, r)
  local self = vd.graphics.afterImage.new(color, duration, vd.graphics._drawPing)
  self.x = x
  self.y = y
  self.r = r or 10
end








function vd.graphics._drawPoint(self)
  self:setColor()
  love.graphics.circle("fill", self.x, self.y, self.w)
end


--self.points
function vd.graphics._drawLine(self)
  self:setColor()
  love.graphics.setLineWidth(self.w * vd.camera.z)
  love.graphics.line(self.sx, self.sy, self.ex, self.ey)
end

--self.r
function vd.graphics._drawCircle(self)
  self:setColor()
  love.graphics.setLineWidth(self.w * vd.camera.z)
  love.graphics.circle('line', self.x, self.y, self.r)
end

--self.x, self.y
--self.text
function vd.graphics._drawText(self)
  self:setColor()
  love.graphics.print(self.text, self.x, self.y)
end

--self.x, self.y, self.r
function vd.graphics._drawPing(self)
  self:setColor()
  love.graphics.setLineWidth(2 * vd.camera.z)

  local tx, ty = love.graphics.transformPoint(self.x, self.y)
  local r1 = ((vd.timer * 10) % 5) * vd.camera.z * self.r/5
  local r2 = (math.max(vd.timer * 10 - 2.5, 0) % 5) * vd.camera.z * self.r/5
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  local cx, cy = w/2, h/2
  local dx, dy = tx - cx, ty - cy
  local absSlope = math.abs(dy/dx)
  local screenSlope = h/w

  if tx > 0 and tx < w and ty > 0 and ty < h then
    love.graphics.circle("line", self.x, self.y, r1)
    love.graphics.circle("line", self.x, self.y, r2)
  else
    local scale = 0
    if      dy < 0  and absSlope >  screenSlope then
      scale = -h/2 / dy
    elseif  dy >= 0 and absSlope >  screenSlope then
      scale = h/2 / dy
    elseif  dx < 0  and absSlope <= screenSlope then
      scale = -w/2 / dx
    elseif  dx >= 0 and absSlope <= screenSlope then
      scale = w/2 / dx
    end
    local rx, ry = love.graphics.inverseTransformPoint(cx + dx * scale, cy + dy * scale)
    love.graphics.circle("line", rx, ry, r1)
    love.graphics.circle("line", rx, ry, r2)
  end
end

return vd.graphics