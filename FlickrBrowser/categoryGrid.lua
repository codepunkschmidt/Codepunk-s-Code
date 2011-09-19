module(..., package.seeall)

local cButtonPadding = 32
local cButtonPaddingTop = 40
local cButtonWidth = 64
local cButtonHeight = 64
local maxColumns = 4

function new(categories, selectedCallback)
    local categoryGridGroup = display.newGroup()

    for i = 1,#categories do
        local gridButton = createGridButton(categories[i], selectedCallback)
        gridButton:setReferencePoint(display.TopLeftReferencePoint)
        gridButton.x = (((i - 1) % maxColumns) * cButtonWidth) + (((i - 1) % maxColumns) * cButtonPadding)
        gridButton.y = math.floor((i - 1) / maxColumns) * cButtonHeight + math.floor((i - 1) / maxColumns) * cButtonPadding + cButtonPaddingTop
        
        local gridButtonText = display.newText(categories[i].name, 0, 0, native.systemFont, 16)
        gridButtonText.x = gridButton.x + cButtonWidth / 2
        gridButtonText.y = gridButton.y + cButtonHeight + gridButtonText.height / 2
        categoryGridGroup:insert(gridButton)
        categoryGridGroup:insert(gridButtonText)
    end
    
    categoryGridGroup.title = display.newText("Select a category", 0, 0, native.systemFont, 32)
    categoryGridGroup.title:setReferencePoint(display.CenterReferencePoint)
    categoryGridGroup.title.x = categoryGridGroup.width / 2
    categoryGridGroup.title.y = categoryGridGroup.title.height / 2
    categoryGridGroup:insert(categoryGridGroup.title)

    categoryGridGroup.x = (display.contentWidth - categoryGridGroup.width) / 2

    return categoryGridGroup
end

function createGridButton(category, selectedCallback)
    local gridButton = display.newImage(category.image)
    gridButton.category = category
    gridButton.selectedCallback = selectedCallback
    gridButton.xScale = cButtonWidth / gridButton.width
    gridButton.yScale = cButtonHeight / gridButton.height
    
    gridButton:addEventListener("touch", function(event) onGridButtonTouched(event, gridButton) end)
    return gridButton
end

function onGridButtonTouched(event, gridButton)
    if event.phase == "ended" then
        gridButton.selectedCallback(gridButton.category)
    end
end