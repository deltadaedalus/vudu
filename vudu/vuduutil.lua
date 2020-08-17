local vdUtil = {}

--[[function vdUtil.roundRect(mode, x, y, w, h, r)
  if mode == 'fill' then
    love.graphics.rectangle("fill", x+r, y, w-r-r, h)
    love.graphics.rectangle("fill", x, y+r, r, h-r-r)
    love.graphics.rectangle("fill", x+w-r, y+r, r, h-r-r)
    love.graphics.arc("fill", "pie", x+r, y+r, r, math.pi, math.pi*3/2)
    love.graphics.arc("fill", "pie", x+w-r, y+r, r, math.pi*3/2, math.pi*2)
    love.graphics.arc("fill", "pie", x+w-r, y+h-r, r, 0, math.pi/2)
    love.graphics.arc("fill", "pie", x+r, y+h-r, r, math.pi/2, math.pi)
  elseif mode == 'line' then
    
  else
    error('Invalid draw mode: ' + mode)
  end
end]]

function vdUtil.roundLine(w, x1, y1, x2, y2)
  love.graphics.setLineWidth(w)
  love.graphics.line(x1, y1, x2, y2)
  love.graphics.circle("fill", x1, y1, w/2)
  love.graphics.circle("fill", x2, y2, w/2)
end

function vdUtil.roundRectContains(px, py, x, y, w, h, r)
  local ax, ay = px-x, py-y
  if ax <= w - r and ax >= r and ay <= h and ay >= 0 then return true end
  if ax <= w and ax >= 0 and ay <= h - r and ay >= r then return true end
  
  local r2 = r*r
  
  if vdUtil.sqDist(ax, ay, r, r) < r2 then return true end
  if vdUtil.sqDist(ax, ay, r, h - r) < r2 then return true end
  if vdUtil.sqDist(ax, ay, w - r, r) < r2 then return true end
  if vdUtil.sqDist(ax, ay, w - r, h - r) < r2 then return true end
  
  return false
end

function vdUtil.sqDist(x, y, u, v)
  local a = x-u
  local b = y-v
  return a*a + b*b
end

function vdUtil.projectScale(x1,y1,x2,y2)
  return (x1*x2 + y1*y2) / (x2*x2 + y2*y2)
end

local _maxAlpha = love._version_major < 11 and 255 or 1
function vdUtil.lerpColor(t, c1, c2)
  local s = 1-t
  return {
    s * c1[1] + t * c2[1], 
    s * c1[2] + t * c2[2], 
    s * c1[3] + t * c2[3], 
    s * (c1[4] or _maxAlpha) + t * (c2[4] or _maxAlpha)
  }
end

function vdUtil.moveTowards(current, target, maxDelta)
  local diff = target - current
  if diff <= maxDelta then
    return target
  else
    return current + maxDelta * (diff / math.abs(diff))
  end
end

function vdUtil.copyColor(value, target)
  target[1] = value[1]
  target[2] = value[2]
  target[3] = value[3]
  target[4] = value[4] or _maxAlpha
end

function vdUtil.lerp(x1, y1, x2, y2, t)
  return x1 + (x2-x1)*t, y1 + (y2-y1)*t
end

function vdUtil.dottedLine(ofs, fill, gap, points)
  ofs = ofs % (fill+gap)
  local draw = ofs < fill
  local jump = draw and fill - ofs or gap + fill - ofs
  for i = 1, #points-3, 2 do
    local x1, y1, x2, y2 = points[i], points[i+1], points[i+2], points[i+3]
    local dist = math.sqrt((x2-x1)^2 + (y2-y1)^2)
    local j = 0
    while jump < dist and j < 100 do
      local xn, yn = vdUtil.lerp(x1, y1, x2, y2, jump/dist)
      if (draw) then love.graphics.line(x1, y1, xn, yn) end
      x1, y1 = xn, yn
      dist = math.sqrt((x2-x1)^2 + (y2-y1)^2)
      draw = not draw
      jump = draw and fill or gap
      j = j + 1
    end
    jump = jump - dist
    if draw then love.graphics.line(x1, y1, x2, y2) end
  end
end

function vdUtil.drawGear(x, y, inradius, outradius, theta, teeth)
  local adif = math.pi*2/teeth
  for i = 0, teeth-1 do
    local a = theta + adif*i
    local x0, y0 = x + inradius * math.cos(a), y + inradius * math.sin(a)
    local x1, y1 = x + inradius * math.cos(a+adif/2), y + inradius * math.sin(a+adif/2)
    local x2, y2 = x + outradius * math.cos(a+adif/2), y + outradius * math.sin(a+adif/2)
    local x3, y3 = x + outradius * math.cos(a+adif), y + outradius * math.sin(a+adif)
    local x4, y4 = x + inradius * math.cos(a+adif), y + inradius * math.sin(a+adif)
    love.graphics.line(x0,y0,x1,y1,x2,y2,x3,y3,x4,y4)
  end
end

function vdUtil.autoFrameColumn(x, y, buttons)
  local h = 2
  local w = 0
  for i, b in ipairs(buttons) do 
    b.y = h + 2
    b.x = 2
    h = h + b.h + 2
    w = math.max(w, b.w+4)
  end

  local frame = _vudu.vuduUI.widget.frame.new(x, y, w, h, 6)

  for i, b in ipairs(buttons) do frame:addWidget(b) end

  return frame
end

return vdUtil