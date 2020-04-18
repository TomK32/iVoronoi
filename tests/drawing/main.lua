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


	initalize()
end

function initalize()
	genvoronoi = voronoi:new(pointcount,3,25,25,framesize.x,framesize.y)
end

function love.draw()
	draw(genvoronoi)
end

function love.keypressed(key)
	if key == "q" then initalize() end
end

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
-- draws the voronoi diagram, used for debugging and visualizing the diagram before using it for anything else.
--
-- ivoronoi = the input voronoi structure. this is expecting the returner[it] from the creation function, 
-- 			  should be the default output from voronoi:create()
function draw(ivoronoi)

	-- draws the polygons
	for index,polygon in pairs(ivoronoi.polygons) do
		if #polygon.points >= 6 then
			love.graphics.setColor(0.2,0.2,0.2)
			love.graphics.polygon('fill',unpack(polygon.points))
			love.graphics.setColor(1,1,1)
			love.graphics.polygon('line',unpack(polygon.points))
		end
	end

	-- draws the segments
	--[[love.graphics.setColor(0.6,0,0.4)
	for index,segment in pairs(ivoronoi.segments) do
		love.graphics.line(segment.startPoint.x,segment.startPoint.y,segment.endPoint.x,segment.endPoint.y)
	end]]--

	-- draws the segment's vertices
	--[[love.graphics.setColor(0.9,0.4,0.8)
	love.graphics.setPointSize(5)
	for index,vertex in pairs(ivoronoi.vertex) do
		love.graphics.points(vertex.x,vertex.y)
	end]]--

	-- draw the points
	love.graphics.setColor(1,1,1)
	love.graphics.setPointSize(7)
	for index,point in pairs(ivoronoi.points) do
		love.graphics.points(point.x,point.y)
		love.graphics.print(index,point.x,point.y)
	end

	-- draws the centroids
	love.graphics.setColor(1,1,0)
	love.graphics.setPointSize(5)
	for index,point in pairs(ivoronoi.centroids) do
		love.graphics.points(point.x,point.y)
		love.graphics.print(index,point.x,point.y)
	end

	-- draws the relationship lines
	love.graphics.setColor(0,1,0)
	for pointindex,relationgroups in pairs(ivoronoi.polygonmap) do
		for badindex,subpindex in pairs(relationgroups) do
			love.graphics.line(ivoronoi.centroids[pointindex].x,ivoronoi.centroids[pointindex].y,ivoronoi.centroids[subpindex].x,ivoronoi.centroids[subpindex].y)
		end
	end
end