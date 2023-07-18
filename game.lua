Game = {}
Game.__index = Game

function Game:Create(games)
	local this = {
		games = games,
		stack = StateStack:Create(),
		gameState = nil,
	}

	setmetatable(this, self)
	return(this)
end 

function Game:load(gameName, data)
	--local current = self.stack:pop()
	--current:exit()
	local new = self.games[gameName]
	gameStack:push(new)
	gameStack.current:enter(data)
end 

function Game:update(dt)
	self.stack:update(dt)
end

function Game:draw()
	self.stack:draw()
end 
