--
-- rss_feed.lua
-- Copyright © 2011 Omnigeek Media. All Rights Reserved.
--
-- takes a rss feed and returns you a table of stories.
--

module(..., package.seeall)

local xml = require( "xml" ).newParser()

function feed(filename, base)
    rssFile = "index.rss"
    if filename then
        rssFile = filename
    end
    baseDir = system.DocumentsDirectory
    if base then
        baseDir = base
    end
    
    local stories = {}
    --print("Parsing the feed")
    local myFeed = xml:loadFile(rssFile, baseDir)
    local items = myFeed.child[1].child
    -- utility.print_r(items)
    local i
    --print("Number of items: " .. #items)
    local l = 1
    for i = 1, #items do
        local item = items[i]
        local enclosuers = {}
        local e = 1
        local story = {}
        story.categories = {}
    
        if item.name == "item" then -- we have a story batman!
            -- utility.print_r(item.child)
            local j
            for j = 1, #item.child do
                if item.child[j].name == "title" then
                    story.title = item.child[j].value
                end
                if item.child[j].name == "link" then
                    story.link = item.child[j].value
                end
                if item.child[j].name == "pubDate" then
                    story.pubDate = item.child[j].value
                end
                if item.child[j].name == "description" then
                    story.description = item.child[j].value
                end
                if item.child[j].name == "dc:creator" then
                    story.dc_creator = item.child[j].value
                end
                if item.child[j].name == "guid" then
                    story.guid = item.child[j].value
                end
                if item.child[j].name == "media:content" then
                    story.mediaContent = item.child[j].properties["url"]
                end
                if item.child[j].name == "category" then
                    story.categories[#story.categories + 1] = item.child[j].value
                end
                -- Podcast's we have to handle differently
                if item.child[j].name == "content:encoded" then
                    -- get the story body
                    --[[
                    print(item.child[j].value)
                    bodytag = {}
                    bodytag = item.child[j].child
                    local p;
                    story.content_encoded = ""
                    for p = 1, #bodytag do
                        if (bodytag[p].value) then
                            story.content_encoded = story.content_encoded .. bodytag[p].value .. "\n\n"
                        end
                    end
                    ]]--
                    story.content_encoded = item.child[j].value
                end
                if item.child[j].name == "enclosure" then
                    local properties = {}
                    properties = item.child[j].properties
                    enclosuers[e] = properties
                    --utility.print_r(properties)
                    e = e + 1
                end
            end
            --utility.print_r(story)
            stories[l] = {}
            stories[l].link = story.link
            stories[l].title = story.title
            stories[l].pubDate = story.pubDate
            stories[l].description = story.description
            stories[l].dc_creator = story.dc_creator
            stories[l].guid = story.guid
            stories[l].comments = story.comments
            stories[l].content_encoded = story.content_encoded
            stories[l].enclosures = enclosuers
            stories[l].categories = story.categories
            stories[l].mediaContent = story.mediaContent
            l = l + 1
        end
    end
    return stories
end