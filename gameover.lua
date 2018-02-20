
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoTitle()
	composer.gotoScene("title")
end


-- configure image sheet:
local sheetInfo = require("galagianSprite")
local objectSheet = graphics.newImageSheet("galagianSprite.png",
	sheetInfo:getSheet())

local _W = display.contentWidth
local _H = display.contentHeight

-- initializing variables:

local scoreTable = {}
local button
local barMultiplier
local score = 0
local lives = 4
local multiplier = 0
local wave = 1

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- load background:
	local background = display.newImageRect(sceneGroup, objectSheet,
		sheetInfo:getFrameIndex("bg"), 500, 1500)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local background2 = display.newImageRect(sceneGroup, objectSheet,
		sheetInfo:getFrameIndex("bg"), 500, 1500)
	background2.x = display.contentCenterX
	background2.y = background.y + 1500

	-- make background scroll vertically:
	local function scrollBackground()
		local yOffset = 2

		background.y = background.y + yOffset
		background2.y = background2.y + yOffset

		if(background.y + background.contentWidth) > 1800 then
			background:translate(0, -3000)
		end

		if(background2.y + background2.contentWidth) > 1800 then
			background2:translate(0, -3000)
		end
	end

	Runtime:addEventListener("enterFrame", scrollBackground)

	-- adding title screen:
	local gameoverScreen = display.newImage(sceneGroup, objectSheet,
		sheetInfo:getFrameIndex("GameOver"),496, 110)
	gameoverScreen.x = display.contentCenterX
	gameoverScreen.y = 200
	gameoverScreen:scale(0.6, 0.99)

	local message = display.newText("SCORESS NO LONGER WORK SORRY.",
		170, 230, "font.ttf", 13)

	local widget = require( "widget")

	local function handleButtonEvent(event)
		if ("ended" == event.phase) then
			display.remove(message)
			button:removeSelf()
			message = nil
			button = nil
			--gotoTitle()
			os.exit()
		end
	end

	button = widget.newButton(
		{
			label = "CLOSE",
			labelColor = { default={1,1,1}, over={1,1,1,1}},
			onEvent = handleButtonEvent,
			emboss = true,
			-- properties for a rounded rectangle button:
			shape = "roundedRect",
			width = 100,
			height = 40,
			cornerRadius = 2,
			font = "font.ttf",
			fillColor = { default={0,0,0,0}, over={0,0,0,0} },
			strokeColor = { default={1,1,1}, over={1,1,1} },
			strokeWidth = 2
		}
	)

	button.x = 250
	button.y = message.y + 50

	-- adding hud at bottom of screen:
	local hud = display.newImageRect(sceneGroup, objectSheet,
		sheetInfo:getFrameIndex("hud"), 320, 30)
	hud.y = _H+30
	hud.x = _W/2


	--handling player lives:
	local livesImage1 = display.newImageRect(sceneGroup, objectSheet,
		sheetInfo:getFrameIndex("life"), 34, 32)
	livesImage1.x = 20
	livesImage1.y = hud.y
	livesImage1.myName = "liveImage1"

	local livesImage2 = display.newImageRect(sceneGroup, objectSheet,
		sheetInfo:getFrameIndex("life"), 34, 32)
	livesImage2.x = 30
	livesImage2.y = hud.y
	livesImage2.myName = "liveImage2"

	local livesImage3 = display.newImageRect(sceneGroup, objectSheet,
		sheetInfo:getFrameIndex("life"), 34, 32)
	livesImage3.x = 40
	livesImage3.y = hud.y
	livesImage3.myName = "liveImage3"

	local livesTable = {livesImage1, livesImage2, livesImage3 }

	-- helper method for setting up score board:
	local function getScore(num)
		if(num == 0) then
			local zero = display.newImageRect(sceneGroup, objectSheet,
				sheetInfo:getFrameIndex("num0"), 13,18)
			return zero
		elseif(num == 1) then
			local one = display.newImageRect(sceneGroup, objectSheet,
				sheetInfo:getFrameIndex("num1"), 12,18)
			return one
		elseif(num == 2) then
			local two = display.newImageRect(sceneGroup, objectSheet,
				sheetInfo:getFrameIndex("num2"), 12,18)
			return two
		elseif(num == 3) then
			local three = display.newImageRect(sceneGroup, objectSheet,
				sheetInfo:getFrameIndex("num3"), 11,18)
			return three
		elseif(num == 4) then
			local four = display.newImageRect(sceneGroup, objectSheet,
				sheetInfo:getFrameIndex("num4"), 12,18)
			return four
		elseif(num == 5) then
			local five = display.newImageRect(sceneGroup, objectSheet,
				sheetInfo:getFrameIndex("num5"), 13,18)
			return five
		elseif(num == 6) then
			local six = display.newImageRect(sceneGroup, objectSheet,
				sheetInfo:getFrameIndex("num6"), 12,18)
			return six
		elseif(num == 7) then
			local seven = display.newImageRect(sceneGroup, objectSheet,
				sheetInfo:getFrameIndex("num7"), 12,18)
			return seven
		elseif(num == 8) then
			local eight = display.newImageRect(sceneGroup, objectSheet,
				sheetInfo:getFrameIndex("num8"), 13,18)
			return eight
		elseif(num == 9) then
			local nine = display.newImageRect(sceneGroup, objectSheet,
				sheetInfo:getFrameIndex("num9"), 12,18)
			return nine
		end
	end

	-- load score board:
	local function scoreBoard()
		local num = getScore(0)
		num.x = 220
		num.y = -30
		xpos = num.x
		scoreTable[0] = num
		for i=1, 9, 1 do
			num = getScore(0)
			num.x = xpos-13
			num.y = -30
			xpos = num.x
			scoreTable[i] = num
		end

	end

	scoreBoard()

	-- general function for fitting images into predefined boxes:
	local function fitImage(displayObject, fitWidth, fitHeight, enlarge)
		--
		-- first determine which edge is out of bounds
		--
		local scaleFactor = fitHeight / displayObject.height
		local newWidth = displayObject.width * scaleFactor
		if newWidth > fitWidth then
			scaleFactor = fitWidth / displayObject.width
		end
		if not enlarge and scaleFactor > 1 then
			return
		end
		displayObject:scale( scaleFactor, scaleFactor)
	end


	-- handling hud objects:
	local function handleHud()
		barMultiplier = display.newImageRect(sceneGroup, "barmultiply.png",
			98, 8)
		barMultiplier.x = _W/2 - 23
		barMultiplier.y = hud.y-6
		local waveMultiplier = display.newImageRect(sceneGroup, objectSheet,
			sheetInfo:getFrameIndex("barshield"), 98, 8)
		waveMultiplier.x = _W/2 + 103
		waveMultiplier.y = hud.y-6

		-- setting up multiplier:
		multiplierImage = getScore(multiplier)
		multiplierImage.x = _W/2 + 25
		multiplierImage.y = _H + 38
		fitImage( multiplierImage, 12, 12, false)
		oldMimage = multiplierImage

		-- setting up wave:
		waveImage = getScore(wave)
		waveImage.x = _W - 15
		waveImage.y = _H + 38
		fitImage( waveImage, 12, 12, false)
		waveImage1 = getScore(0)
		waveImage1.x = _W - 23
		waveImage1.y = _H + 38
		fitImage( waveImage1, 12, 12, false)
		waveImage2 = getScore(0)
		waveImage2.x = _W - 32
		waveImage2.y = _H + 38
		fitImage( waveImage2, 12, 12, false)
	end

	handleHud()
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
