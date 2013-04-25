gen = { }
gen.regions = { }

framesize = { x=windowsize.x-50, y=windowsize.y-50 }
pointcount = 50

function gen:initalize()
	-- fixed for testing, remove the seed when testing is finished
	--local seed = math.random(1,55555)
	--math.randomseed(41493)
	--print('seed used: ' .. seed)

	gen.regions = voronoi:create(pointcount,3,25,25,framesize.x,framesize.y)

end

function gen:keypressed(key,unicode)

end

function gen:keyreleased(key)

end

function gen:draw()

	voronoi:draw(gen.regions)

	love.graphics.setColor(255,255,255)

	love.graphics.rectangle('line',gen.regions.boundary[1],gen.regions.boundary[2],gen.regions.boundary[3]-gen.regions.boundary[1],gen.regions.boundary[4]-gen.regions.boundary[2])

end

function gen:update()

end

-- http://www.voronoigame.com/VoronoiGameApplet.html
-- implement the voronoi like this, might be lots faster to calculate! then the way i have it

-- or generate larger ones recursevly, so it generates a few big cells, then smaller cells in the bigger cells.

-- Bowyer–Watson algorithm http://en.wikipedia.org/wiki/Bowyer%E2%80%93Watson_algorithm
-- Fortune's algorithm http://en.wikipedia.org/wiki/Fortune%27s_algorithm
-- Lloyd's algorithm http://en.wikipedia.org/wiki/Lloyd%27s_algorithm
