local vd = require(_vdpath .. "vudu")
local vdui = require(_vdpath .. "vuduUI")
local vdw = vdui.widget
local vdUtil = require(_vdpath .. "vuduUtil")

vdw.slider = setmetatable({
    slideColor_pre11 = {128, 128, 128},
    slideColor = {1/2, 1/2, 1/2}
}, vdw)
vdw.slider.__index = vdw.slider

function vdw.slider.new(x, y, w, h, r, settings)
    local self = setmetatable(vdw.new(x, y, w, h, r, settings), vdw.slider)
    self.targetRef = settings.targetRef
    self.max = settings.max or 1
    self.min = settings.min or 0
    self.targetValue = settings.targetValue or 0
    self.residual = settings.residual or 0;


    self.startPoint = settings.startPoint or {x = x, y = y}
    self.endPoint = settings.endPoint or {x = x+w, y = y+h}
    self.currentValue = self.targetRef and vudu.getByName(self.targetRef) or self.targetValue;
    self.moving = false;

    return self
end

function vdw.slider:onPress(x, y, button, isTouch)

end

function vdw.slider:whileHeld(x, y, dt)
    local dx, dy = x-self.startPoint.x, y-self.startPoint.y
    local sx, sy = self.endPoint.x - self.startPoint.x, self.endPoint.y - self.startPoint.y
    local t = math.min(math.max(vdUtil.projectScale(dx, dy, sx, sy), 0), 1)

    self.targetValue = self.min + t*(self.max-self.min)
end

function vdw.slider:onRelease(x, y, button, isTouch)

end

function vdw.slider:update(dt)
    local wasMoving = self.moving
    self.moving = math.abs((self.currentValue-self.targetValue) / (self.max-self.min)) > .001 or self.ui.heldWidget == self
    if wasMoving and not self.moving then
        self.currentValue = self.targetValue
    end

    if self.moving then --if currently moving, enforce will upon targetRef
        self.currentValue = self.currentValue * self.residual^dt + self.targetValue * (1-self.residual^dt)
        if self.targetRef then vd.setByName(self.targetRef, self.currentValue) end
    else
        if self.targetRef then self.currentValue = vd.getByName(self.targetRef) end
    end
end

function vdw.slider:draw()
    love.graphics.setColor(self.slideColor)
    vdUtil.roundLine(self.r*2, self.startPoint.x, self.startPoint.y, self.endPoint.x, self.endPoint.y)
    local sx, sy = self.endPoint.x - self.startPoint.x, self.endPoint.y - self.startPoint.y
    local along = (self.currentValue - self.min) / (self.max-self.min)
    love.graphics.setColor(self:getColor())
    love.graphics.circle("fill", self.startPoint.x + sx*along, self.startPoint.y + sy*along, self.r)
end

function vdw.slider:checkContains(x, y)
    local sx, sy = self.endPoint.x - self.startPoint.x, self.endPoint.y - self.startPoint.y
    local along = (self.currentValue - self.min) / (self.max-self.min)
    local px, py = self.startPoint.x + sx*along, self.startPoint.y + sy*along

    return vdUtil.sqDist(x, y, px, py) < self.r * self.r
end

function vdw.slider:gotoValue(value)
    self.targetValue = value
    self.moving = true
end