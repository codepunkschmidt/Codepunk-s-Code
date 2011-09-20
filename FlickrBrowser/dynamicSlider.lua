module(..., package.seeall)

local titleBar = require("titleBar")

function new(stories)
    local sliderGroup = display.newGroup()
    local sliderImagesGroup = display.newGroup()
    sliderGroup.imageContainer = sliderImagesGroup
    
    sliderGroup.prevImage = nil
    sliderGroup.curImage = nil
    sliderGroup.nextImage = nil
    
    sliderGroup.stories = stories
    sliderGroup.curStoryIndex = 1
    
    sliderGroup.background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
    sliderGroup.background:setFillColor(0, 0, 0)
    sliderGroup:insert(sliderGroup.background)
    sliderGroup:insert(sliderGroup.imageContainer)
    
    sliderGroup.titleBar = titleBar.new()
    titleBar.setTitle(sliderGroup.titleBar, sliderGroup.stories[1].title)
    sliderGroup.titleBar.isVisible = false
    sliderGroup:insert(sliderGroup.titleBar)

    createImages(sliderGroup)

    sliderGroup.background:addEventListener("touch", function(event) onSliderTouched(event, sliderGroup) end)

    return sliderGroup
end

function onSliderTouched(event, sliderGroup)
    if event.phase == "began" then
        display.getCurrentStage():setFocus( sliderGroup.background )
        sliderGroup.background.isFocus = true
        
        sliderGroup.startPos = event.x
        sliderGroup.prevPos = event.x
    elseif sliderGroup.background.isFocus then
        if event.phase == "moved" then
            local delta = event.x - sliderGroup.prevPos
            sliderGroup.prevPos = event.x
            
            sliderGroup.curImage.x = sliderGroup.curImage.x + delta
            sliderGroup.prevImage.x = sliderGroup.prevImage.x + delta
            sliderGroup.nextImage.x = sliderGroup.nextImage.x + delta
        elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
            dragDistance = event.x - sliderGroup.startPos

            if dragDistance > -10 and dragDistance < 10 then
                focusOnCurImage(sliderGroup)
                sliderGroup.titleBar.isVisible = not sliderGroup.titleBar.isVisible
            elseif dragDistance < -100 then
                focusOnNextImage(sliderGroup)
            elseif dragDistance > 100 then
                focusOnPrevImage(sliderGroup)
            else
                focusOnCurImage(sliderGroup)
            end

            display.getCurrentStage():setFocus( nil )
            sliderGroup.background.isFocus = false
        end
    end
end

function focusOnPrevImage(sliderGroup)
    display.remove(sliderGroup.nextImage)
    transition.to(sliderGroup.curImage, {time = 400, x = display.contentWidth + display.contentWidth / 2, transition = easing.outExpo })
    transition.to(sliderGroup.prevImage, {time = 400, x = display.contentWidth / 2, transition = easing.outExpo })
    
    sliderGroup.curStoryIndex = sliderGroup.curStoryIndex - 1
    
    if sliderGroup.curStoryIndex < 1 then
        sliderGroup.curStoryIndex = #sliderGroup.stories
    end
    
    titleBar.setTitle(sliderGroup.titleBar, sliderGroup.stories[sliderGroup.curStoryIndex].title)
    sliderGroup.nextImage = sliderGroup.curImage
    sliderGroup.curImage = sliderGroup.prevImage
    createPrevImage(sliderGroup)
end

function focusOnNextImage(sliderGroup)
    display.remove(sliderGroup.prevImage)
    
    transition.to( sliderGroup.curImage, {time = 400, x = -display.contentWidth / 2, transition = easing.outExpo } )
    transition.to(sliderGroup.nextImage, {time = 400, x = display.contentWidth / 2, transition = easing.outExpo } )
    
    sliderGroup.curStoryIndex = sliderGroup.curStoryIndex + 1
    
    if sliderGroup.curStoryIndex > #sliderGroup.stories then
        sliderGroup.curStoryIndex = 1
    end
    
    titleBar.setTitle(sliderGroup.titleBar, sliderGroup.stories[sliderGroup.curStoryIndex].title)

    sliderGroup.prevImage = sliderGroup.curImage
    sliderGroup.curImage = sliderGroup.nextImage
    createNextImage(sliderGroup)    
end

function focusOnCurImage(sliderGroup)
    transition.to( sliderGroup.curImage, {time = 400, x = display.contentWidth / 2, transition = easing.outExpo } )
    transition.to( sliderGroup.prevImage, {time = 400, x = -display.contentWidth / 2, transition = easing.outExpo } )
    transition.to( sliderGroup.nextImage, {time = 400, x = display.contentWidth + display.contentWidth / 2, transition = easing.outExpo } )
end

function createPrevImage(sliderGroup)
    sliderGroup.prevImage = getStoryImage(sliderGroup, sliderGroup.curStoryIndex - 1, -display.contentWidth / 2, display.contentHeight / 2)
    sliderGroup.imageContainer:insert(sliderGroup.prevImage)
end

function createNextImage(sliderGroup)
    sliderGroup.nextImage = getStoryImage(sliderGroup, sliderGroup.curStoryIndex + 1, display.contentWidth + display.contentWidth / 2, display.contentHeight / 2)
    sliderGroup.imageContainer:insert(sliderGroup.nextImage)
end

function createImages(sliderGroup)
    cleanImages(sliderGroup)
    
    sliderGroup.prevImage = getStoryImage(sliderGroup, sliderGroup.curStoryIndex - 1, -display.contentWidth / 2, display.contentHeight / 2)
    sliderGroup.curImage = getStoryImage(sliderGroup, sliderGroup.curStoryIndex, display.contentWidth / 2, display.contentHeight / 2)
    sliderGroup.nextImage = getStoryImage(sliderGroup, sliderGroup.curStoryIndex + 1, display.contentWidth + display.contentWidth / 2, display.contentHeight / 2)
    
    sliderGroup.imageContainer:insert(sliderGroup.prevImage)
    sliderGroup.imageContainer:insert(sliderGroup.curImage)
    sliderGroup.imageContainer:insert(sliderGroup.nextImage)
end

function getStoryImage(sliderGroup, index, x, y)
    if index < 1 then
        index = #sliderGroup.stories
    elseif index > #sliderGroup.stories then
        index = 1
    end

    local image = display.newImage(sliderGroup.stories[index].rssImage, system.DocumentsDirectory)
    image.xScale = display.contentWidth / image.width
    image.yScale = display.contentHeight / image.height

    image.x = x
    image.y = y
    
    return image
end

function cleanImages(sliderGroup)
    cleanImage(sliderGroup.prevImage)
    cleanImage(sliderGroup.curImage)
    cleanImage(sliderGroup.nextImage)
end

function cleanImage(image)
    if image ~= nil then
        display.remove(image)
        image = nil
    end
end