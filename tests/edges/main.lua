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

	voronoi = require 'voronoi'

	-----------------------

	framesize = { x=windowsize.x-50, y=windowsize.y-50 }
	pointcount = 50

	drawme = { [1] = true }

	initalize()
end

function initalize()
	genvoronoi = voronoi:new(pointcount,3,25,25,framesize.x,framesize.y)
end

function love.draw()

	love.graphics.setColor(255,255,255)
	for i,v in pairs(drawme) do
		for j,k in pairs(genvoronoi:getEdges(1)) do
			love.graphics.line(unpack(k))
		end
	end

end

function love.update()

end

function love.keyreleased(key)

end

function love.keypressed(key,unicode)

end