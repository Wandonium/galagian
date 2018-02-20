--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:31526f55c3748fd1ad9160a8e2b481d8:8f6559e98018c0fe851a91f188904e11:442614e757f594e81bd096adc7e0d085$
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
            -- boom01
            x=1,
            y=1,
            width=250,
            height=204,

            sourceX = 0,
            sourceY = 2,
            sourceWidth = 250,
            sourceHeight = 250
        },
        {
            -- boom02
            x=1,
            y=413,
            width=250,
            height=202,

            sourceX = 0,
            sourceY = 4,
            sourceWidth = 250,
            sourceHeight = 250
        },
        {
            -- boom03
            x=1,
            y=207,
            width=250,
            height=204,

            sourceX = 0,
            sourceY = 2,
            sourceWidth = 250,
            sourceHeight = 250
        },
        {
            -- boom04
            x=1,
            y=617,
            width=250,
            height=202,

            sourceX = 0,
            sourceY = 3,
            sourceWidth = 250,
            sourceHeight = 250
        },
        {
            -- boom05
            x=253,
            y=205,
            width=248,
            height=202,

            sourceX = 2,
            sourceY = 3,
            sourceWidth = 250,
            sourceHeight = 250
        },
        {
            -- boom06
            x=253,
            y=409,
            width=248,
            height=202,

            sourceX = 2,
            sourceY = 3,
            sourceWidth = 250,
            sourceHeight = 250
        },
        {
            -- boom07
            x=253,
            y=1017,
            width=250,
            height=198,

            sourceX = 0,
            sourceY = 3,
            sourceWidth = 250,
            sourceHeight = 250
        },
        {
            -- boom08
            x=1,
            y=821,
            width=250,
            height=202,

            sourceX = 0,
            sourceY = 3,
            sourceWidth = 250,
            sourceHeight = 250
        },
        {
            -- boom09
            x=253,
            y=1,
            width=250,
            height=202,

            sourceX = 0,
            sourceY = 3,
            sourceWidth = 250,
            sourceHeight = 250
        },
        {
            -- boom10
            x=253,
            y=613,
            width=250,
            height=200,

            sourceX = 0,
            sourceY = 3,
            sourceWidth = 250,
            sourceHeight = 250
        },
        {
            -- boom11
            x=253,
            y=815,
            width=242,
            height=200,

            sourceX = 8,
            sourceY = 2,
            sourceWidth = 250,
            sourceHeight = 250
        },
    },
    
    sheetContentWidth = 504,
    sheetContentHeight = 1216
}

SheetInfo.frameIndex =
{

    ["boom01"] = 1,
    ["boom02"] = 2,
    ["boom03"] = 3,
    ["boom04"] = 4,
    ["boom05"] = 5,
    ["boom06"] = 6,
    ["boom07"] = 7,
    ["boom08"] = 8,
    ["boom09"] = 9,
    ["boom10"] = 10,
    ["boom11"] = 11,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
