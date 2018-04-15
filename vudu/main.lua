vudu = require "init"

function love.load()
  love.graphics.setBackgroundColor(0,0,3/16)
  testable = {one = 'yup', two = type, 20, 21, 135, "hello", love, 20, 20, 13, type, {vd_expand = true, hello = 'world', world = 'burning', 2, 4, 6, 8, 10, 22}, 0, 13}, 20, 20
  
  t = 0
  
  vudu.initialize()
end

function love.update(dt)
  t = t + dt
end

function love.draw()
  love.graphics.translate(400, 300)
  love.graphics.setColor(0, 1/2, 0)
  love.graphics.circle("fill", 40 * math.sin(t), 40 * math.cos(t), 20)
end

