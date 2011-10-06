display.setStatusBar(display.HiddenStatusBar)

require("pprint")
local pathfinder = require("pathfinder")

-- constants to fiddle with
local kRoadProbability = 6 -- number between 0 and 10 with 10 being a lot of roads and 0 being none
local kLevelRows = 50
local kLevelCols = 50

-- our map to be generated --
local level = {}

-- table contains display.newRect objects --
local cells = {}

-- walks on the path
local walker

-- starting and ending cells to be selected by user --
local startCell = {col = -1, row = -1}
local endCell = {col = -1, row = -1}

-- contains text object for user intructions --
local instructions = nil

-- controls program flow --
local curGameFunction = nil

local cellWidth = display.contentWidth / kLevelCols
local cellHeight = display.contentHeight / kLevelRows

-- builds our grid --
function buildGrid()
    -- build map array --
    for x = 0, kLevelCols do
        level[x] = {}
        for y = 0, kLevelRows do
            local probability = math.random(0,10)
            if probability <= kRoadProbability then
                level[x][y] = 1
            else
                level[x][y] = 0
            end
        end
    end

    -- build screen now --
    for x = 0, kLevelCols do
        for y = 0, kLevelRows do
            local cell = display.newRect(x*cellWidth, y*cellHeight, cellWidth, cellHeight)
            cell.strokeWidth = 1
            cell:setStrokeColor(0,0,0)
            if level[x][y] == 0 then
                cell:setFillColor(255, 0, 0)
            end
            
            if cells[x] == nil then
                cells[x] = {}
            end
            
            cells[x][y] = cell
        end
    end

    print2d(level)
end

-- called to select the starting point in the grid --
function onStartCellSelected(event)
    local indices = getIndices(event.x, event.y)

    if level[indices[1]][indices[2]] == 0 then
        displayInstructions("Cannot select red. Try again")
    else
        startCell.col = indices[1]
        startCell.row = indices[2]
        displayInstructions("Select the ending cell")
        colorCell(getCell(event.x, event.y), 0, 255, 0)
        curGameFunction = function(event) onEndCellSelected(event) end
    end
end

-- called to select the ending point in the grid --
function onEndCellSelected(event)
    local indices = getIndices(event.x, event.y)

    if level[indices[1]][indices[2]] == 0 then
        displayInstructions("Cannot select red. Try again")
    else
        endCell.col = indices[1]
        endCell.row = indices[2]
        colorCell(getCell(event.x, event.y), 0, 0, 255)
        displayInstructions("Touch anywhere to see A* go")
        curGameFunction = function(event) onDetermineAStar(event) end
    end
end

function newWalker(path)
    local walker = display.newCircle((startCell.col + 0.5) * cellWidth, (startCell.row + 0.5) * cellHeight, cellWidth)
    walker.strokeWidth = 1
    walker:setStrokeColor(0,0,0)
    walker:setFillColor(0, 255, 255)
    walker.pathIndex = 0
    walker.pathLen = table_len(path)
    walker.speed = 50
    
    function walker:go()
        if self.pathIndex < self.pathLen then
            local dir = path[self.pathIndex]
            self.transition = transition.to(self, { time = self.speed * dir.count,
                                                    x = self.x + dir.dx * dir.count * cellWidth,
                                                    y = self.y + dir.dy * dir.count * cellHeight,
                                                    onComplete = function () self:go() end})
        end
        self.pathIndex = self.pathIndex + 1
    end
    
    return walker
end

-- called to get the A* algorithm going --
function onDetermineAStar(event)
    displayInstructions("")

    -- run A* --
    local path = pathfinder.pathFind(level, kLevelCols, kLevelRows, startCell.col, startCell.row, endCell.col, endCell.row)
    pprint("Path", path)
    
    if path ~= false then
        -- color the path --
        local currentCell = {x=startCell.col, y=startCell.row}
    
        for k = 0, #path do
            local cellDirectionX = path[k].dx
            local cellDirectionY = path[k].dy
            local count = path[k].count
    
            for l = 1, count do
                currentCell.x = currentCell.x + cellDirectionX
                currentCell.y = currentCell.y + cellDirectionY
                if currentCell.x ~= endCell.col or currentCell.y ~= endCell.row then
                    colorCell(cells[currentCell.x][currentCell.y], 255, 255, 0)
                end
            end
        end
        
        -- create a moving object
        walker = newWalker(path)
        walker:go()
        
        curGameFunction = function(event) onEnd(event) end
    else
        displayInstructions("Suitable path not found")
        curGameFunction = function(event) onEnd(event) end
    end
end

-- called when the demonstration ends (resets the grid) --
function onEnd(event)
    for x = 0, kLevelCols do
        for y = 0, kLevelRows do
            cells[x][y]:removeSelf()
        end
    end
    
    cells = {}
    
    if walker then
        walker:removeSelf()
        walker = nil
    end
    
    buildGrid()
    displayInstructions("Select the starting cell")
    curGameFunction = function(event) onStartCellSelected(event) end
end

-- returns table containing index values based on where a user clicked on the grid --
function getIndices(x, y)
    return {math.floor(x / cellWidth), math.floor(y / cellHeight)}
end

-- gets the display.newRect object based on x,y value --
function getCell(x, y)
    local indices = getIndices(x, y)
    return cells[indices[1]][indices[2]]
end

-- colors a cell on the grid --
function colorCell(cell, red, green, blue)
    cell:setFillColor(red, green, blue)
end

-- displays instructions (albeit hard to read) to the user
function displayInstructions(string)
    if instructions ~= nil then
        instructions:removeSelf()
    end

    instructions = display.newText(string, 0, 0, native.systemFontBold, 20)
    instructions:setTextColor(0, 0, 0)
end

-- Touch handler. Delegates call to current selected game function --
function onBoardTouched(event)
    if event.phase == "began" then
        curGameFunction(event)
    end
end

-- gets the ball rolling --
curGameFunction = function(event) onStartCellSelected(event) end
buildGrid()
displayInstructions("Select the starting cell")
Runtime:addEventListener("touch", onBoardTouched)