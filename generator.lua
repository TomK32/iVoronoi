gen = { }
gen.regions = { }

framesize = { x=400, y=400 }
pointcount = 6

function gen:initalize()
	-- fixed for testing, remove the seed when testing is finished
	math.randomseed(123)

	gen.regions = voronoi:create(pointcount,1,300,100,framesize.x,framesize.y)

end

function gen:keypressed(key,unicode)

end

function gen:keyreleased(key)

end

function gen:draw()

	voronoi:draw(gen.regions)

	love.graphics.setColor(255,255,255)

	love.graphics.rectangle('line',300,100,400,400)

end

function gen:update()

end

-- http://www.voronoigame.com/VoronoiGameApplet.html
-- implement the voronoi like this, might be lots faster to calculate! then the way i have it

-- or generate larger ones recursevly, so it generates a few big cells, then smaller cells in the bigger cells.

-- Bowyer–Watson algorithm http://en.wikipedia.org/wiki/Bowyer%E2%80%93Watson_algorithm
-- Fortune's algorithm http://en.wikipedia.org/wiki/Fortune%27s_algorithm
-- Lloyd's algorithm http://en.wikipedia.org/wiki/Lloyd%27s_algorithm
