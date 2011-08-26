-- A* pathfinding module
-- Author: Lerg
-- Release date: 2011-08-25
-- Version: 1.0
-- License: MIT
-- Based on the python implementation.
-- Requires my utils module, in particular newHeap(), table_len() and table_reverse() functions
--
-- USAGE:
--   Import this module and use pathFind() function. Map should be zero indexed (first element index is zero).
_M = {}
 
local mAbs = math.abs
local mSqrt = math.sqrt
 
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
                    while not (pq[pqi][0].posX == xdx and pq[pqi][0].posY == ydy) do
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