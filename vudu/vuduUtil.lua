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

function vdUtil.lerpColor(t, c1, c2)
  local s = 1-t
  return {s * c1[1] + t * c2[1], s * c1[2] + t * c2[2], s * c1[3] + t * c2[3], s * (c1[4] or 1) + t * (c2[4] or 1)}
end

function vdUtil.moveTowards(current, target, maxDelta)
  local diff = target - current
  if diff <= maxDelta then
    return target
  else
    return current + maxDelta * (diff / math.abs(diff))
  end
end

return vdUtil