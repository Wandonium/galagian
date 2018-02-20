-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- loading the physics library:
local physics = require("physics")
physics.start()
physics.setGravity(0,0)

-- seeding random num generator:
math.randomseed(os.time())

-- configure image sheet:
local sheetInfo = require("galagianSprite")
local objectSheet = graphics.newImageSheet("galagianSprite.png",
	sheetInfo:getSheet())

-- initializing variables:
local died = false

local fighterTable = {}
local tm = {}
local scoreTable = {}
local meteorTable = {}
local meteorCount = {}

local ship
local fighter
local enemyShot
local barMultiplier
local score = 0
local lives = 4
local multiplier = 0
local wave = 1


local _W = display.contentWidth
local _H = display.contentHeight

-- setting display groups:
local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

-- load background:
local background = display.newImageRect(backGroup, objectSheet,
	sheetInfo:getFrameIndex("bg"), 500, 1500)
background.x = display.contentCenterX
background.y = display.contentCenterY

local background2 = display.newImageRect(backGroup, objectSheet,
	sheetInfo:getFrameIndex("bg"), 500, 1500)
background2.x = display.contentCenterX
background2.y = background.y + 1500


-- adding hud at bottom of screen:
local hud = display.newImageRect(uiGroup, objectSheet,
	sheetInfo:getFrameIndex("hud"), 320, 30)
hud.y = _H+30
hud.x = _W/2


--handling player lives:
local livesImage1 = display.newImageRect(uiGroup, objectSheet,
	sheetInfo:getFrameIndex("life"), 34, 32)
livesImage1.x = 20
livesImage1.y = hud.y
livesImage1.myName = "liveImage1"

local livesImage2 = display.newImageRect(uiGroup, objectSheet,
	sheetInfo:getFrameIndex("life"), 34, 32)
livesImage2.x = 30
livesImage2.y = hud.y
livesImage2.myName = "liveImage2"

local livesImage3 = display.newImageRect(uiGroup, objectSheet,
	sheetInfo:getFrameIndex("life"), 34, 32)
livesImage3.x = 40
livesImage3.y = hud.y
livesImage3.myName = "liveImage3"

local livesTable = {livesImage1, livesImage2, livesImage3 }

-- helper method for setting up score board:
local function getScore(num)
	if(num == 0) then
		local zero = display.newImageRect(uiGroup, objectSheet,
			sheetInfo:getFrameIndex("num0"), 13,18)
		return zero
	elseif(num == 1) then
		local one = display.newImageRect(uiGroup, objectSheet,
			sheetInfo:getFrameIndex("num1"), 12,18)
		return one
	elseif(num == 2) then
		local two = display.newImageRect(uiGroup, objectSheet,
			sheetInfo:getFrameIndex("num2"), 12,18)
		return two
	elseif(num == 3) then
		local three = display.newImageRect(uiGroup, objectSheet,
			sheetInfo:getFrameIndex("num3"), 11,18)
		return three
	elseif(num == 4) then
		local four = display.newImageRect(uiGroup, objectSheet,
			sheetInfo:getFrameIndex("num4"), 12,18)
		return four
	elseif(num == 5) then
		local five = display.newImageRect(uiGroup, objectSheet,
			sheetInfo:getFrameIndex("num5"), 13,18)
		return five
	elseif(num == 6) then
		local six = display.newImageRect(uiGroup, objectSheet,
			sheetInfo:getFrameIndex("num6"), 12,18)
		return six
	elseif(num == 7) then
		local seven = display.newImageRect(uiGroup, objectSheet,
			sheetInfo:getFrameIndex("num7"), 12,18)
		return seven
	elseif(num == 8) then
		local eight = display.newImageRect(uiGroup, objectSheet,
			sheetInfo:getFrameIndex("num8"), 13,18)
		return eight
	elseif(num == 9) then
		local nine = display.newImageRect(uiGroup, objectSheet,
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
	barMultiplier = display.newImageRect(uiGroup, "raw/barmultiply.png",
		98, 8)
	barMultiplier.x = _W/2 - 23
	barMultiplier.y = hud.y-6
	local waveMultiplier = display.newImageRect(uiGroup, objectSheet,
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

local function updateMultiplier()
	--[[display.remove(barMultiplier)
	local widget = require("widget")

	-- image sheet options and declaration:
	local options = {
		width = 100,
		height = 11,
		sheetContentWidth = 102,
		sheetContentHeight = 13
	}

	local progressSheet = graphics.newImageSheet("barSprite.png",
		sheetInfo:getSheet())

	-- create the widget:
	local progressView = widget.newProgressView(
		{
			sheet = progressSheet,
			left = _W/2 - 73,
			top = hud.y - 10,
			width = 98,
			isAnimated = true,
			--fillWidth = 8
		}
	)

	-- set the progress to 100%
	progressView:setProgress(1)--]]

	-- setting up multiplier:
	multiplier = multiplier + 1
	mImage = getScore(multiplier)
	mImage.x = oldMimage.x
	mImage.y = oldMimage.y
	fitImage( mImage, 12, 12, false)
	oldMimage:removeSelf()
	oldMimage = nil
	oldMimage = mImage
end


-- for updating the score during game:
local function updateScore(score)
	local function setScore(index, theScore)
		local oldImage = scoreTable[index]
		local newImage = getScore(theScore)
		newImage.x = oldImage.x
		newImage.y = oldImage.y
		oldImage:removeSelf()
		oldImage = nil
		scoreTable[index] = newImage
	end
	local count = 1000000000
	local index = 9
	while(count >= 1) do
		local num = math.floor(score/count)
		if(num >= 1) then
			setScore(index, num)
			score = score%count
		end
		count = count/10
		index = index - 1
	end
end

--[[local myClosure = function() updateScore(5454) end
timer.performWithDelay(2000, myClosure, 1)--]]


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

-- adding the player's ship:
ship = display.newImageRect(mainGroup, objectSheet,
	sheetInfo:getFrameIndex("ship2"), 29, 27)
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100
-- giving ship physical properties:
physics.addBody(ship, "dynamic", {radius = 15})
ship.myName = "ship"

-- handling player movement:
local function dragShip(event)

	local ship = event.target

	local phase = event.phase

	if("began" == phase) then
		display.currentStage:setFocus(ship)
		ship.touchOffsetX = event.x - ship.x
		ship.touchOffsetY = event.y - ship.y
	elseif("moved" == phase) then
		ship.x = event.x -  ship.touchOffsetX
		ship.y = event.y - ship.touchOffsetY
	elseif("ended" == phase or "cancelled" == phase) then
		display.currentStage:setFocus(nil)
	end
	-- prevent touch propagation to underlying objects:
	return true
end
ship:addEventListener("touch", dragShip)

-- handling firing of shots at enemies:
local function fireShot()
	local newShot = display.newImageRect(mainGroup, objectSheet,
		sheetInfo:getFrameIndex("shot1"), 15, 10)
	newShot.rotation = 270
	physics.addBody(newShot, "dynamic", {isSensor = true})
	newShot.isBullet = true
	newShot.myName = "shot"
	newShot.x = ship.x-5
	newShot.y = ship.y
	newShot:toBack()
	transition.to(newShot, {y=-40, time = 500,
		onComplete = function() display.remove(newShot) end})
	newShot.anchor = 0

	local newShot1 = display.newImageRect(mainGroup, objectSheet,
		sheetInfo:getFrameIndex("shot1"), 15, 10)
	newShot1.rotation = 270
	physics.addBody(newShot1, "dynamic", {isSensor = true})
	newShot1.isBullet = true
	newShot1.myName = "shot"
	newShot1.x = ship.x+5
	newShot1.y = ship.y
	newShot1:toBack()
	transition.to(newShot1, {y=-40, time = 500,
		onComplete = function() display.remove(newShot1) end})
	newShot1.anchor = 1
end
ship:addEventListener("tap", fireShot)


-- handling enemy movement:
local function createFighters()
	fighter = display.newImageRect(mainGroup, objectSheet,
		sheetInfo:getFrameIndex("fighter"), 29, 29)
	table.insert(fighterTable, fighter)
	physics.addBody(fighter, "kinematic", {radius = 20})
	fighter.myName = "fighter"
	fighter.x = _W/2
	fighter.y = -40
	local ypos = math.random(50, 200)
	timer.performWithDelay(2500)
	local xpos = math.random(50, 300)
	transition.to(fighter, {time = 1000,
		y = ypos,
		x = xpos,
	})
	local function shoot()
		enemyShot = display.newImageRect(mainGroup, objectSheet,
			sheetInfo:getFrameIndex("shot1"), 15, 10)
		physics.addBody(enemyShot, "dynamic", {isSensor = true})
		enemyShot.rotation = 90
		enemyShot.isBullet = true
		enemyShot.myName = "enemyShot"
		enemyShot.x = xpos
		enemyShot.y = ypos
		enemyShot:toBack()
		transition.to(enemyShot, {time = 2000, y=_H+30,
			onComplete = function() display.remove(enemyShot) end})
	end

	table.insert(tm, timer.performWithDelay(2000, shoot, 0))

	-- making fighter move horizontally on screen:
	--[[local animate = function(obj, ref)
		if ref then
			obj.transitionLoop = ref
		end

		obj.x = 20


		transition.to(obj, {
			time = 2000,
			x = _W-100,
			onComplete = obj.transitionLoop
		})
	end
	animate(fighter, animate)--]]

end

local num = math.random(4, 8)
for i=1, num, 1 do
	timer.performWithDelay(1000)
	createFighters()
end

-- handling meteors:
local function createMeteor()
	--timer.performWithDelay(10000)
	local meteor = display.newImage(mainGroup, objectSheet,
		sheetInfo:getFrameIndex("asteroid"), 50, 50)
	table.insert(meteorTable, meteor)
	table.insert(meteorCount, 0)
	meteor.x = math.random(10, _W-10)
	meteor.y = -40
	meteor.myName = "meteor"
	local myRotation = 0
	meteor.rotation = myRotation
	physics.addBody(meteor, "kinematic", {radius = 50})

	local rotationSpeed = math.random(100, 400)
	local function rotate()
		myRotation = myRotation + 180
		transition.to(meteor, {rotation = myRotation, time = 1000})
	end

	r = timer.performWithDelay(rotationSpeed, rotate, 0)

	local speed = math.random(2000, 4000)
	transition.to(meteor, {time = speed, y = _H + 70,
		onComplete = function()
		display.remove(meteor)
		timer.cancel(r)
		end
	})

end

num = math.random(1, 5)
meteorTimer = timer.performWithDelay(2000, createMeteor, num)

local function restorePlayer()
	-- removing body from physics simulator:
	ship.isBodyActive = false

	ship.x = display.contentCenterX
	ship.y = display.contentHeight - 100

	-- fade in the player:
	transition.to(ship, {time = 500, alpha = 1,
		onComplete = function()
			ship.isBodyActive = true
			died = false
			end
	})

end



-- handling crystals:
local function crystals(xpos, ypos, enemy)
	local function create(spread)
		local num = math.random(1, 2)
		if num == 1 then
			local crystalSmall = display.newImage(mainGroup, objectSheet,
				sheetInfo:getFrameIndex("crys1"), 12, 12)
			physics.addBody(crystalSmall, "dynamic", {radius = 6})
			crystalSmall.x = xpos
			crystalSmall.y = ypos
			crystalSmall.myName = "crystal"
			transition.to(crystalSmall, {time = 1000, y = crystalSmall.y + math.random(-spread, spread),
				x = crystalSmall.x + math.random(-spread, spread),transition = easing.outCubic,
				onComplete = function()
					transition.to(crystalSmall, {time = 3000, y = _H + 50,
						onComplete = function() display.remove(crystalSmall) end})
					end
				}
			)
		else
			local crystalBig = display.newImage(mainGroup, objectSheet,
				sheetInfo:getFrameIndex("crys0"), 16, 16)
			physics.addBody(crystalBig, "dynamic", {radius = 6})
			crystalBig.x = xpos
			crystalBig.y = ypos
			crystalBig.myName = "crystal"
			transition.to(crystalBig, {time = 1000, y = crystalBig.y + math.random(-spread, spread),
				x = crystalBig.x + math.random(-spread, spread), transition = easing.outCubic,
				onComplete = function()
					transition.to(crystalBig, {time = 3000, y = _H + 50,
						onComplete = function() display.remove(crystalBig) end})
					end
				}
			)
		end
	end
	if(enemy == "fighter") then
		create(35)
	elseif( enemy == "meteor") then
		for i = 1, 15, 1 do
			create(70)
		end
	end
end




-- handling explosions:
local function explosion(xpos, ypos, xScale, yScale)
	local sheetInfo = require("boom")
	local mySheet = graphics.newImageSheet( "boom.png",
		sheetInfo:getSheet())

	local sequenceData = {
		{	name = "explode",
			start = 1,
			count = 11,
			frames = sheetInfo:getSheet(),
			time = 250,
			loopCount = 1
		}
	}
	local expl =  display.newSprite(mainGroup, mySheet,
		sequenceData)
	expl.x = xpos
	expl.y = ypos
	fitImage(expl, xScale, yScale, false)
	expl.timeScale = 0.5
	expl:play()
	transition.to(expl, {time = 500,
		onComplete = function() display.remove(expl) end})
end



-- handling collisions:
local function onCOllision(event)
	if (event.phase == "began") then
		-- storing collision objects:
		local obj1 = event.object1
		local obj2 = event.object2
		local xpos, ypos, xScale, yScale = 0,0,0,0
		if(obj1.myName == "shot" and obj2.myName == "fighter") then
			xpos = obj2.x
			ypos = obj2.y
			explosion(xpos, ypos, 50, 50)
			display.remove(obj2)
			for i=#fighterTable, 1, -1 do
				if(fighterTable[i] == obj2) then
					timer.cancel(tm[i])
					table.remove(fighterTable, i)
					table.remove(tm, i)
					break
				end
			end
			score = score + 10
			updateScore(score)
			if(score%20 == 0) then
				updateMultiplier()
			end
			crystals(xpos, ypos, "fighter")
		elseif(obj2.myName == "shot" and obj1.myName == "fighter") then
			xpos = obj1.x
			ypos = obj1.y
			explosion(xpos, ypos, 50, 50)
			display.remove(obj2)
			for i=#fighterTable, 1, -1 do
				if(fighterTable[i] == obj1) then
					table.remove(fighterTable, i)
					timer.cancel(tm[i])
					table.remove(tm, i)
					break
				end
			end
			score = score + 10
			updateScore(score)
			if(score%20 == 0) then
				updateMultiplier()
			end
			crystals(xpos, ypos, "fighter")
		end

		if((obj1.myName == "enemyShot" and obj2.myName == "ship") or
			(obj1.myName == "ship" and obj2.myName == "enemyShot")) then

			-- making screen blink:
			local rect = display.newRect(_W/2, _H/2, 500, 800)
			rect:setFillColor(1)
			rect.blendMode = "add"
			rect.alpha = 0
			transition.fadeIn(rect, {time = 200, onComplete = function()
				transition.fadeOut(rect, {time = 1500})
				end})


			if(died == false) then
				died = true

				-- update lives:
				lives = lives - 1
				num = #livesTable
				display.remove(livesTable[num])
				table.remove(livesTable, num)
				if(lives == 0) then
					display.remove(ship)
				else
					ship.alpha = 0
					timer.performWithDelay(1000, restorePlayer)
				end
			end
		end

		if((obj1.myName == "meteor" and obj2.myName == "shot") or
			(obj1.myName == "shot" and obj2.myName == "meteor")) then
			local object
			if(obj1.myName == "meteor") then
				xpos = obj1.x
				ypos = obj1.y
				object = obj1
			elseif(obj2.myName == "meteor") then
				xpos = obj2.x
				ypos = obj2.y
				object = obj2
			end

			local rect = display.newRoundedRect(xpos, ypos,45,45,20)
			rect:setFillColor(1)
			rect:setStrokeColor(1)
			rect.strokeWidth = 5
			rect.blendMode = "add"
			rect.alpha = 0
			transition.to(rect, {time = 0.5, alpha = 1,
				onComplete = function()
				transition.to(rect, {time = 0.5, alpha = 0})
				end})
			for i = 1, #meteorTable, 1 do
				if( meteorTable[i] == object) then
					if(meteorCount[i] == 10) then
						explosion(xpos, ypos, 100, 100)
						display.remove(object)
						score = score + 100
						updateScore(score)
						updateMultiplier()
						crystals(xpos, ypos, "meteor")
					else
						meteorCount[i] = meteorCount[i] + 1
					end
				end
			end
		end

		if((obj1.myName == "meteor" and obj2.myName == "ship") or
			(obj1.myName == "ship" and obj2.myName == "meteor")) then
			local object
			if(obj1.myName == "meteor") then
				xpos = obj2.x
				ypos = obj2.y
				object = obj1
			elseif(obj2.myName == "meteor") then
				xpos = obj1.x
				ypos = obj1.y
				object = obj2
			end

			-- making screen blink:
			local rect = display.newRect(_W/2, _H/2, 500, 800)
			rect:setFillColor(1)
			rect.blendMode = "add"
			rect.alpha = 0
			transition.fadeIn(rect, {time = 200, onComplete = function()
				transition.fadeOut(rect, {time = 1500})
				end})

			for i = 1, #meteorTable, 1 do
				if( meteorTable[i] == object) then
					explosion(xpos, ypos, 100, 100)
					display.remove(object)
				end
			end

			if(died == false) then
				died = true

				-- update lives:
				lives = lives - 1
				num = #livesTable
				display.remove(livesTable[num])
				table.remove(livesTable, num)
				if(lives == 0) then
					display.remove(ship)
				else
					ship.alpha = 0
					timer.performWithDelay(1000, restorePlayer)
				end
			end
		end
	end
end
Runtime:addEventListener("collision", onCOllision)

