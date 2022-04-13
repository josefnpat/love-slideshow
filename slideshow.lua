local slideshow = {}

function slideshow.new(init)
  init = init or {}
  local self = {}

  self.update = slideshow.update
  self.draw = slideshow.draw
  self.drawSlide = slideshow.drawSlide
  self.next = slideshow.next

  self._getValidMedia = slideshow._getValidMedia

  self._slide_dir = init.slide_dir or "slides"
  self._slide_time = init.slide_time or 10
  self._slide_transition_time = init.slide_transition_time or 1
  self._slide_time_dt = 0

  self:next()self:next()

  return self
end

function slideshow:update(dt)
  if self._current_slide:type() == "Image" then
    self._slide_time_dt = self._slide_time_dt + dt
    if self._slide_time_dt >= self._slide_time then
      self:next()
    end
  elseif self._current_slide:type() == "Video" then
    if not self._current_slide:isPlaying() then
      self:next()
    end
  end
end

function slideshow:_getValidMedia()
  local files = love.filesystem.getDirectoryItems(self._slide_dir)
  local media = {}
  for _,v in pairs(files) do
    local path,file,extension = string.match(v,"(.-)([^\\]-([^\\%.]+))$")
    local ext = string.lower(extension)
    local fileinfo = {name = v, ext = ext}
    if ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "ogv" or ext == "ogg" then
      table.insert(media,fileinfo)
    end
  end
  return media
end


function slideshow:next()
  self._slide_time_dt = 0
  local files = self:_getValidMedia()
  local file = files[math.random(#files)]

  if #files > 1 and self._current_slide_file then
    while file == self._current_slide_file do
      file = files[math.random(#files)]
    end
  end

  self._last_slide_file = self._current_slide_file
  self._last_slide = self._current_slide

  self._current_slide_file = file
  if (file.ext == "png" or file.ext == "jpg" or file.ext == "jpeg") then
    self._current_slide = love.graphics.newImage(self._slide_dir.."/"..file.name)
  elseif (file.ext == "ogv" or file.ext == "ogg") then
    self._current_slide = love.graphics.newVideo(self._slide_dir.."/"..file.name)
    self._current_slide:rewind()
    self._current_slide:play()
  end
end

function slideshow:draw()
  local time_into_alpha = math.max(0,self._slide_time_dt-self._slide_time+self._slide_transition_time)
  local alpha = time_into_alpha/self._slide_transition_time
  if self._last_slide then
    love.graphics.setColor(1,1,1,1*(1-alpha))
  end
  if self._current_slide then
    love.graphics.setColor(1,1,1,1)
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
