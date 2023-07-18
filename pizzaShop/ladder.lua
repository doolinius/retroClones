Ladder = {}
Ladder.__index = Ladder

function Ladder:Create(x, y, height)
  local this = {
    x = x,
    y = y,
    width = 15,
    height = height
  }

  setmetatable(this, self)
  return(this)
end

function Ladder:update(dt) end

function Ladder:draw()
  for i=self.y, self.height, 6 do
    love.graphics.line(self.x, i, self.x+self.width, i)
  end
end
