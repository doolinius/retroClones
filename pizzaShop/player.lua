Player = {}
Player.__index = Player

function Player:Create()
  local this = {
    image = love.graphics.newImage("sprites2.png"),
    x = 0,
    y = 0,
    animations = {},
    facing = "right",
    topSpeed = 32,
    xSpeed = 0,
    ySpeed = 0
  }
  local duration = 0.2
  local grid = anim8.newGrid(16, 16, this.image:getDimensions())
  this.animations["down"] = anim8.newAnimation(grid('1-3',1,2,1), duration)
  this.animations["left"] = anim8.newAnimation(grid('1-3',2,2,2), duration)
  this.animations["right"] = anim8.newAnimation(grid('1-3',3,2,3), duration)
  this.animations["up"] = anim8.newAnimation(grid('1-3',4,2,4), duration)

  this.animation = this.animations[this.facing]

  setmetatable(this, self)
  return(this)
end

function Player:setDirection(dir)
  if dir ~= self.facing then
    self.facing = dir
    self.animation = self.animations[self.facing]
  end
end

function Player:update(dt)
  if input:down('left') then
    self:setDirection('left')
    self.xSpeed = -self.topSpeed
    self.ySpeed = 0
    self.animation:update(dt)
  elseif input:down('right') then
    self:setDirection('right')
    self.xSpeed = self.topSpeed
    self.ySpeed = 0
    self.animation:update(dt)
  elseif input:down('down') then
    self:setDirection('down')
    self.xSpeed = 0
    self.ySpeed = self.topSpeed - 8
    self.animation:update(dt)
  elseif input:down('up') then
    self:setDirection('up')
    self.xSpeed = 0
    self.ySpeed = -self.topSpeed + 8
    self.animation:update(dt)
  else
    self.xSpeed = 0
    self.ySpeed = 0
  end
  local newX = self.x + self.xSpeed * dt
  local newY = self.y + self.ySpeed * dt
  local actualX, actualY, cols, len = world:move(self, newX, newY)
  self.x = actualX
  self.y = actualY
end

function Player:draw()
  self.animation:draw(self.image, self.x, self.y)
end

function Player:handleInput()


end
