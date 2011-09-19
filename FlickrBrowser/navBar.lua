module(..., package.seeall)

function new()
    local navBarGroup = display.newGroup()
    return navBarGroup
end

function setTitle(navBarGroup, title)
    if navBarGroup.titleGroup ~= nil then
        display.remove(navBarGroup.titleGroup)
    end
    
    navBarGroup.titleGroup = createTitleGroup(title)
    navBarGroup:insert(navBarGroup.titleGroup)
end

function createTitleGroup(title)
    local titleGroup = display.newGroup()
    
    local titleBackground = display.newImage("tabBar.png", 0, 0)
    titleBackground.alpha = 0.5
    titleGroup:insert(titleBackground)

    if title == nil then
        title = "No Title"
    end
    
    local title = display.newText(title, 0, 0, native.systemFont, 24)
    title:setReferencePoint(display.CenterReferencePoint)
    title.x = display.contentWidth / 2
    title.y = titleBackground.height / 2
    titleGroup:insert(title)
    
    return titleGroup
end