module(..., package.seeall)

function perform(object)
    object.x = math.random(1, display.contentWidth)
    object.y = -20
    object.rotation = math.random(45,90)
end