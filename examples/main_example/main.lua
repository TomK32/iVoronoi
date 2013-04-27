function love.load( arg )
	-------------------------------------------------------------------------------
	-- this section here finds the current directory of the main.lua and moves the 
	-- package.path to the root of the repo, so that it can use voronoi.lua
	for i,v in pairs(arg) do 
		if (v ~= '--console') and (v ~= 'embedded boot.lua') and (v:find('.exe') == nil ) then
			print(v)
			package.path = v..'/../../?.lua;' .. package.path
		end
	end
	
	require 'generator'
	voronoi = require 'voronoi'

	gen:initalize()
end

function love.draw()
	gen:draw()
end

function love.keypressed(key,unicode)
	if key == "q" then gen:initalize() end

	gen:keypressed(key,unicode)
end

function love.keyreleased(key)
	gen:keyreleased(key)
end

function love.update()
	gen:update()
end