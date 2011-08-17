module(..., package.seeall)

function get()
    local definitions = 
    {
        objects = 
        {
            {
                name = "Gas Can",
                image = "images/gasCan.png",
                imageSize = { width = 32, height = 43 },
                physicsDataFile = "gasCanPhysics",
                positionMethod = "top"
            },
            {
                name = "Old Lady",
                image = "images/oldLady.png",
                physicsDataFile = "oldLadyPhysics",
                positionMethod = "top"
            },
            {
                name = "Road Barrel",
                image = "images/roadBarrell.png",
                physicsDataFile = "roadBarrelPhysics",
                positionMethod = "top"
            },
            {
                name = "Road Block",
                image = "images/roadBlock.png",
                physicsDataFile = "roadBlockPhysics",
                positionMethod = "top"
            },
            {
                name = "Wrench",
                image = "images/wrench.png",
                physicsDataFile = "wrenchPhysics",
                positionMethod = "top"
            }
        }
    }
    return definitions
end

