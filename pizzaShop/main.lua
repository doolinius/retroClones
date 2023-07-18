
function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  love.window.setMode(320*3, 240*3, {minwidth = 324, minheight = 244, resizable =true})
  anim8 = require('libs/anim8')
  Input = require('libs/Input')
  log = require('libs/log')
  sti = require('libs/sti')
  bump = require('libs/bump')
  input = Input()
  input:bind('2', function() love.graphics.captureScreenshot("pizzaShop" .. os.time() .. ".png") end)
  input:bind('p', 'pause')
  input:bind('f', 'toggle_fullscreen')

  input:bind('a', 'left')
  --input:bind('left', 'left')
  input:bind('d', 'right')
  input:bind('s', 'down')
  input:bind('w', 'up')
  require('ladder')
  require('player')

  world = bump.newWorld()
  map = sti("map1.lua", {"bump"})
  map:bump_init(world)
  ladder = Ladder:Create(20, 20, 80)
  player = Player:Create()
  player.x = 2 * 16
  player.y = 9 * 16
  world:add(player, player.x, player.y, 12, 16)
end

function love.update(dt)
  --player:handleInput()
  map:update(dt)
  player:update(dt)
end

function love.draw()
love.graphics.scale(3)
  map:draw(0, 0, 3)
  player:draw()
end
