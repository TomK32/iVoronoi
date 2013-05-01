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
	drawlist = { }

	activated = { [2] = true }

	initalize()
end

function initalize()
	genvoronoi = voronoi:new(pointcount,3,25,25,framesize.x,framesize.y)
end

function love.draw()

	for index,polygon in pairs(genvoronoi.polygons) do
		if #polygon.points >= 6 then
			love.graphics.setColor(25,25,25)
			love.graphics.polygon('fill',unpack(polygon.points))
			love.graphics.setColor(100,100,100)
			love.graphics.polygon('line',unpack(polygon.points))
			if activated[index] then love.graphics.setColor(255,0,0) end
			love.graphics.print(polygon.index,polygon.centroid.x,polygon.centroid.y)
		end
	end

	love.graphics.setColor(255,255,255)
	for j,k in pairs(genvoronoi:getEdges(unpack(drawlist))) do
		love.graphics.line(unpack(k))
	end

end

function love.update()

	drawlist = { }
	for i,v in pairs(drawme) do
		drawlist[#drawlist+1] = i 
	end

end

function love.mousepressed(x,y,button)

	if button == 'l' then
		local distance = { }
		for index,centroids in pairs(genvoronoi.centroids) do
			distance[#distance+1] = { i = index, d = math.sqrt(math.pow(x-centroids.x,2) + math.pow(y-centroids.y,2)) }
		end

		table.sort(distance,function(a,b) return a.d < b.d end)

		for i,pindex in pairs({ unpack(genvoronoi.polygonmap[distance[1].i]),distance[1].i }) do
			if genvoronoi.polygons[pindex]:containspoint(x,y) then 
				if activated[pindex] == true then activated[pindex] = nil else activated[pindex] = true end
			end
		end
	end
end

function love.keyreleased(key)

end

function love.keypressed(key,unicode)

	if (unicode >= 49) and (unicode <= 57) then
		if drawme[unicode-48] == true then drawme[unicode-48] = nil else drawme[unicode-48] = true end
	end

end