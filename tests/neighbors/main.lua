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


	drawthem = { }
	initalize()
end

function initalize()
	genvoronoi = voronoi:new(pointcount,3,25,25,framesize.x,framesize.y)
end

function love.draw()

	for index,tt in pairs(drawthem) do
		love.graphics.setColor(150,150,150)
		love.graphics.polygon('fill',unpack(genvoronoi.polygons[index].points))
		love.graphics.setColor(0,0,0)
		love.graphics.polygon('line',unpack(genvoronoi.polygons[index].points))
		
		for i,polygon in pairs(genvoronoi:getNeighbors(index)) do
			love.graphics.setColor(150,0,0)
			love.graphics.polygon('fill',unpack(polygon.points))
			love.graphics.setColor(0,0,0)
			love.graphics.polygon('line',unpack(polygon.points))
		end
	end

end

function love.update()

end

function love.keyreleased(key)

	drawthem = { }

end

function love.keypressed(key,unicode)

	if (unicode >= 49) and (unicode <= 57) then
		drawthem[unicode-48] = true
	end

end