local slideshow = {}

function slideshow.new(init)
  init = init or {}
  local self = {}

  self.update = slideshow.update
  self.draw = slideshow.draw
  self.drawSlide = slideshow.drawSlide
  self.next = slideshow.next

  self._getValidImages = slideshow._getValidImages

  self._slide_dir = init.slide_dir or "slides"
  self._slide_time = init.slide_time or 10
  self._slide_transition_time = init.slide_transition_time or 1
  self._slide_time_dt = 0

  self:next()self:next()

  return self
end

function slideshow:update(dt)
  self._slide_time_dt = self._slide_time_dt + dt
  if self._slide_time_dt >= self._slide_time then
    self:next()
  end
end

function slideshow:_getValidImages()
  local files = love.filesystem.getDirectoryItems(self._slide_dir)
  local images = {}
  for _,v in pairs(files) do
    local path,file,extension = string.match(v,"(.-)([^\\]-([^\\%.]+))$")
    local ext = string.lower(extension)
    if ext == "png" or ext == "jpg" or ext == "jpeg" then
      table.insert(images,v)
    end
  end
  return images
end

function slideshow:next()
  self._slide_time_dt = 0
  local files = self:_getValidImages()
  local file = files[math.random(#files)]

  if #files > 1 and self._current_slide_file then
    while file == self._current_slide_file do
      file = files[math.random(#files)]
    end
  end

  self._last_slide_file = self._current_slide_file
  self._last_slide = self._current_slide

  self._current_slide_file = file
  self._current_slide = love.graphics.newImage(self._slide_dir.."/"..file)
end

function slideshow:draw()
  local time_into_alpha = math.max(0,self._slide_time_dt-self._slide_time+self._slide_transition_time)
  local alpha = time_into_alpha/self._slide_transition_time
  if self._last_slide then
    love.graphics.setColor(255,255,255,255*(1-alpha))
    self:drawSlide(self._last_slide)
  end
  if self._current_slide then
    love.graphics.setColor(255,255,255,255*alpha)
    self:drawSlide(self._current_slide)
  else
    love.graphics.printf(
      "There are no images in the `"..self._slide_dir.."` folder.",
      0,love.graphics.getHeight()/2,
      love.graphics.getWidth(),"center")
  end
end

function slideshow:drawSlide(slide)
  local sx = love.graphics.getWidth()/slide:getWidth()
  local sy = love.graphics.getHeight()/slide:getHeight()
  local s = math.min(sx,sy)
  local ox,oy = 0,0
  if sy < sx then
    ox = (love.graphics.getWidth()-slide:getWidth()*s)/2
  elseif sx < sy then
    oy = (love.graphics.getHeight()-slide:getHeight()*s)/2
  end
  love.graphics.draw(slide,ox,oy,0,s,s)
end

return slideshow
