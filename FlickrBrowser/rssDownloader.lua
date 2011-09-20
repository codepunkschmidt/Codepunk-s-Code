module(..., package.seeall)

local rss = require("rss")

function new()
    local rssObject = {}
    return rssObject
end

function downloadFeed(rssObject, url, statusCallback, errorCallback)
    cleanDocumentsDirectory()
    rssObject.statusCallback = statusCallback
    rssObject.errorCallback = errorCallback
    
    network.download( url, "GET", function(event) onNetworkStatus(event, rssObject) end, "rss2.xml", system.DocumentsDirectory )
end

function onNetworkStatus(event, rssObject)
    if ( event.isError ) then
        rssObject.errorCallback()
    else
        parseFeed(rssObject)
    end
end

function parseFeed(rssObject)    
    rssObject.stories = {}

    rssObject.stories = rss.feed("rss2.xml", system.DocumentsDirectory)
    
    if rssObject.statusCallback ~= nil then
        local status = {event = "RSSDownloaded", stories = #rssObject.stories}
        rssObject.statusCallback(status)
    end
    
    for i = 1, #rssObject.stories do
        parseStory(rssObject, rssObject.stories[i], i)
    end
end

function parseStory(rssObject, story, index)
    story.rssImage = "rssImage" .. index .. ".png"
    network.download( story.mediaContent, "GET", function(event) onImageDownloaded(event, rssObject, story) end, story.rssImage, system.DocumentsDirectory )
end

function onImageDownloaded(event, rssObject, story)
    if event.isError then
        if rssObject.errorCallback ~= nil then
            rssObject.errorCallback()
        end
    else
        local status = {event = "RSSImageDownloaded"}
        rssObject.statusCallback(status)
    end
end

function getStories(rssObject)
    return rssObject.stories
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