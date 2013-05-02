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
	neighbormode = 'all'
	initalize()
	indexes = { }
end

function initalize()
	genvoronoi = voronoi:new(pointcount,3,25,25,framesize.x,framesize.y)
end

function love.draw()

	for index,tt in pairs(drawthem) do
		love.graphics.setColor(150,150,150)
		love.graphics.polygon('fill',unpack(genvoronoi.polygons[index].points))
	end

	for i,polygon in pairs(genvoronoi:getNeighbors(neighbormode,unpack(indexes))) do
		love.graphics.setColor(255,0,0,100)
		love.graphics.polygon('fill',unpack(polygon.points))
	end

	for index,polygon in pairs(genvoronoi.polygons) do
		if #polygon.points >= 6 then
			love.graphics.setColor(50,50,50)
			love.graphics.polygon('line',unpack(polygon.points))
			love.graphics.setColor(50,50,50)
			love.graphics.print(polygon.index,polygon.centroid.x,polygon.centroid.y)
		end
	end

	love.graphics.setColor(255,255,255)
	love.graphics.print('draw mode: ' .. neighbormode,5,5)

end

function love.update()

	indexes = { }
	for i,v in pairs(drawthem) do indexes[#indexes+1] = i end

end

function love.keyreleased(key)

end

function love.keypressed(key,unicode)

	if key == '1' then neighbormode = 'all' elseif key == '2' then neighbormode = 'shared' end

end

function love.mousepressed(x,y,button)

	if button == 'l' then

		local polygon = genvoronoi:polygoncontains(x,y)
		if polygon ~= nil then
			if drawthem[polygon.index] == true then drawthem[polygon.index] = nil else drawthem[polygon.index] = true end
		end

	end
end