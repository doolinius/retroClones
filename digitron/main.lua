function colfilter(item, other)
  return("slide")
end

function love.load()
  lg = love.graphics
  lk = love.keyboard
  love.window.setTitle("Doolin Digitron")
  love.window.setMode(640, 480)

  blip = love.audio.newSource("blip.wav", "static")

  bump = require("bump")
  world = bump.newWorld()

  moonshine = require("moonshine")
  effect = moonshine(moonshine.effects.crt)
              .chain(moonshine.effects.scanlines)
              .chain(moonshine.effects.chromasep)
  effect.crt.distortionFactor = {1.02, 1.02}
  effect.scanlines.width = 1
  effect.scanlines.thickness = 0.5
  effect.chromasep.angle = 0.5
  effect.chromasep.radius = 2.01

  bigFont = lg.newFont('arcade.ttf', 48)
  smallFont = lg.newFont('arcade.ttf', 24)
  lg.setFont(bigFont)

  paddle1 = {
    x = 30,
    y = 50,
    w = 20,
    h = 60,
    speed = 6
  }

  paddle2 = {
    x = 640 - 20 - 30,
    y = 50,
    w = 20,
    h = 60,
    speed = 6
  }

  ball = {
    x = paddle1.x + math.floor(paddle1.h / 2),
    y = paddle1.y + paddle1.w + 5,
    w = 8,
    h = 8,
    speed = 4,
    ySpeed = 0
  }

  topWall = {
    x = 0,
    y = 0,
    w = 640,
    h = 49
  }

  bottomWall = {
    x = 0,
    y = 431,
    w = 640,
    h = 49
  }

  placeBallP1()

  world:add(paddle1, paddle1.x, paddle1.y, paddle1.w, paddle1.h)
  world:add(paddle2, paddle2.x, paddle2.y, paddle2.w, paddle2.h)
  world:add(ball, ball.x, ball.y, ball.w, ball.h)
  world:add(topWall, topWall.x, topWall.y, topWall.w, topWall.h)
  world:add(bottomWall, bottomWall.x, bottomWall.y, bottomWall.w, bottomWall.h)

  lg.setLineWidth(1)
  lg.setLineStyle("smooth")

  p1Score = 0
  p2Score = 0

  state = "reset" -- "p2Serve", "inPlay", "gameOver"

  gameOverChoice = 1
  winner = ""

  resetTimerMax = 0.5
  resetTimer = resetTimerMax

  maxSpeed = 12
end

function resetGame()
  gameOverChoice = 1
  winner = ""
  state = "reset"
  resetTimer = resetTimerMax
  p1Score = 0
  p2Score = 0
end

function placeBallP1()
  ball.x = paddle1.x + paddle1.w
  ball.y = paddle1.y + math.floor(paddle1.h / 2)
  ball.speed = 4
end

function placeBallP2()
  ball.x = paddle2.x - ball.w
  ball.y = paddle2.y + math.floor(paddle2.h / 2)
  ball.speed = 4
end

function getYSpeed(col)
  local ball = col.item
  local paddle = col.other
  local diff = ball.y - paddle.y
  if diff > 56 then
    return(4)
  elseif diff > 46 then
    return(3)
  elseif diff > 36 then
    return(2)
  elseif diff > 28 then
    return(0)
  elseif diff > 24 then
    return(-2)
  elseif diff > 18 then
    return(-3)
  elseif diff > 8 then
    return(-4)
  elseif diff > -6 then
    return(-5)
  else
    return(0)
  end
  print(diff)
end

function updateBall(dt)
  world:update(paddle1, paddle1.x, paddle1.y, paddle1.w, paddle1.h)
  world:update(paddle2, paddle2.x, paddle2.y, paddle2.w, paddle2.h)
  ball.x = ball.x + ball.speed
  ball.y = ball.y + ball.ySpeed
  local actualX, actualY, cols, len = world:move(ball, ball.x, ball.y, colfilter)
  ball.x = actualX
  ball.y = actualY
  for i=1,len do
    local other = cols[i].other
    blip:play()
    if other == paddle1 or other == paddle2 then
      ball.ySpeed = getYSpeed(cols[i])
      ball.speed = -ball.speed
      if other == paddle1 and lk.isDown('space') then
        ball.speed = math.min(maxSpeed, ball.speed + 2)
      elseif other == paddle2 and lk.isDown('rctrl') then
        ball.speed = math.min(maxSpeed, ball.speed - 2)
      end
    elseif other == topWall or other == bottomWall then
      ball.ySpeed = -ball.ySpeed
    end
  end
end

function love.update(dt)

  if state == "p1Serve" or state == "p2Serve" or state == "inPlay" then
    if lk.isDown('w') then
      if paddle1.y >= 50 then
        paddle1.y = math.max(50, paddle1.y - paddle1.speed)
      end
    elseif lk.isDown('s') then
      if paddle1.y <= (480 - paddle1.h - 50) then
        paddle1.y = math.min(480 - paddle1.h - 50, paddle1.y + paddle1.speed)
      end
    end
    if lk.isDown('up') then
      if paddle2.y >= 50 then
        paddle2.y = math.max(50, paddle2.y - paddle2.speed)
      end
    elseif lk.isDown('down') then
      if paddle2.y <= (480 - paddle2.h - 50) then
        paddle2.y = math.min(480 - paddle2.h - 50, paddle2.y + paddle2.speed)
      end
    end

    if state == "p1Serve" and lk.isDown('space') then
      state = "inPlay"
      placeBallP1()
    elseif state == "p2Serve" and lk.isDown('rctrl') then
      state = "inPlay"
      placeBallP2()
    end

  elseif state == "gameOver" then
    if lk.isDown('w') then
      gameOverChoice = math.max(1, gameOverChoice - 1)
    elseif lk.isDown('s') then
      gameOverChoice = math.min(2, gameOverChoice + 1)
    elseif lk.isDown('space') then
      if gameOverChoice == 1 then
        resetGame()
      else
        love.event.quit()
      end
    end
  elseif state == "reset" then
    resetTimer = resetTimer - dt
    if resetTimer <= 0 then
      state = "p1Serve"
    end
  end

  if state == "inPlay" then
    if ball.x < -ball.w then
      p2Score = p2Score + 1
      if p2Score == 21 then
        state = "gameOver"
        winner = "Player 2"
      else
        state = "p2Serve"
        placeBallP2()
      end
    end
    if ball.x > 640 then
      p1Score = p1Score + 1
      if p1Score == 21 then
        state = "gameOver"
        winner = "Player 1"
      else
        state = "p1Serve"
        placeBallP1()
      end
    end
    updateBall()
  end

end

function drawGameOver()
  local winWidth = 320
  local winHeight = 160
  lg.setColor(1,1,1,1)
  lg.rectangle("fill", 160, 160, winWidth, winHeight)
  lg.setColor(0,0,0,1)
  lg.rectangle("fill", 168, 168, winWidth - 16, winHeight - 16)
  lg.setColor(1, 1, 1, 1)
  lg.setFont(smallFont)
  lg.printf(winner .. " wins!", 174, 174, winWidth - 32, "center")
  lg.printf("New Game", 240, 174+68, winWidth - 32, "left")
  lg.printf("Exit    ", 240, 174+68+28, winWidth - 32, "left")

  local indicatorY = 174+68
  if gameOverChoice == 2 then
    indicatorY = 174+68+28
  end

  lg.print("> ", 216, indicatorY)

  lg.setFont(bigFont)
end

function love.draw()
  effect(function()
    lg.print(p1Score, 140)
    lg.print(p2Score, 640-190)
    local i = 0
    local y = 50
    while y < 430 do
      if (i % 2 == 0) then
        lg.line(320-3, y, 320-3, y+8)
      end
      i = i + 1
      y = y + 8
    end
    lg.line(0, 50, 640, 50)
    lg.line(0, 430, 640, 430)
    lg.rectangle("fill", paddle1.x, paddle1.y, paddle1.w, paddle1.h)
    lg.rectangle("fill", paddle2.x, paddle2.y, paddle2.w, paddle2.h)
    if state == "inPlay" then
      lg.rectangle("fill", ball.x, ball.y, ball.w, ball.h)
    end

    if state == "gameOver" then
      drawGameOver()
    end

  end)
end
