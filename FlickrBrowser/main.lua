display.setStatusBar( display.HiddenStatusBar ) --Hide status bar from the beginning
system.setIdleTimer( false ) -- turn off device sleeping

local rssDownloader = require("rssDownloader")
local dynamicSlider = require("dynamicSlider")
local progressBar = require("progressBar")
local categoryGrid = require("categoryGrid")

local baseUrl = "http://api.flickr.com/services/feeds/photos_public.gne?lang=en-us&format=rss_200&tags="

local mainGroup = display.newGroup()

function init()
    mainGroup.categorySelected = false
    mainGroup.backGround = display.newImage( "grass.png" )
    mainGroup:insert(mainGroup.backGround)
    
    local categories = {
        {
            name = "Corona",
            image = "icons/corona.png"
        },
        {
            name = "Zombies",
            image = "icons/zombie.png"
        },
        {
            name = "Video Games",
            image = "icons/Pacman.png"
        },
        {
            name = "Nature",
            image = "icons/nature.png"
        },
        {
            name = "Seattle",
            image = "icons/seattle.png"
        },
        {
            name = "Lua",
            image = "icons/lua.png"
        },
        {
            name = "Football",
            image = "icons/football.png"
        },
        {
            name = "Politics",
            image = "icons/politics.png"
        },
        {
            name = "Love",
            image = "icons/love.png"
        },
        {
            name = "Candy",
            image = "icons/candy.png"
        },
        {
            name = "Technology",
            image = "icons/technology.png"
        },
        {
            name = "Weather",
            image = "icons/weather.png"
        }
    }
    
    mainGroup.categoryGrid = categoryGrid.new(categories, function(category) onCategorySelected(category) end)
    mainGroup:insert(mainGroup.categoryGrid)
end

function onCategorySelected(category)
    if mainGroup.categorySelected == false then
        mainGroup.categorySelected = true
        mainGroup.rssDownloader = rssDownloader.new()
        rssDownloader.downloadFeed(mainGroup.rssDownloader, baseUrl .. category.name, onFeedDownloadStatus, onFeedDownloadError)
    end
end

function main()
    init()
end

function onFeedDownloadStatus(status)
    if status.event == "RSSDownloaded" then
        mainGroup.progressBar = progressBar.new(status.stories, 0, display.contentHeight - 5, display.contentWidth)
        mainGroup:insert(mainGroup.progressBar)
        mainGroup.numStories = status.stories
        mainGroup.curStoryIndex = 0
    else
        mainGroup.curStoryIndex = mainGroup.curStoryIndex + 1
        progressBar.increment(mainGroup.progressBar)
        if mainGroup.curStoryIndex == mainGroup.numStories then
            display.remove(mainGroup.categoryGrid)
            display.remove(mainGroup.progressBar)
            display.remove(mainGroup.backGround)
            mainGroup.imageSlider = dynamicSlider.new(rssDownloader.getStories(mainGroup.rssDownloader))
            mainGroup:insert(mainGroup.imageSlider)
        end
    end
end

function onFeedDownloadError()
    print("Error")
end

main()

