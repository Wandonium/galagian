--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:cd6869477d3752ab63b22ae488fc763a:cfed15c62d128eb1c367a48f53ba6599:1deb9ce6555e1e693cffab414c966f36$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- barmultiply
            x=1,
            y=1,
            width=100,
            height=11,

        },
    },
    
    sheetContentWidth = 102,
    sheetContentHeight = 13
}

SheetInfo.frameIndex =
{

    ["barmultiply"] = 1,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
