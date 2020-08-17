local vd = require(_vdreq .. "vudu")
local vdwin = require(_vdreq .. "vuduwindow")
local vdui = require(_vdreq .. "vuduui")

vd.physics = vdwin.new({
  colors = {
    shape = {1/4, 1, 2/3},
    contact = {1, 1/2, 0},
    joint = {2/3, 1/4, 1},
    error = {1, 0, 1/4},
  },

  world = nil,
  lWidth = 1,
  renderContacts = true,
  renderShapes = true,
  renderJoints = true,
  allJoints = {},
  transform = {x = 0, y = 0, z = 1, r = 0},
}, {
  runHidden = false
})


function vd.physics:load()

end

function vd.physics:update(dt)
  if self.world then
    for i, j in ipairs(self.world:getJoints()) do if not vd.physics.allJoints[j] then 
      vd.physics.allJoints[j] = j
    end end
  end
end

function vd.physics:draw()
  love.graphics.setLineWidth(self.lWidth)
  love.graphics.push()
  love.graphics.origin()
  love.graphics.scale(self.transform.z)
  love.graphics.translate(-self.transform.x, -self.transform.y)
  love.graphics.rotate(self.transform.r)

  if self.world then
    --Shapes/Fixtures/Bodies
    if self.renderShapes then
      love.graphics.setColor(vd.physics.colors.shape)

      for i, body in ipairs(self.world:getBodies()) do
        for i, f in ipairs(body:getFixtures()) do
          local shape = f:getShape()
          if shape:typeOf('CircleShape') then
            local x, y = body:getWorldPoints(shape:getPoint())
            love.graphics.circle('line', x, y, shape:getRadius())
          else
            love.graphics.polygon('line', body:getWorldPoints(shape:getPoints()))
          end
        end
      end
    end

    --Contacts
    if self.renderContacts then
      love.graphics.setColor(vd.physics.colors.contact)

      for i, c in ipairs(self.world:getContacts()) do
        local x1, y1, x2, y2 = c:getPositions()
        if x1 then love.graphics.circle('line', x1, y1, 4) end
      end
    end

    --Joints
    if self.renderJoints then
      love.graphics.setColor(vd.physics.colors.joint)

      for i, j in pairs(vd.physics.allJoints) do
        vd.physics.drawJoint[j:getType()](j)
      end
    end
  end

  love.graphics.pop()
end

function vd.physics.setWorld(world)
  vd.physics.world = world
end

function vd.physics.setTransformation(x, y, z, r)
  vd.physics.transform = {x=x or 0, y=y or 0, z=z or 0, r=r or 0}
end




vd.physics.drawJoint = {}

vd.physics.drawJoint["distance"] = function(joint)
  local x1, y1, x2, y2 = joint:getAnchors()

  local f = joint:getFrequency()

  if f == 0 then
    love.graphics.line(x1, y1, x2, y2)
  else
    local u = 5
    local d = math.sqrt((x2-x1)^2 + (y2-y1)^2)
    local l = joint:getLength()
    local n = math.floor(l/u)
    local b = l-(n*u)
    local normx, normy = (x2-x1)/d, (y2-y1)/d
    local ylen = u*((d-b)/(l-b))

    local phase = 1
    for i = 0, n-1 do
      local sx, sy = x1 + (b/2 + ylen*i) * normx, y1 + (b/2 + ylen*i) * normy
      love.graphics.line(
        sx, sy, 
        sx + normx*ylen/2 - normy*u*phase, sy + normy*ylen/2 + normx*u*phase,
        sx + normx*ylen, sy + normy*ylen)
      phase = -phase
    end
    love.graphics.line(x1, y1, x1+b/2*normx, y1+b/2*normy)
    love.graphics.line(x2, y2, x2-b/2*normx, y2-b/2*normy)
  end
end

vd.physics.drawJoint["friction"] = function(joint)
  local a1, c1, a2, c2 = joint:getAnchors()
  local b1, b2 = joint:getBodies()

  local x1, y1 = b1:getPosition()
  local x2, y2 = b2:getPosition()
  local vx1, vy1 = b1:getLinearVelocity()
  local vx2, vy2 = b2:getLinearVelocity()

  local avx, avy = (vx1-vx2) / 2, (vy1-vy2) / 2
  local dir = math.atan2(avy, avx)

  vdUtil.dottedLine(0, 5, 15, {a1, c1, a2, c2})
  for i = 1, 3 do
    love.graphics.arc('line', 'open', x1, y1, 5 + i*3, dir-math.pi/(i+1), dir+math.pi/(i+1))
  end

  for i = 1, 3 do
    love.graphics.arc('line', 'open', x2, y2, 5 + i*3, -dir-math.pi/(i+1), -dir+math.pi/(i+1))
  end
    
end

vd.physics.drawJoint["gear"] = function(joint)
  local j1, j2 = joint:getJoints()
  local ratio = joint:getRatio()
  local x1, y1 = j1:getAnchors()
  local x2, y2 = j2:getAnchors()
  local type1, type2 = j1:getType(), j2:getType()
  local d = math.sqrt((x2-x1)^2 + (y2-y1)^2)

  if (ratio == 0 or ratio == math.huge) then
    love.graphics.setColor(vd.physics.colors.error)
    vdUtil.dottedLine(0, 5, 5, {x1, y1, x2, y2})
    love.graphics.setColor(vd.physics.colors.joint)
    return
  end

  --if (type1 == 'revolute' and type2 == 'revolute') then
  if (true) then  --TODO: rendering revolute-prismatic joints and prismatic-prismatic joints
    local a1 = type1 == 'revolute' and j1:getJointAngle() or j1:getJointTranslation()/94.25*math.pi
    local a2 = type2 == 'revolute' and j2:getJointAngle() or j2:getJointTranslation()/94.25*math.pi

    local r2 = d * math.abs(ratio)/(math.abs(ratio)+1)
    local r1 = d-r2

    if (ratio <= -1) then
      local ox, oy = (x2-x1)/d, (y2-y1)/d
      vdUtil.drawGear(x1, y1, (r1/2)-1.5, (r1/2)+1.5, a1, 6)
      vdUtil.drawGear(x2, y2, (r2/2)-1.5, (r2/2)+1.5, a2, math.abs(ratio * 6))
      vdUtil.dottedLine(a1*r1/2 + r1*math.pi/12, r1*math.pi/12, r1*math.pi/12, {x2+oy*(r2/2-1.5), y2-ox*(r2/2-1.5), x1+oy*(r1/2-1.5), y1-ox*(r1/2-1.5)})
      vdUtil.dottedLine(a1*r1/2 + r1*math.pi/12, r1*math.pi/12, r1*math.pi/12, {x1-oy*(r1/2-1.5), y1+ox*(r1/2-1.5), x2-oy*(r2/2-1.5), y2+ox*(r2/2-1.5)})
    elseif (ratio < 0) then
      local ox, oy = (x2-x1)/d, (y2-y1)/d
      vdUtil.drawGear(x1, y1, (r1/2)-1.5, (r1/2)+1.5, a1, math.abs(6/ratio))
      vdUtil.drawGear(x2, y2, (r2/2)-1.5, (r2/2)+1.5, a2, 6)
      vdUtil.dottedLine(a2*r2/2 + r2*math.pi/12, r2*math.pi/12, r2*math.pi/12, {x2+oy*(r2/2-1.5), y2-ox*(r2/2-1.5), x1+oy*(r1/2-1.5), y1-ox*(r1/2-1.5)})
      vdUtil.dottedLine(a2*r2/2 + r2*math.pi/12, r2*math.pi/12, r2*math.pi/12, {x1-oy*(r1/2-1.5), y1+ox*(r1/2-1.5), x2-oy*(r2/2-1.5), y2+ox*(r2/2-1.5)})
    elseif (ratio >= 1) then
      vdUtil.drawGear(x1, y1, r1-2.5, r1+2.5, a1, 12)
      vdUtil.drawGear(x2, y2, r2-2.5, r2+2.5, a2, ratio * 12)
    else
      vdUtil.drawGear(x1, y1, r1-2.5, r1+2.5, a1, 12 / ratio)
      vdUtil.drawGear(x2, y2, r2-2.5, r2+2.5, a2, 12)
    end
  end
end

vd.physics.drawJoint["motor"] = function(joint)
  vd.physics.drawJoint.revolute(joint)
end

vd.physics.drawJoint["mouse"] = function(joint)
  local x1, y1, x2, y2 = joint:getAnchors()

  love.graphics.line(
    x1, y1,
    x1+10, y1+10,
    x1+6, y1+12,
    x1+7, y1+14,
    x1+5, y1+15,
    x1+4, y1+13,
    x1, y1+15,
    x1, y1
  )

  vdUtil.dottedLine(0, 5, 10, {x1, y1, x2, y2})
end

vd.physics.drawJoint["prismatic"] = function(joint)
  local x1, y1, x2, y2 = joint:getAnchors()
  local b1, b2 = joint:getBodies()
  local b2x, b2y = b2:getPosition()
  local limMin, limMax = joint:getLimits()
  limMax = math.min(limMax, 3000)
  local t = joint:getJointTranslation()

  local dist = math.sqrt((x1-x2)^2 + (y1-y2)^2)
  local normx, normy = joint:getAxis()
  --if (t <= 0) then normx, normy = -normx, -normy end
  local angle = math.atan2(normy, normx)

  local r = 2.5
  local s = 10
  local xmin, ymin = x1 + normx * limMin, y1 + normy * limMin
  local xmine, ymine = xmin-normx*r, ymin-normy*r
  local xmax, ymax = x1 + normx * limMax, y1 + normy * limMax
  local xt, yt = x1 + normx * t, y1 + normy * t
  local tLo, tHi = math.max(t-s, limMin), math.min(t+s, limMax)
  local xtmin, ytmin, xtmax, ytmax = x1 + normx * tLo, y1 + normy * tLo, x1 + normx * tHi, y1 + normy * tHi

  local xminL, xminR, yminL, yminR = xmin - normy * r, xmin + normy * r, ymin + normx * r, ymin - normx * r
  local xmaxL, xmaxR, ymaxL, ymaxR = xmax - normy * r, xmax + normy * r, ymax + normx * r, ymax - normx * r

  love.graphics.line(xminL, yminL, xmaxL, ymaxL)
  love.graphics.line(xminR, yminR, xmaxR, ymaxR)
  love.graphics.arc('line', 'open', xmin, ymin, r, angle+math.pi-math.pi/2, angle+math.pi+math.pi/2)
  love.graphics.arc('line', 'open', xmax, ymax, r, angle-math.pi/2, angle+math.pi/2)
  love.graphics.circle('fill', xt, yt, r-1)
  love.graphics.line(b2x, b2y, xt, yt)
  love.graphics.line(xtmin, ytmin, xtmax, ytmax)
  if (limMin > r) then love.graphics.line(x1, y1, xmine, ymine) end
end

vd.physics.drawJoint["pulley"] = function(joint)
  local x1, y1, x2, y2 = joint:getAnchors()
  local gx1, gy1, gx2, gy2 = joint:getGroundAnchors()
  local l1, l2 = math.sqrt((gx1-x1)^2 + (gy1-y1)^2), math.sqrt((gx2-x2)^2 + (gy2-y2)^2)
  local ratio = joint:getRatio()
  local r1 = 1/(ratio+1)
  local r2 = 1-r1
  r1, r2 = r1*8*2, r2*8*2
  local gDist = math.sqrt((gx2-gx1)^2 + (gy2-gy1)^2)
  local gx,gy = (gx2-gx1)/gDist, (gy2-gy1)/gDist
  
  local px1, py1 = gx1+gx*8, gy1+gy*8
  local px2, py2 = gx2-gx*8, gy2-gy*8

  local function wheel(x, y, r, a)
    local sx, sy = math.cos(a), math.sin(a)
    local bx, by = math.cos(a+math.pi/4), math.sin(a+math.pi/4)
    local inR = math.min(8, r)

    love.graphics.circle('line', x, y, r)
    love.graphics.circle('line', x, y, 8)
    love.graphics.line(x+sx*8, y+sy*8, x+sx*r, y+sy*r)
    love.graphics.line(x+sy*8, y-sx*8, x+sy*r, y-sx*r)
    love.graphics.line(x-sx*8, y-sy*8, x-sx*r, y-sy*r)
    love.graphics.line(x-sy*8, y+sx*8, x-sy*r, y+sx*r)
    love.graphics.line(x-bx*inR, y-by*inR, x+bx*inR, y+by*inR)
  end

  wheel(px1, py1, r1, -l1 / 8)
  wheel(px2, py2, r2, l2 / 8)
  vdUtil.dottedLine(0, 6, 2, {x1, y1, gx1, gy1})
  vdUtil.dottedLine(0, 6, 2, {x2, y2, gx2, gy2})
  vdUtil.dottedLine(l1 * r1/8, 6, 2, {px1+gy*r1, py1-gx*r1, px2+gy*r2, py2-gx*r2})
  if (ratio ~= 1) then vdUtil.dottedLine(l1 * r1/8, 6, 2, {px2-gy*r2, py2+gx*r2, px1-gy*r1, py1+gx*r1}) end
  
end

vd.physics.drawJoint["revolute"] = function(joint)
  local x1, y1 = joint:getAnchors()
  local b1, b2 = joint:getBodies()
  local angle = joint:getJointAngle() + b1:getAngle()
  local dx, dy = math.cos(angle), math.sin(angle)
  local bx, by = math.cos(b1:getAngle()), math.sin(b1:getAngle())

  love.graphics.circle('fill', x1, y1, 2)
  love.graphics.line(x1, y1, x1+dx*5, y1+dy*5)
  love.graphics.line(x1+bx*5, y1+by*5, x1+bx*7.5, y1+by*7.5)
  if joint:hasLimitsEnabled() then
    love.graphics.arc('line', x1, y1, 5, joint:getLowerLimit() + b1:getAngle(), joint:getUpperLimit() + b1:getAngle())
  else
    love.graphics.circle('line', x1, y1, 5)
  end
end

vd.physics.drawJoint["rope"] = function(joint)
  local x1, y1, x2, y2 = joint:getAnchors()

  local d = math.sqrt((x2-x1)^2 + (y2-y1)^2)
  local l = joint.getMaxLength and joint:getMaxLength() or d

  if d >= l then
    love.graphics.line(x1, y1, x2, y2)
  else
    local r = math.sqrt(l*l-d*d)/2/math.pi
    local normx, normy = (x2-x1)/d, (y2-y1)/d
    local line = {}

    for i = 0, 1, 1/16 do
      table.insert(line, x1 + normx * i * d - normy * math.sin(i * math.pi * 2) * r)
      table.insert(line, y1 + normy * i * d + normx * math.sin(i * math.pi * 2) * r)
    end

    love.graphics.line(line)
  end
end

vd.physics.drawJoint["weld"] = function(joint)
  local x1, y1, x2, y2 = joint:getAnchors()
  local b1, b2 = joint:getBodies()
  local angle = b1:getAngle() + math.pi/4

  local normx, normy = 5*math.cos(angle), 5*math.sin(angle)

  love.graphics.line(
    x1+normx, y1+normy,
    x1-normy, y1+normx,
    x1-normx, y1-normy,
    x1+normy, y1-normx,
    x1+normx, y1+normy
  )
  love.graphics.line(x1+normx, y1+normy, x1-normx, y1-normy)
  love.graphics.line(x1-normy, y1+normx, x1+normy, y1-normx)
end

vd.physics.drawJoint["wheel"] = function(joint)

end

return vd.physics