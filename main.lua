
function love.load()

	game = Game:Create()
	-- optional command line argument to start a particular game
	-- game:start("digitron") 
	-- without game name, it starts with a selection menu
	game:start()

end 

function love.update(dt)

	game:update(dt)

end

function love.draw()
	game:draw()
end 
