module(..., package.seeall)

local rss = require("rss")

function new()
    local rssGroup = display.newGroup()
    return rssGroup
end

function downloadFeed(rssGroup, url, statusCallback, errorCallback)
    cleanDocumentsDirectory()
    rssGroup.statusCallback = statusCallback
    rssGroup.errorCallback = errorCallback
    
    network.download( url, "GET", function(event) onNetworkStatus(event, rssGroup) end, "rss2.xml", system.DocumentsDirectory )
end

function onNetworkStatus(event, rssGroup)
    if ( event.isError ) then
        print("Error downloading feed")
        rssGroup.errorCallback()
    else
        parseFeed(rssGroup)
    end
end

function parseFeed(rssGroup)    
    rssGroup.stories = {}

    rssGroup.stories = rss.feed("rss2.xml", system.DocumentsDirectory)
    
    if rssGroup.statusCallback ~= nil then
        local status = {event = "RSSDownloaded", stories = #rssGroup.stories}
        rssGroup.statusCallback(status)
    end
    
    for i = 1, #rssGroup.stories do
        parseStory(rssGroup, rssGroup.stories[i], i)
    end
end

function parseStory(rssGroup, story, index)
    story.rssImage = "rssImage" .. index .. ".png"
    network.download( story.mediaContent, "GET", function(event) onImageDownloaded(event, rssGroup, story) end, story.rssImage, system.DocumentsDirectory )
end

function onImageDownloaded(event, rssGroup, story)
    if event.isError then
        if rssGroup.errorCallback ~= nil then
            rssGroup.errorCallback()
        end
    else
        local status = {event = "RSSImageDownloaded"}
        rssGroup.statusCallback(status)
    end
end

function getStories(rssGroup)
    return rssGroup.stories
end

function cleanDocumentsDirectory()
    local destDir = system.DocumentsDirectory
    local loop = true
    local index = 1
    
    while loop == true do
        local results, reason = os.remove(system.pathForFile( "rssImage" .. index .. ".png", destDir  ))

        if results then
            index = index + 1
        else
            loop = false
        end
    end
end