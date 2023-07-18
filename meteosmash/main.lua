
function love.load()
	M = require 'posix.signal'
  math.randomseed( os.time() )
  require('objects')
  love.window.setMode(640, 480)
  love.window.setTitle("MeteoSmash")
  love.graphics.setDefaultFilter("nearest", "nearest")
  intFont = love.graphics.newFont("intellec.ttf", 40)

  particle = love.graphics.newImage("particle.png")

  bgImage = love.graphics.newImage("background-sheet.png")
  backgrounds = {
    love.graphics.newQuad(0, 0, 160, 120, bgImage:getDimensions()),
    love.graphics.newQuad(160, 0, 160, 120, bgImage:getDimensions()),
    love.graphics.newQuad(320, 0, 160, 120, bgImage:getDimensions()),
    love.graphics.newQuad(480, 0, 160, 120, bgImage:getDimensions()),
    love.graphics.newQuad(640, 0, 160, 120, bgImage:getDimensions()),
    love.graphics.newQuad(0, 0, 160, 120, bgImage:getDimensions()),
  }
  love.graphics.setBackgroundColor(unpack(Color.brown))
  love.graphics.setFont(intFont)
  bgSound = love.audio.newSource("bg_sound.wav", "static")
  bgSound:setPitch(2)

  anim8 = require('anim8/anim8')
  bump = require('bump')
  world = bump.newWorld()
  ground = {x=0, y=108*4, w=160*4, h=50*4}
  world:add(ground, ground.x, ground.y, ground.w, ground.h)

  cannon = Cannon:Create()

  -- add cannon to world

  bullets = {}
  targets = {}

  score = 800
  highScore = 800
  lives = 3
  EXTRA_LIFE = 1000

  LEVEL2 = 1000
  LEVEL3 = 5000
  LEVEL4 = 20000
  LEVEL5 = 50000
  LEVEL6 = 100000
  level = 1

  soundInterval = 0.5 + 0.5 / level
  soundTimer = soundInterval

  targetInterval = 0.4
  targetTimer = targetInterval

  state = 'title'
end

function setLevel(score)
  if (score < LEVEL2) then
    level = 1
  elseif (score < LEVEL3) then
    level = 2;
  elseif (score < LEVEL4) then
    level = 3;
  elseif (score < LEVEL5) then
    level = 4;
  elseif (score < LEVEL6) then
    level = 5;
  else
    level = 6;
  end
end

function updateScore(change)
  score = score + (change * level);
  if (score > highScore) then
    old_high = highScore
    highScore = score
    if (math.floor(highScore / EXTRA_LIFE) > math.floor(old_high / EXTRA_LIFE)) then
      lives = lives + 1
    end
  end
  setLevel(score);
end

function createTarget(gLevel)
  local roll = math.random(1, 100)
  if roll < 75 then
    return Meteor:Create(gLevel)
  elseif roll < 97 then
    return Bomb:Create(gLevel)
  else
    return Seeker:Create(cannon)
  end
end

function removeBullet(b)
  world:remove(b)
  for i=1, #bullets do
    if bullets[i] == b then
      table.remove(bullets, i)
    end
  end
end

function removeTarget(t)
  world:remove(t)
  for i=1, #targets do
    if targets[i] == t then
      table.remove(targets, i)
      if t.type == "BigMeteor" then
        local lm1 = Meteor:Create(level, "SmallMeteor")
        lm1.color = t.color
        lm1.x = t.x + 8
        lm1.y = t.y + 8
        lm1.x_velocity = -40
        local lm2 = Meteor:Create(level, "SmallMeteor")
        lm2.color = t.color
        lm2.x = t.x + 16
        lm2.y = t.y + 8
        lm2.x_velocity = 40
        table.insert(targets, lm1)
        table.insert(targets, lm2)
        world:add(lm1, lm1.x + lm1.colBox.x, lm1.y + lm1.colBox.y, lm1.colBox.w, lm1.colBox.h)
        world:add(lm2, lm2.x + lm2.colBox.x, lm2.y + lm2.colBox.y, lm2.colBox.w, lm2.colBox.h)
      elseif (t.type ~= "Explosion") then
        local e = Explosion:Create(t.x, t.y)
        table.insert(targets, e)
        world:add(e, e.x + e.colBox.x, e.y + e.colBox.y, e.colBox.w, e.colBox.h)
      end
    end
  end
end

function clearStage()
  targets = {}
  bullets = {}
end

function die()
  
end

function love.update(dt)
  if state == 'game' then
    soundTimer = soundTimer - dt
    targetTimer = targetTimer - dt
    if soundTimer <= 0 then
      bgSound:play()
      soundTimer = soundInterval
    end

    if targetTimer <= 0 and math.random() < (0.02 * level) then
      targetTimer = targetInterval
      if #targets < 8 then
        local t = createTarget(level)
        world:add(t, t.x + t.colBox.x, t.y + t.colBox.y, t.colBox.w, t.colBox.h)
        table.insert(targets, t)
      end
    end

    cannon:update(dt)

    for _, t in ipairs(targets) do
      if t:isDead() then
        removeTarget(t)
      else
        t:update(dt)
      end
    end

    for _, b in ipairs(bullets) do
      if b:isDead() then
        removeBullet(b)
      else
        b:update(dt)
      end
    end
  end
end

function drawTitleScreen()
  x = 60
  love.graphics.setColor(unpack(Color.white))
  love.graphics.rectangle("fill", x, 50, 15, 30)
  x = x + 64


  love.graphics.setColor(unpack(Color.yellow))
  love.graphics.rectangle("fill", x, 50, 15, 30)
  x = x + 64


  love.graphics.setColor(unpack(Color.green))
  love.graphics.rectangle("fill", x, 50, 15, 30)
  x = x + 64


  love.graphics.setColor(unpack(Color.dark_green))
  love.graphics.rectangle("fill", x, 50, 15, 30)
  x = x + 64
  x = x + 64

  love.graphics.setColor(unpack(Color.tan))
  love.graphics.rectangle("fill", x, 50, 15, 30)
  x = x + 64

  love.graphics.setColor(unpack(Color.red))
  love.graphics.rectangle("fill", x, 50, 15, 30)
  x = x + 64


  love.graphics.setColor(unpack(Color.blue))
  love.graphics.rectangle("fill", x, 50, 15, 30)
  x = x + 64


  love.graphics.setColor(unpack(Color.black))
  love.graphics.rectangle("fill", x, 50, 15, 30)
  x = x + 64

  love.graphics.setColor(1, 1, 1, 1)


  love.graphics.printf("Doolin Digital", 0, 110, 640, "center")

  love.graphics.printf("presents", 0, 150, 640, "center")
  love.graphics.printf("MeteoSmash", 0, 230, 640, "center")

  love.graphics.printf("Copr @ 1983", 0, 320, 640, "center")
  love.graphics.printf("Doolin Digital LLC", 0, 370, 640, "center")
end

function love.draw()
  if state == 'title' then
    drawTitleScreen()
  elseif state == 'game' then
    love.graphics.draw(bgImage, backgrounds[level], 0, 0, 0, 4, 4)
    cannon:draw()
    love.graphics.printf(score, 0, 432, 310, "right")
    love.graphics.draw(cannon.image, cannon.normal, 340, 432, 0, 4, 4)

    for _, t in ipairs(targets) do
      t:draw()
    end

    for _, b in ipairs(bullets) do
      b:draw()
    end

    love.graphics.printf(lives, 380, 432, 80, "left")
    love.graphics.printf("Lvl " .. level, 460, 432, 180, "right")
  end
end

function love.keypressed(key)
  if state == 'title' then
    if key == 'space' then
      state = 'game'
    end
  elseif state == 'game' then
    if key == 'space' then
      local b = cannon:fireBullet()
      if b then
        world:add(b, b.x + b.colBox.x, b.y + b.colBox.y, b.colBox.w, b.colBox.h)
        table.insert(bullets, b)
      end
    end
  end
end
