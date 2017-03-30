io.stdout:setvbuf("no")

local ls = require("slideshow").new{}

function love.update(dt)
  ls:update(dt)
end

function love.draw()
  ls:draw()
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
