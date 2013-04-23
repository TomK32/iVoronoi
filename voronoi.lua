-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
voronoi = { }
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
-- creates a voronoi diagram and returns a table containing the structure.
--
-- polygoncount = the number of polygons wanted, this can be thought of as the total number of grid regions
-- iterations = how many times you would like to run the  voronoi. the more iterations, the smoother and more regular
--              the grid looks, recommend at least 3 iterations for a nice grid. any more is diminishing returns
-- minx,miny,maxx,maxy = the boundary for the voronoi diagram. if you choose 0,0,100,100 the function will make a voronoi diagram inside 
--                       the square defined by 0,0 and 100,100 where all the points of the voronoi are inside the square.
function voronoi:create(polygoncount,iterations,minx,miny,maxx,maxy)
	local returner = { }

	----------------------------------------------------------
	-- the iteration loop
	for it=1,iterations do

		------------------------------------------------
		-- initalizes everything needed for this iteration
		returner[it] = { }
		returner[it].points = { }
		returner[it].boundary = { minx,miny,minx+maxx,miny+maxy }
		returner[it].vertex = { }
		returner[it].segments = { }
		returner[it].events = Heap:new()
		returner[it].beachline = DoubleLinkedList:new()
		returner[it].polygons = { }

		---------------------------------------------------------
		-- creates the random points that the polygons will be based
		-- off of. if this is it > 1 then it uses the centroids of the 
		-- polygons from the previous iteration as the 'random points'
		-- this relaxes the voronoi diagram and softens the grids so
		-- the grid is more even.
		if it == 1 then 
			for i=1,polygoncount do
				returner[it].points[i] = 
				{ 
					x = math.random(returner[it].boundary[1],returner[it].boundary[3]), 
					y = math.random(returner[it].boundary[2],returner[it].boundary[4]) 
				}
			end
			-- sorts the polygon midpoints
			returner[it].points = mfunc:sortpoints(returner[it].points)
		else
			returner[it].points = returner[it-1].centroids
		end
		
		-- sets up the returner events
		for i = 1,#returner[it].points do
			returner[it].events:push(returner[it].points[i], returner[it].points[i].x)
		end
		
		while not returner[it].events:isEmpty() do
			local e, x = returner[it].events:pop()
			if e.event then
				self:processEvent(e,returner[it])
			else
				self:processPoint(e,returner[it])
			end    
		end
		
		self:finishEdges(returner[it])	 
    end

    -----------------------------
    -- returns the last iteration
    return returner[iterations]
end

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
-- draws the voronoi diagram, used for debugging and visualizing the diagram before using it for anything else.
--
-- ivoronoi = the input voronoi structure. this is expecting the returner[it] from the creation function, 
-- 			  should be the default output from voronoi:create()
function voronoi:draw(ivoronoi)

	-- draw the points
	love.graphics.setColor(255,255,255)
	love.graphics.setPointSize(5)
	for index,point in pairs(ivoronoi.points) do
		love.graphics.point(point.x,point.y)
	end

	-- draws the segments
	love.graphics.setColor(150,0,100)
	for index,segment in pairs(ivoronoi.segments) do
		love.graphics.line(segment.startPoint.x,segment.startPoint.y,segment.endPoint.x,segment.endPoint.y)
	end

end

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
Heap = { }

function Heap:new() 
    o = { heap = { }, nodes = { } } 
    setmetatable(o, self) 
    self.__index = self 
    return o
end
 
function Heap:push(k, v)
    assert(v ~= nil, "cannot push nil")

    local heap_pos = #self.heap + 1 -- node position in heap array (leaf)
    local parent_pos = (heap_pos - heap_pos % 2) / 2 -- parent position in heap array

    self.heap[heap_pos] = k -- insert at a leaf
    self.nodes[k] = v

    while heap_pos > 1 and self.nodes[self.heap[parent_pos]] > v do -- climb heap?
        self.heap[parent_pos], self.heap[heap_pos] = self.heap[heap_pos], self.heap[parent_pos]
        heap_pos = parent_pos
        parent_pos = (heap_pos - heap_pos % 2) / 2
    end

end
 
function Heap:pop()
    local heap_pos = #self.heap

    assert(heap_pos > 0, "cannot pop from empty heap")

    local heap_root_pos = self.heap[1]
    local heap_root = self.nodes[heap_root_pos]

    local current_heap = self.nodes[self.heap[heap_pos]]

    self.heap[1] = self.heap[heap_pos] -- move leaf to root
    self.heap[heap_pos] = nil -- remove leaf
    self.nodes[heap_root_pos] = nil
    heap_pos = heap_pos - 1

    local node_pos = 1 -- node position in heap array

    local parent_pos = 2 * node_pos -- left sibling position
    if heap_pos > parent_pos and self.nodes[self.heap[parent_pos]] > self.nodes[self.heap[parent_pos + 1]] then
        parent_pos = 2 * node_pos + 1 -- right sibling position
    end
    while heap_pos >= parent_pos and self.nodes[self.heap[parent_pos]] < current_heap do -- descend heap?
        self.heap[parent_pos], self.heap[node_pos] = self.heap[node_pos], self.heap[parent_pos]
        node_pos = parent_pos
        parent_pos = 2 * node_pos
    if heap_pos > parent_pos and self.nodes[self.heap[parent_pos]] > self.nodes[self.heap[parent_pos + 1]] then
        parent_pos = 2 * node_pos + 1
    end
end
    return heap_root_pos, heap_root
end
 
function Heap:isEmpty() 
    return self.heap[1] == nil 
end

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
DoubleLinkedList = { }

function DoubleLinkedList:new()
    o = { first = nil, last = nil } -- empty list head

    setmetatable(o, self) 
    self.__index = self 

    return o
end
 
function DoubleLinkedList:insertAfter(node, data)
    local new = {prev = node, next = node.next, x = data.x, y = data.y } -- creates a new node
    node.next = new -- the node after node is the new node
    if node == self.last then -- check if the old node is the last node...
        self.last = new -- ...and set the new node as last node
    else
        --otherwise set the next nodes previous node to the new one
        new.next.prev = new 
    end
    return new -- return the new node
end
 
function DoubleLinkedList:insertAtStart(data)
    local new = {prev = nil, next = self.first, x = data.x, y = data.y} -- create the new node
    if not self.first then -- check if the list is empty
        self.first = new -- the new node is the first and the last in this case
        self.last = new
   else
        -- the node before the old first node is the new first node
        self.first.prev = new
        self.first = new -- update the list's first field
   end
   return new
end
 
function DoubleLinkedList:delete(node)
    if node == self.first then -- check if the node is the first one...
        -- ...and set the new first node if we remove the first
        self.first = node.next
    else
        -- set the previous node's next node to the next node
        node.prev.next = node.next
    end
    
    if node == self.last then -- check if the node is the last one...
        -- ...the new last node is the node before the deleted node
        self.last = node.prev
    else
        node.next.prev = node.prev -- update the next node's prev field
    end
end
 
function DoubleLinkedList:nextNode(node)
    return (not node and self.first) or node.next
end

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

function voronoi:processEvent(event,ivoronoi)
    if event.valid then
        local segment = {startPoint = {x = event.x, y = event.y}, endPoint = {x = 0, y = 0}, done = false, type = 1}
        table.insert(ivoronoi.segments, segment)
        --Remove the associated arc from the front, and update segment info
        
        ivoronoi.beachline:delete(event.arc)
        
        if event.arc.prev then
            event.arc.prev.seg1 = segment
        end
        
        if event.arc.next then
            event.arc.next.seg0 = segment
        end
        
        --Finish the edges before and after arc.
        if event.arc.seg0 then
            event.arc.seg0.endPoint = {x = event.x, y = event.y}
            event.arc.seg0.done = true
        end    
            
        if event.arc.seg1 then
            event.arc.seg1.endPoint = {x = event.x, y = event.y}
            event.arc.seg1.done = true
        end    
        
        -- debugging vertix list!!!
        table.insert(ivoronoi.vertex, {x = event.x, y = event.y})
        
        --Recheck circle events on either side of p:
        if (event.arc.prev) then
            self:check_circle_event(event.arc.prev, event.x,ivoronoi)
        end
        if (event.arc.next) then
            self:check_circle_event(event.arc.next, event.x,ivoronoi)
        end    
        event.arc = nil
   end
   event = nil 
end
 
 
function voronoi:processPoint(point,ivoronoi)
    --Adds a point to the beachline
    local intersect = intersect
    if (not ivoronoi.beachline.first) then
        ivoronoi.beachline:insertAtStart(point)
        return
    end
    
    --Find the current arc(s) at height p.y (if there are any).
    for arc in ivoronoi.beachline.nextNode, ivoronoi.beachline do
        z = (intersect(point,arc))
        if z then
            --New parabola intersects arc i.  If necessary, duplicate i.
            -- ie if there is a next node, but there is not interation, then creat a duplicate
            if not (arc.next and (intersect(point,arc.next))) then
                ivoronoi.beachline:insertAfter(arc, arc)
            else    
                --print("test", arc.next,intersect(point,arc.next).x,intersect(point,arc.next).y, z.x,z.y  )
                return
            end    
            arc.next.seg1 = arc.seg1
            
            --Add p between i and i->next.
            ivoronoi.beachline:insertAfter(arc, point)
 
            
            segment = {startPoint = {x = z.x, y = z.y}, endPoint = {x = 0, y = 0}, done = false, type = 2}
            segment2 = {startPoint = {x = z.x, y = z.y}, endPoint = {x = 0, y = 0}, done = false, type = 2}
 
            -- debugging segment list!!!
            table.insert(ivoronoi.segments, segment)
            table.insert(ivoronoi.segments, segment2)
 
            
            --Add new half-edges connected to i's endpoints.
            arc.next.seg0 = segment
            arc.seg1 = segment
            arc.next.seg1 = segment2
            arc.next.next.seg0 = segment2
            
            --Check for new circle events around the new arc:
            self:check_circle_event(arc, point.x, ivoronoi)
            self:check_circle_event(arc.next, point.x, ivoronoi)
            self:check_circle_event(arc.next.next, point.x, ivoronoi)
 
            return
            
        end    
    end
 
 
    --Special case: If p never intersects an arc, append it to the list.
    -- Find the last node.
    
    ivoronoi.beachline:insertAtStart(point)
 
    segment = {startPoint = {x = X0, y = (ivoronoi.beachline.last.y + ivoronoi.beachline.last.prev.y) / 2}, endPoint = {x = 0, y = 0}, done = false, type = 3}
    
    table.insert(segments, segment)
    
    ivoronoi.beachline.last.seg0 = segment
    ivoronoi.beachline.last.prev.seg1 = segment
end
 
 
 
function voronoi:check_circle_event(arc, x0, ivoronoi)
    --Look for a new circle event for arc i.
    --Invalidate any old event.
 
    if (arc.event and arc.event.x ~= x0) then
        arc.event.valid = false
    end
    arc.event = nil
 
    if ( not arc.prev or not arc.next) then
        return
    end
    
    local a = arc.prev
    local b = arc
    local c = arc.next
 
    if ((b.x-a.x)*(c.y-a.y) - (c.x-a.x)*(b.y-a.y) >= 0) then
        return false
    end    
 
    --Algorithm from O'Rourke 2ed p. 189.
    local A = b.x - a.x
    local B = b.y - a.y
    local C = c.x - a.x
    local D = c.y - a.y
    local E = A*(a.x+b.x) + B*(a.y+b.y)
    local F = C*(a.x+c.x) + D*(a.y+c.y)
    local G = 2*(A*(c.y-b.y) - B*(c.x-b.x))
 
    if (G == 0) then
        --return false --Points are co-linear
        print("g is 0")
    end
 
    --Point o is the center of the circle.
    local o = {}
    o.x = (D*E-B*F)/G
    o.y = (A*F-C*E)/G
 
    --o.x plus radius equals max x coordinate.
    local x = o.x + math.sqrt( math.pow(a.x - o.x, 2) + math.pow(a.y - o.y, 2) )
    
    if x and x > x0 then
        --Create new event.
        arc.event = {x = o.x, y = o.y, arc = arc, valid = true, event = true}
        ivoronoi.events:push(arc.event, x)
    end
end
 
 
 
function intersect(point, arc)
    --Will a new parabola at point p intersect with arc i?
    local res = {}
    if (arc.x == point.x) then 
        return false 
    end
 
    if (arc.prev) then
        --Get the intersection of i->prev, i.
        a = intersection(arc.prev, arc, point.x).y
    end    
    if (arc.next) then
        --Get the intersection of i->next, i.
        b = intersection(arc, arc.next, point.x).y
    end    
    --print("intersect", a,b,p.y)
    if (( not arc.prev or a <= point.y) and (not arc.next or point.y <= b)) then
        res.y = point.y
        -- Plug it back into the parabola equation.
        res.x = (arc.x*arc.x + (arc.y-res.y)*(arc.y-res.y) - point.x*point.x) / (2*arc.x - 2*point.x)
        return res
    end
    return false
end
 
 
function intersection(p0, p1, l)
    -- Where do two parabolas intersect?
    
    local res = {}
    local p = {x = p0.x, y = p0.y}
 
    if (p0.x == p1.x) then
        res.y = (p0.y + p1.y) / 2
    elseif (p1.x == l) then
        res.y = p1.y
    elseif (p0.x == l) then
        res.y = p0.y
        p = p1
   else
      -- Use the quadratic formula.
      local z0 = 2*(p0.x - l);
      local z1 = 2*(p1.x - l);
 
      local a = 1/z0 - 1/z1;
      local b = -2*(p0.y/z0 - p1.y/z1);
      local c = (p0.y*p0.y + p0.x*p0.x - l*l)/z0 - (p1.y*p1.y + p1.x*p1.x - l*l)/z1
      res.y = ( -b - math.sqrt(b*b - 4*a*c) ) / (2*a)
   end
   
   -- Plug back into one of the parabola equations.
   res.x = (p.x*p.x + (p.y-res.y)*(p.y-res.y) - l*l)/(2*p.x-2*l)
   return res
end
 
function voronoi:finishEdges(ivoronoi)
    --Advance the sweep line so no parabolas can cross the bounding box.
    l = ivoronoi.boundary[3] + (ivoronoi.boundary[3]-ivoronoi.boundary[1]) + (ivoronoi.boundary[4]-ivoronoi.boundary[2])
 
    --Extend each remaining segment to the new parabola intersections.
    for arc in ivoronoi.beachline.nextNode, ivoronoi.beachline do
        if arc.seg1 then
            p = intersection(arc, arc.next, l*2)
            arc.seg1.endPoint = {x = p.x, y = p.y}
            arc.seg1.done = true
        end    
    end
end
