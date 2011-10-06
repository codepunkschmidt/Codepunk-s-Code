-- A* pathfinding module
-- Author: Lerg
-- Release date: 2011-08-25
-- Version: 1.1
-- License: MIT
-- Based on the python implementation.
--
-- USAGE:
--   Import this module and use pathFind() function. Map should be zero indexed (first element index is zero).
local _M = {}
 
local mAbs = math.abs
local mSqrt = math.sqrt

-------------------------------------------
-- Set a value to bounds
-------------------------------------------
local function clamp(value, low, high)
    if value < low then value = low
    elseif high and value > high then value = high end
    return value
end

-------------------------------------------
-- Implementation of min binary heap for use as a priority queue
-- each element should have 'priority' field or one that you defined
-- when created a heap.
-------------------------------------------
local function newHeap (priority)
    if not priority then
        priority = 'priority'
    end
    heapObject = {}
    heapObject.heap = {}
    heapObject.len = 0 -- Size of the heap
    function heapObject:push (newElement) -- Adds new element to the heap
        local index = self.len
        self.heap[index] = newElement -- Add to bottom of the heap
        self.len = self.len + 1 -- Increase heap elements counter
        self:heapifyUp(index) -- Maintane min heap
    end
 
    function heapObject:heapifyUp (index)
        local parentIndex = clamp(math.floor((index - 1) / 2), 0)
        if self.heap[index][priority] < self.heap[parentIndex][priority] then
            self.heap[index], self.heap[parentIndex] = self.heap[parentIndex], self.heap[index] -- Swap
            self:heapifyUp(parentIndex) -- Continue sorting up the heap
        end
    end
 
    function heapObject:pop (index) -- Returns the element with the smallest priority or specific one
        if not index then index = 0 end
        local minElement = self.heap[index]
        self.heap[index] = self.heap[self.len - 1] -- Swap
        -- Remove element from heap
        self.heap[self.len - 1] = nil
        self.len = self.len - 1
        self:heapifyDown(index) -- Maintane min heap
        return minElement
    end
 
    function heapObject:heapifyDown (index)
        local leftChildIndex = 2 * index + 1
        local rightChildIndex = 2 * index + 2
        if  (self.heap[leftChildIndex] and self.heap[leftChildIndex][priority] and self.heap[leftChildIndex][priority] < self.heap[index][priority])
            or
            (self.heap[rightChildIndex] and self.heap[rightChildIndex][priority] and self.heap[rightChildIndex][priority] < self.heap[index][priority]) then
                if (not self.heap[rightChildIndex] or not self.heap[rightChildIndex][priority]) or self.heap[leftChildIndex][priority] < self.heap[rightChildIndex][priority] then
                    self.heap[index], self.heap[leftChildIndex] = self.heap[leftChildIndex], self.heap[index] -- Swap
                    self:heapifyDown(leftChildIndex) -- Continue sorting down the heap
                else
                    self.heap[index], self.heap[rightChildIndex] = self.heap[rightChildIndex], self.heap[index] -- Swap
                    self:heapifyDown(rightChildIndex) -- Continue sorting down the heap
                end
        end
    end
 
    function heapObject:root () -- Returns the root element without removing it
        return self.heap[0]
    end
 
    return heapObject
end

-------------------------------------------
-- Calculate number of elements in a table
-- Correctly manages zero indexed tables
-------------------------------------------
function table_len (t)
    local len = #t + 1
    if len == 1 and t[0] == nil then
        len = 0
    end
    return len
end
 
-------------------------------------------
-- Reverse a table
-------------------------------------------
local function table_reverse (t)
    local r = {}
    local tl = table_len(t)
    for k,v in pairs(t) do
        r[tl - k - 1] = v
    end
    return r
end

-------------------------------------------
-- Print two dimensional arrays
-------------------------------------------
function print2d(t)
    for r = 0, table_len(t) - 1 do
        local str = ''
        for c = 0, table_len(t[r]) - 1 do
            local val = t[c][r] or 0 -- Codepunk: Changed to print in [x][y] direction
            val = math.round(val)
            if val == 0 then
                val = ' '
            end
            str = str .. val .. ' '
        end
        print(str)
    end
end

-- This represents a track node (each step)
local function newNode (posX, posY, distance, priority)
    node = {}
    node.posX = posX
    node.posY = posY
    node.distance = distance
    node.priority = priority
    -- Estimation function for the remaining distance to the goal.
    function node:estimate(destX, destY)
        local dx = destX - self.posX
        local dy = destY - self.posY
        -- Manhattan distance
        return mSqrt(dx * dx + dy * dy) --mAbs(dx) + mAbs(dy)
        --Euclidian Distance
        --return mSqrt(dx * dx + dy * dy)
    end
    function node:updatePriority(destX, destY)
        self.priority = self.distance + self:estimate(destX, destY) * 10 -- A*
    end
    function node:nextMove()
        --  give higher priority to going straight instead of diagonally
        --if dirs == 8 and d % 2 ~= 0 then
        --    self.distance = self.distance + 14
        --else
        self.distance = self.distance + 10
    end
    mt = { __lt =   function (a, b)
                        return { value = a.priority < b.priority }
                    end }
    setmetatable(node, mt)
 
    return node
end
 
-- A-star algorithm.
-- The path returned will be a table of directions and number of steps
-- @param the_map 2D table of the map representation, 0 means now way, 1 means a road. Tables are 0 indexed.
-- @param mapW number Width of the map
-- @param mapH number Height of the map
-- @param startX number Start point
-- @param startY number
-- @param targetX number End point
-- @param targetY number
-- @return table|mixed Path is returned or false if no path is found
function _M.pathFind(the_map, mapW, mapH, startX, startY, targetX, targetY)
    -- Number of directions: 4 or 8
    local dirs = 4
    local dx = {}
    dx[0], dx[1], dx[2], dx[3] = 1, 0, -1, 0
    local dy = {}
    dy[0], dy[1], dy[2], dy[3] = 0, 1, 0, -1
    -- For 8 directions:
    -- dx = 1, 1, 0, -1, -1, -1, 0, 1
    -- dy = 0, 1, 1, 1, 0, -1, -1, -1
    local closed_nodes_map = {} -- map of closed (tried-out) nodes
    local open_nodes_map = {} -- map of open (not-yet-tried) nodes
    local dir_map = {} -- map of dirs
    local row = {}
    for i = 0, mapW - 1 do
        row[i] = 0
    end
 
    for i = 0, mapH - 1 do -- create 2d arrays
        closed_nodes_map[i] = {}
        open_nodes_map[i] = {}
        dir_map[i] = {}
        for j = 0, mapW - 1 do
            closed_nodes_map[i][j] = 0
            open_nodes_map[i][j] = 0
            dir_map[i][j] = 0
        end
    end
 
    local pq = {} -- priority queues of open (not-yet-tried) nodes
    pq[0] = newHeap()
    pq[1] = newHeap()
    local pqi = 0 -- priority queue index
    -- create the start node and push into list of open nodes
    local n0 = newNode(startX, startY, 0, 0)
    n0:updatePriority(targetX, targetY)
    pq[pqi]:push(n0)
    open_nodes_map[startY][startX] = n0.priority -- mark it on the open nodes map
    -- A* search
    while pq[pqi].len > 0 do
        -- get the current node w/ the highest priority
        -- from the list of open nodes
        local n1 = pq[pqi]:pop() -- top node
        local n0 = newNode(n1.posX, n1.posY, n1.distance, n1.priority)
        local x = n0.posX
        local y = n0.posY
        -- remove the node from the open list
        open_nodes_map[y][x] = 0
        closed_nodes_map[y][x] = 1 -- mark it on the closed nodes map
 
        -- quit searching when the goal is reached
        -- form direction table
        if x == targetX and y == targetY then
            -- generate the path from finish to start
            -- by following the dirs
            local path = {}
            local pathIndex = 0
            local function pathInsert (a_dir, dir_count)
                -- TODO: find a bug when zero count directions are inserted
                if dir_count then
                    local rev_dir -- reverse direction
                    if a_dir == 0 then rev_dir = 2 end
                    if a_dir == 1 then rev_dir = 3 end
                    if a_dir == 2 then rev_dir = 0 end
                    if a_dir == 3 then rev_dir = 1 end
                    local item = {dx = dx[rev_dir], dy = dy[rev_dir], count = dir_count}
                    path[pathIndex] = item
                    pathIndex = pathIndex + 1
                end
            end
 
            local prev_cur
            local dir_count = 0
            local cur_dir
            while not (x == startX and y == startY) do
                cur_dir = dir_map[y][x]
                if not prev_dir then prev_dir = cur_dir end
                if prev_dir ~= cur_dir then
                    pathInsert(prev_dir, dir_count)
                    dir_count = 0
                end
                dir_count = dir_count + 1
                prev_dir = cur_dir
                x = x + dx[cur_dir]
                y = y + dy[cur_dir]
            end
 
            pathInsert(cur_dir, dir_count)
            return table_reverse(path)
        end
        -- generate moves (child nodes) in all possible dirs
        for i = 0, dirs - 1 do
            local xdx = x + dx[i]
            local ydy = y + dy[i]
            if not (xdx < 0 or xdx >= mapW or ydy < 0 or ydy >= mapH or the_map[xdx][ydy] ~= 1 or closed_nodes_map[ydy][xdx] == 1) then
                -- generate a child node
                local m0 = newNode(xdx, ydy, n0.distance, n0.priority)
                m0:nextMove(dirs, i)
                m0:updatePriority(targetX, targetY)
                -- if it is not in the open list then add into that
                if open_nodes_map[ydy][xdx] == 0 then
                    open_nodes_map[ydy][xdx] = m0.priority
                    pq[pqi]:push(m0)
                    -- mark its parent node direction
                    dir_map[ydy][xdx] = (i + dirs / 2) % dirs
                elseif open_nodes_map[ydy][xdx] > m0.priority then
                    -- update the priority
                    open_nodes_map[ydy][xdx] = m0.priority
                    -- update the parent direction
                    dir_map[ydy][xdx] = (i + dirs / 2) % dirs
                    -- replace the node
                    -- by emptying one pq to the other one
                    -- except the node to be replaced will be ignored
                    -- and the new node will be pushed in instead
                    while pq[pqi][0] and not (pq[pqi][0].posX == xdx and pq[pqi][0].posY == ydy) do
                        pq[1 - pqi]:push(pq[pqi]:pop())
                    end
                    pq[pqi]:pop() -- remove the target node
                    -- empty the larger size priority queue to the smaller one
                    if pq[pqi].len > pq[1 - pqi].len then
                        pqi = 1 - pqi
                    end
                    while pq[pqi].len > 0 do
                        pq[1-pqi]:push(pq[pqi]:pop())
                    end
                    pqi = 1 - pqi
                    pq[pqi]:push(m0) -- add the better node instead
                end
            end
        end
    end
    return false -- if no route found
end

return _M