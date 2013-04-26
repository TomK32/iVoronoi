function love.load()

	package.path = 'D:/Documents/Programming/voronoi/?.lua;' .. package.path
	--package.path = './../../?.lua;' .. package.path

	require 'generator'
	require 'voronoi'

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