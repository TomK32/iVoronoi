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
	pointcount = 250

	drawlist = { }
	edgemode = 'segment'
	activated = { }

	initalize()
end

function initalize()
	genvoronoi = voronoi:new(pointcount,3,25,25,framesize.x,framesize.y)
end

function love.draw()

	for index,polygon in pairs(genvoronoi.polygons) do
		if #polygon.points >= 6 then
			if activated[polygon.index] then love.graphics.setColor(0,0.4,0) else love.graphics.setColor(0.04,0.04,0.04) end
			love.graphics.polygon('fill',unpack(polygon.points))
			love.graphics.setColor(0.2,0.2,0.2)
			love.graphics.polygon('line',unpack(polygon.points))
			if activated[polygon.index] then love.graphics.setColor(1,0,0) end
			love.graphics.print(polygon.index,polygon.centroid.x,polygon.centroid.y)
		end
	end

	love.graphics.setColor(1,1,1)
	for j,k in pairs(genvoronoi:getEdges(edgemode,unpack(drawlist))) do
		love.graphics.line(unpack(k))
	end

	love.graphics.setColor(1,1,1)
	love.graphics.print('drawmode: '.. edgemode .. ' drawing ' .. #genvoronoi:getEdges(edgemode,unpack(drawlist)) .. ' segment(s)',5,5)
end

function love.update()

	drawlist = { }
	for i,v in pairs(activated) do drawlist[#drawlist+1] = i end

end

function love.mousepressed(x,y,button)

	if button == 1 then
		local polygon = genvoronoi:polygoncontains(x,y)
		if polygon ~= nil then
			if activated[polygon.index] == true then activated[polygon.index] = nil else activated[polygon.index] = true end
		end

	end
end

function love.keyreleased(key)

end

function love.keypressed(key,unicode)

	if key == '1' then edgemode = 'segment' 
	elseif key == '2' then edgemode = 'vertex' end

end