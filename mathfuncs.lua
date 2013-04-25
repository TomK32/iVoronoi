mfunc = { }

mfunc.zerothreshold = 0.01

function mfunc:sortpoints(points)
		table.sort(points,function (a,b) 	if a.y < b.y then return true 
											elseif a.y == b.y then	
												if a.x < b.y then return true
												else return false end
											else return false end end
		)
	return points
end
function mfunc:sortthepoints(points)
	local sortedpoints = self:sorttable(points,'x',true)
	sortedpoints = self:sorttable(sortedpoints,'y',true)
	return sortedpoints
end

function mfunc:insideboundaries(px,py,boundary)
	-- checks if the point is inside the square defined by the boundary
	if (boundary[1] <= px) and (boundary[2] <= py) and (boundary[3] >= px) and (boundary[4] >= py) then 
		return true
	else
		return false
	end
end

function mfunc:tablecontains(tablename,attributename,value)

	if attributename == nil then
		for i,v in pairs(tablename) do
			if v == value then return true end
		end
	else
		for i,v in pairs(tablename) do
			if v[attributename] == value then return true end
		end
	end
	return false

end

function mfunc:sortpolydraworder(listofpoints)

	local returner = { }

	-- sorts it assending by y
	table.sort(listofpoints,function (a,b) return a.y < b.y end)

	local unpacked = { }
	for i,point in pairs(listofpoints) do
		unpacked[#unpacked+1] = point.x
		unpacked[#unpacked+1] = point.y
	end

	local midpoint = { self:polyoncentroid(unpacked) }

	local right = { }
	local left = { }

	for i,point in pairs(listofpoints) do
		if point.x < midpoint[1] then 
			left[#left+1] = point
		else 
			right[#right+1] = point
		end
	end

	local tablecount= #left
	for j,point in pairs(left) do
		returner[tablecount+1-j] = point
	end
		
	for j,point in pairs(right) do
		returner[#returner+1] = point
	end

	unpacked = { }
	for i,point in pairs(returner) do
		if i > 1 then
			if (math.abs(unpacked[#unpacked-1] - point.x) < mfunc.zerothreshold) and (math.abs(unpacked[#unpacked] - point.y) < mfunc.zerothreshold) then
				-- duplicate point, so do nothing
			else
				unpacked[#unpacked+1] = point.x
				unpacked[#unpacked+1] = point.y
			end
		else
			unpacked[#unpacked+1] = point.x
			unpacked[#unpacked+1] = point.y
		end
	end
	returner = unpacked

	return returner
end

function mfunc:polyoncentroid(listofpoints)
	-- formula here http://en.wikipedia.org/wiki/Centroid#Centroid_of_polygon
	local A = 0
	for i = 1,#listofpoints,2 do
		--print('point',listofpoints[i],listofpoints[i+1])
		if i > #listofpoints-2 then
			A = A + listofpoints[i]*listofpoints[2] - listofpoints[1]*listofpoints[i+1]
		else
			A = A + listofpoints[i]*listofpoints[i+3] - listofpoints[i+2]*listofpoints[i+1]
		end
	end
	A = 0.5 * A

	local cx = 0
	for i = 1, #listofpoints,2 do
		if i > #listofpoints-2 then
			cx = cx + (listofpoints[i]+listofpoints[1])*(listofpoints[i]*listofpoints[2] - listofpoints[1]*listofpoints[i+1])
		else
			cx = cx + (listofpoints[i]+listofpoints[i+2])*(listofpoints[i]*listofpoints[i+3] - listofpoints[i+2]*listofpoints[i+1])
		end
	end
	cx = cx / (6*A)

	local cy = 0
	for i = 1, #listofpoints,2 do
		if i > #listofpoints-2 then
			cy = cy + (listofpoints[i+1]+listofpoints[2])*(listofpoints[i]*listofpoints[2] - listofpoints[1]*listofpoints[i+1])
		else
			cy = cy + (listofpoints[i+1]+listofpoints[i+3])*(listofpoints[i]*listofpoints[i+3] - listofpoints[i+2]*listofpoints[i+1])
		end
	end
	cy = cy / (6*A)
	--print('cx',cx,'cy',cy,'A',A)

	return cx,cy
end

function mfunc:sorttable(datable,parameter,sortbyasending)
	local count = 0
	local startingvalue = nil
	local startingvalueindex = 0
	local sortedtable = { }

	for i,v in pairs(datable) do 
		count = count + 1

		if (startingvalue == nil) 
		or (sortbyasending and (startingvalue[parameter] > v[parameter])) 
		or (sortbyasending == false and (startingvalue[parameter] < v[parameter])) then
			startingvalue = v
			startingvalueindex = i
		end
	end

	sortedtable[1] = startingvalue
	datable[startingvalueindex] = nil

	for i=2,count do
		local nextvalue = nil
		local nextvalueindex = 0

		for j,v in pairs(datable) do
			if (nextvalue == nil) 
			or (sortbyasending and (nextvalue[parameter] > v[parameter])) 
			or (sortbyasending == false and (nextvalue[parameter] < v[parameter])) then
				nextvalue = v
				nextvalueindex = j
			end
		end
		sortedtable[i] = nextvalue
		datable[nextvalueindex] = nil
	end

	return sortedtable
end

function mfunc:sortpolydraworder(listofpoints)
	-- gets the angle from some point in the center of the polygon and sorts by angle

	local returner = nil
	local mainpoint = { x=0, y=0 }
	local count = 0

	for i,v in pairs(listofpoints) do
		count = count + 1
		mainpoint.x = mainpoint.x + v.x
		mainpoint.y = mainpoint.y + v.y
	end

	mainpoint.x = (mainpoint.x/count)
	mainpoint.y = (mainpoint.y/count)

	-- sets the angle of each point with respect to the averaged centerpoint of the polygon.
	for i,v in pairs(listofpoints) do
		v.angle = math.acos(math.abs(mainpoint.y-v.y)/(math.sqrt(math.pow((mainpoint.x-v.x),2)+math.pow((mainpoint.y-v.y),2))))
		if (mainpoint.x <= v.x) and (mainpoint.y <= v.y) then
			v.angle = 3.14 - v.angle
		elseif (mainpoint.x >= v.x) and (mainpoint.y <= v.y) then
			v.angle = v.angle + 3.14
		elseif (mainpoint.x >= v.x)and (mainpoint.y >= v.y) then
			v.angle = 2*3.14 - v.angle
		end
	end

	-- orders the points correctly
	--table.sort(listofpoints,function(a,b) return a.angle > b.angle end)
	listofpoints = self:sorttable(listofpoints,'angle',true)

	for j,point in pairs(listofpoints) do
		if returner == nil then
			returner = { }
			returner[1] = point.x
			returner[2] = point.y
		else
			if (math.abs(returner[#returner-1] - point.x) < mfunc.zerothreshold) and (math.abs(returner[#returner] - point.y) < mfunc.zerothreshold) then
				-- duplicate point, so do nothing
			else
				returner[#returner+1] = point.x
				returner[#returner+1] = point.y
			end
		end
	end

	--print('returner: ',unpack(returner))

	return returner

end

-- this function will calculate the midpoint between point 1 and 2
function mfunc:perpendicularline(x1,y1,x2,y2)

	local slope = -1*(x2-x1)/(y2-y1)
	local midpoint = { x = (x2+x1)/2, y = (y2+y1)/2 }
	local intercept = midpoint.y - (slope*midpoint.x)

	local ix1 = 0
	local iy1 = slope*ix1+intercept
	local ix2 = windowsize.x
	local iy2 = slope*ix2+intercept

	return ix1,iy1,ix2,iy2
end

-- this function will treat the 2nd point as the midpoint
function mfunc:perpendicularline2(x1,y1,x2,y2)

	local slope = -1*(x2-x1)/(y2-y1)
	local midpoint = { x = x2, y = y2 }
	local intercept = midpoint.y - (slope*midpoint.x)

	local ix1 = 0
	local iy1 = slope*ix1+intercept
	local ix2 = windowsize.x
	local iy2 = slope*ix2+intercept

	return ix1,iy1,ix2,iy2
end

function mfunc:intersectionpoint(line1,line2)

	local slope1 = (line1[4]-line1[2])/(line1[3]-line1[1])
	local intercept1 = line1[2] - (slope1*line1[1])	
	local slope2 = (line2[4]-line2[2])/(line2[3]-line2[1])
	local intercept2 = line2[2] - (slope2*line2[1])

	local ix = 0
	local iy = 0

	-- checks if there is a vertical line
	if line1[1] == line1[3] then
		--line 1 is vertical
		ix = line1[1]
		iy = slope2*ix + intercept2
	elseif line2[1] == line2[3] then
		--line 2 is vertical
		ix = line2[1]
		iy = slope1*ix + intercept1
	else
		-- do the normal math
		ix = (intercept2 - intercept1) / (slope1 - slope2)
		iy = slope1*ix + intercept1
	end

	local onbothlines = false
	if self:isonline(ix,iy,line1) == true and self:isonline(ix,iy,line2) == true then 
		onbothlines = true
	end

	return ix, iy, onbothlines
end

function mfunc:issegmentintersect(line1,groupoflines)
	-- checks if the line segment intersects any of the line segments in the group of lines

	local timestrue = 0
	local timesfalse = 0
	local checkset = { }

	for index,line2 in pairs(groupoflines) do
		local ix,iy,onbothlines = self:intersectionpoint(line1,line2)

		if ((math.abs(line1[1]-ix)+math.abs(line1[2]-iy))<mfunc.zerothreshold or (math.abs(line1[3]-ix)+math.abs(line1[4]-iy))<mfunc.zerothreshold) then 
			onbothlines = false
		end

		checkset[index] = onbothlines

		if onbothlines then timestrue = timestrue + 1 else timesfalse = timesfalse + 1 end
	end

	if timestrue > 0 then return false else return true end
end

function mfunc:isonline(x,y,line)
	-- checks if the point is on the line

	local returner = false
	local xis = false
	local yis = false
	local endpoint = false

	if (line[1] >= x and x >= line[3]) or (line[3] >= x and x >= line[1])  then
		xis = true
	end

	if (line[2] >= y and y >= line[4]) or (line[4] >= y and y >= line[2]) then
		yis = true
	end

	if (line[1] == x and line[2] == y) or (line[3] == x and line[4] == y) then
		endpoint = true
	end

	if xis == true and yis == true and endpoint == false then returner = true end

	return returner
end

function mfunc:round(num, idp)
	--http://lua-users.org/wiki/SimpleRound
 	local mult = 10^(idp or 0)
 	return math.floor(num * mult + 0.5) / mult
end