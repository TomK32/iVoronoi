gen = { }
gen.regions = { }

framesize = { x=windowsize.x-50, y=windowsize.y-50 }
pointcount = 50

function gen:initalize()
	-- fixed for testing, remove the seed when testing is finished
	--local seed = math.random(1,55555)
	math.randomseed(45754)
	--print('seed used: ' .. seed)

	-- numbers with problems, fix them
	-- 31138 (250 points, 1000x600)
	-- 40953 (250 points, 1000x600)
	-- 19288 (250 points, 1000x600)
	-- 48962 (250 points, 1000x600)

	-- this one has a 'sorting' error ... 'invalid order for sorting'
	-- 30202 (250 points, 1000x600), mfunc:sortpoints cause this. if you remove it, it works but then it looks bad

	-- 36758 (50 points, 1000x600)

	gen.regions = voronoi:create(pointcount,1,25,25,framesize.x,framesize.y)

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
