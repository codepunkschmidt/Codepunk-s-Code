module(..., package.seeall)

function new(totalUnits, x, y, totalWidth)
    local progressBarGroup = display.newGroup()
    
    progressBarGroup.totalUnits = totalUnits
    progressBarGroup.totalWidth = totalWidth
    progressBarGroup.curUnit = 0;

    progressBarGroup.progressBar = display.newImage("progressBar.png", x, y)
    progressBarGroup.progressBar.width = 1

    progressBarGroup.progressBar:setReferencePoint(display.CenterLeftReferencePoint)
    progressBarGroup.progressBar.x = x
    progressBarGroup.progressBar.y = y
    
    progressBarGroup:insert(progressBarGroup.progressBar)

    return progressBarGroup
end

function increment(progressBarGroup)
    local curX = progressBarGroup.progressBar.x
    progressBarGroup.curUnit = progressBarGroup.curUnit + 1
    progressBarGroup.progressBar.width = (progressBarGroup.totalWidth / progressBarGroup.totalUnits) * progressBarGroup.curUnit
    progressBarGroup.progressBar:setReferencePoint(display.CenterLeftReferencePoint)
    progressBarGroup.progressBar.x = curX
end
