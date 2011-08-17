local physics = require( "physics" )
physics.setDrawMode("hybrid")
physics.start()

-- load out object definitions
local objects = require("objects")
local objectGroup = objects.get()

-- amount of time to spawn a new object
local kSpawnTime = 200

local sky = display.newImage( "images/bkg_clouds.png" )
sky.x = 160; sky.y = 195

local ground = display.newImage( "images/ground.png" )
ground.x = 160; ground.y = 445
physics.addBody( ground, "static", { friction=0.5, bounce=0.3 } )

-- start spawning
timer.performWithDelay(kSpawnTime, function() spawnNewObject(); end )

function spawnNewObject()
    -- get a random object from the object group
    local maxObjects = #objectGroup.objects
    local curObject = objectGroup.objects[math.random(1,maxObjects)]
    
    -- load object image
    local curObjectImage = display.newImage(curObject.image)
    
    -- load object physics data
    local physicsFile = require(curObject.physicsDataFile)
    local physicsData = physicsFile.physicsData(scaleFactor)
    physics.addBody( curObjectImage, physicsData:get("object") )

    -- call objects positioning method
    local positionFile = require(curObject.positionMethod)
    positionFile.perform(curObjectImage)
    
    -- spawn next object
    timer.performWithDelay(kSpawnTime, spawnNewObject )
end

