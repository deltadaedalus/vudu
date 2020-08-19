local vd = require(_vdreq .. "vudu")
local vdUtil = require(_vdreq .. "vuduutil")
local vdui = require(_vdreq .. "vuduui")

local vdwin = {}
vdwin.__index = vdwin

function vdwin.new(t, settings)
  settings = settings or {}
  
  local self = setmetatable(t, vdwin)
  self.x = settings.x or 0
  self.y = settings.y or 0
  self.w = settings.w or 20
  self.h = settings.h or 20
  self.minimizeType = settings.minimizeType or 'top'
  self.hasFrame = settings.hasFrame
  self.runHidden = settings.runHidden
  
  if (self.hasFrame) then
    self.frame = vdui.widget.frame.new(self.x, self.y, self.w, self.h, 6)
    self.frame.idleColor = vd.colors.window
  end
  
  return self
end

function vdwin:addTopWidget()
  local frame = vdui.widget.frame.new(0, 0, self.w, 12, 6, {onResize = function(self) self.w = self.parent.w end})
  frame.idleColor = vd.colors.highlight
  self.frame:addWidget(frame)
  local minimizer = vdui.widget.new(0, 0, 12, 12, 6, {
    onRelease = function(self)
      self.target.frame.h, self.savedH = self.savedH, self.target.frame.h 
      if self.target.minimizeType == 'bottom' then
        self.target.frame.y = self.target.frame.parent.h - self.target.frame.h - 2
      end
    end
  })
  minimizer.target = self
  minimizer.savedH = 12
  frame:addWidget(minimizer)
end

function vdwin:setCallback(index, func)
  self[index] = func
end

function vdwin:load() end
function vdwin:update(dt) end
function vdwin:draw() end
function vdwin:mousepressed(x, y, button, isTouch) end
function vdwin:mousereleased(x, y, button, isTouch) end
function vdwin:keypressed(key, scancode, isrepeat) end
function vdwin:keyreleased(key, scancode, isrepeat) end
function vdwin:wheelmoved(x, y)  end
function vdwin:textinput(text) end


return vdwin