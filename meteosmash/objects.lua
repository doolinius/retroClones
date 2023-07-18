-- Intellivision color palette

Color = {
  black = {0, 0, 0, 1},
  blue = {20/255, 56/255, 247/255, 1},
  red = {227/255, 19/255, 14/255, 1},
  tan = {203/255, 241/255, 104/255, 1},

  dark_green = {0, 148/255, 40/255, 1},
  green = {7/255, 194/255, 0, 1},
  yellow = {1, 1, 1/255, 1},
  white = {1, 1, 1, 1},

  gray = {200/255, 200/255, 200/255, 1},
  cyan = {35/255, 206/255, 195/255, 1},
  orange = {253/255, 153/255, 24/255, 1},
  brown = {58/255, 91/255, 2/255, 1},

  pink = {240/255, 70/255, 60/255, 1},
  violet = {211/255, 131/255, 1, 1},
  bright_green = {72/255, 246/255, 1/255, 1},
  magenta = {184/255, 17/255, 120/255, 1}
}

explode = love.audio.newSource("explosion2.wav", "static")
rockBreak = love.audio.newSource("rockBreak.wav", "static")

function colFilter(item, other)
  if item.type == "Bullet" then
    if other.type == "Cannon" or other.type == "Explosion" then
      return("cross")
    else
      return("slide")
    end
  else
    return("cross")
  end
end

function random_color()
    local keys = {}
    for k in pairs(Color) do
      if k ~= "black" then
        table.insert(keys, k)
      end
    end
    return Color[keys[math.random(#keys)]]
end

BigMeteorSheet = love.graphics.newImage("big_meteors.png")
BigMeteorSheet:setFilter("nearest", "nearest")
BigMeteors = {
  love.graphics.newQuad(0, 0, 16, 16, 16*3, 16),
  love.graphics.newQuad(16, 0, 16, 16, 16*3, 16),
  love.graphics.newQuad(32, 0, 16, 16, 16*3, 16)
}

SmallMeteorSheet = love.graphics.newImage("small_meteors.png")
SmallMeteorSheet:setFilter("nearest", "nearest")
SmallMeteors = {
  love.graphics.newQuad(0, 0, 8, 8, 8*3, 8),
  love.graphics.newQuad(8, 0, 8, 8, 8*3, 8),
  love.graphics.newQuad(16, 0, 8, 8, 8*3, 8)
}

Meteor = {}
Meteor.__index = Meteor

function Meteor:Create(gameLevel, type)
  local this = {
    x = math.random(0,640 - 16*4),
    y = -16*4,
    color = random_color(),
    x_velocity = math.random(0,15*gameLevel), -- needs to be based on gameLevel
    y_velocity = math.random(40, 80 + (20 * gameLevel)),
    dead = false
  }
  if math.random() < 0.5 then
    this.x_velocity = -this.x_velocity
  end

  if type == "SmallMeteor" or (math.random() < 0.4) then
    this.type = "SmallMeteor"
    this.image = SmallMeteorSheet
    this.quad = SmallMeteors[math.random(#SmallMeteors)]
    this.score = 20
    this.colBox = {
      x = 0,
      y = 0,
      w = 10*4,
      h = 10*4
    }
  else
    this.type = "BigMeteor"
    this.image = BigMeteorSheet
    this.quad = BigMeteors[math.random(#BigMeteors)]
    this.score = 10
    this.colBox = {
      x = 0,
      y = 0,
      w = 16*4,
      h = 16*4
    }
  end

  setmetatable(this, self)
  return(this)
end

function Meteor:update(dt)
  local x = self.x + self.x_velocity * dt
  local y = self.y + self.y_velocity * dt
  local actualX, actualY, cols, len = world:move(self, x, y, colFilter)
  self.x = actualX
  self.y = actualY
  if self.x < -self.colBox.w or self.x > 160*4 then
    self.dead = true
  else
    if len > 0 then
      for i=1, len do
        if cols[i].other == ground then
          self.dead = true
          score = score - self.score
        elseif cols[i].other.type == "Bullet" then
          self.dead = true
          cols[i].other.dead = true
          if self.type == "SmallMeteor" then
            explode:play()
          else
            rockBreak:play()
          end
          updateScore(self.score)
        end
      end
    end
  end
end

function Meteor:draw()
  love.graphics.push("all")
    love.graphics.setColor(unpack(self.color))
    love.graphics.draw(self.image, self.quad, self.x, self.y, 0, 4, 3)
  love.graphics.pop()
end

function Meteor:isDead()
  return self.dead
end

Bomb = {}
Bomb.__index = Bomb

function Bomb:Create(gameLevel)
  local this = {
    x = math.random(0, 640),
    y = -16,
    x_velocity = 0,
    y_velocity = math.random(10, gameLevel * 100),
    dead = false
  }

  if (math.random() < 0.6) then
    this.type = "SmallBomb"
    this.image = love.graphics.newImage("small_bomb.png")
    local g = anim8.newGrid(10, 10, this.image:getDimensions())
    this.animation = anim8.newAnimation(g('1-4', 1), 0.2)
    this.score = 80
    this.colBox = {
      x = 2*4,
      y = 2*4,
      w = 6*4,
      h = 6*4
    }
  else
    this.type = "BigBomb"
    this.image = love.graphics.newImage("big_bomb.png")
    local g = anim8.newGrid(16, 16, this.image:getDimensions())
    this.animation = anim8.newAnimation(g('1-4', 1), 0.2)
    this.score = 40
    this.colBox = {
      x = 4*4,
      y = 4*4,
      w = 7*4,
      h = 7*4
    }
  end

  setmetatable(this, self)
  return(this)
end

function Bomb:update(dt)
  self.animation:update(dt)
  local x = self.x + self.x_velocity * dt
  local y = self.y + self.y_velocity * dt
  local actualX, actualY, cols, len = world:move(self, x, y, colFilter)
  self.x = actualX
  self.y = actualY
  if self.x > 160*4 or self.x < -self.colBox.w then
    self.dead = true
  else
    if len > 0 then
      for i=1, len do
        if cols[i].other == ground then
          self.dead = true
        elseif cols[i].other.type == "Bullet" then
          cols[i].other.dead = true
          explode:play()
          self.dead = true
          updateScore(self.score)
        end
      end
    end
  end
end

function Bomb:draw()
  self.animation:draw(self.image, self.x, self.y, 0, 4, 4)
end

function Bomb:isDead()
  return self.dead
end

Seeker = {}
Seeker.__index = Seeker

function Seeker:Create(cannon)
  local this = {
    type = "Seeker",
    x = math.random(160),
    y = -16,
    image = love.graphics.newImage("seeker.png"),
    sound = love.audio.newSource("seeker.wav", "static"),
    soundInterval = 0.75,
    soundTimer = 0,
    x_velocity = 0,
    y_velocity = 175,
    score = 50,
    dead = false,
    cannon = cannon -- needed for tracking
  }
  local g = anim8.newGrid(7, 7, this.image:getDimensions())
  this.animation = anim8.newAnimation(g('1-2', 1), 0.35)
  this.sound:setPitch(1)
  this.sound:setVolume(0.6)

  this.colBox = {
    x = 0,
    y = 0,
    w = 7*4,
    h = 7*4
  }

  setmetatable(this, self)
  return(this)
end

function Seeker:update(dt)
  self.soundTimer = self.soundTimer - dt
  if self.soundTimer <= 0 then
    self.soundTimer = self.soundInterval
    self.sound:play()
  end
  self.animation:update(dt)
  if self.cannon.x < self.x then
    self.x_velocity = -120
  elseif self.cannon.x > self.x then
    self.x_velocity = 120
  else
    self.x_velocity = 0
  end
  local x = self.x + self.x_velocity * dt
  local y = self.y + self.y_velocity * dt
  local actualX, actualY, cols, len = world:move(self, x, y, colFilter)
  self.x = actualX
  self.y = actualY
  if self.x > 160*4 or self.x < -self.colBox.w then
    self.dead = true
  else
    if len > 0 then
      for i=1, len do
        if cols[i].other == ground then
          if math.random() < (0.9 * level) then
            self.y_velocity = 0
          else
            self.dead = true
          end
        elseif cols[i].other.type == "Bullet" then
          self.dead = true
          cols[i].other.dead = true
          explode:play()
          updateScore(self.score)
        end
      end
    end
  end
end

function Seeker:draw()
  self.animation:draw(self.image, self.x, self.y, 0, 4, 4)
end

function Seeker:isDead()
  return self.dead
end

Explosion = {}
Explosion.__index = Explosion

function Explosion:Create(x, y)
  local this = {
    type = "Explosion",
    x = x,
    y = y,
    image = love.graphics.newImage("explosion.png"),
    animation = nil,
    colBox = {
      x = 3*4,
      y = 3*4,
      w = 5*4,
      h = 5*4
    },
  }
  local g = anim8.newGrid(11, 11, this.image:getDimensions())
  this.animation = anim8.newAnimation(g('1-5', 1), 0.15, 'pauseAtEnd')

  setmetatable(this, self)
  return(this)
end

function Explosion:update(dt)
  self.animation:update(dt)
end

function Explosion:draw()
  self.animation:draw(self.image, self.x, self.y, 0, 4, 4)
end

function Explosion:isDead()
  return self.animation.status == "paused"
end

Bullet = {}
Bullet.__index = Bullet

function Bullet:Create(cannon)
  local this = {
    type = "Bullet",
    x = cannon.x + 12,
    y = cannon.y + 4,
    speed = -420,
    colBox = {
      x = 0,
      y = 2,
      w = 6,
      h = 14
    },
    dead = false
  }

  setmetatable(this, self)
  return(this)
end

function Bullet:update(dt)
  local y = self.y + self.speed * dt
  local actualX, actualY, cols, len = world:move(self, self.x, y, colFilter)
  self.x = actualX
  self.y = actualY
end

function Bullet:draw()
  love.graphics.rectangle("fill", self.x, self.y, 6, 16)
end

function Bullet:isDead()
  return self.dead or (self.y <= -self.colBox.h)
end

Cannon = {}
Cannon.__index = Cannon

function Cannon:Create()
  local this = {
    type = "Cannon",
    x = 320 - 4,
    y = 94 * 4,
    speed = 220,
    image = love.graphics.newImage("cannon.png"),
    normal = love.graphics.newQuad(0, 0, 7, 10, 14, 10),
    firing = love.graphics.newQuad(7, 0, 7, 10, 14, 10),
    fireDelay = 0.35,
    fireCount = 0,
    colBox = {
      x = 1*4,
      y = 1*4,
      w = 5*4,
      h = 7*4
    },
    sound = love.audio.newSource("cannon.wav", "static"),
    shotsFired = 0
  }

  setmetatable(this, self)
  return(this)
end

function Cannon:update(dt)
  if self.fireCount > 0 then
    self.fireCount = self.fireCount - dt
  elseif self.fireCount < 0 then
    self.fireCount = 0
  end
  self:handleInput(dt)
end

function Cannon:draw()
  love.graphics.draw(self.image, self.normal, self.x, self.y, 0, 4, 4)
end

function Cannon:fireBullet()
  local b = nil
  if self.fireCount == 0 then
    b = Bullet:Create(self)
    self.fireCount = self.fireDelay
    self.shotsFired = self.shotsFired + 1
    self.sound:play()
  end
  return b
end

function Cannon:handleInput(dt)
  if love.keyboard.isDown('a') then
    self.x = math.max(2, self.x - self.speed * dt)
  elseif love.keyboard.isDown('d') then
    self.x = math.min(self.x + self.speed * dt, 640-30)
  end

end
