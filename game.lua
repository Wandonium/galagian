
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoGameOVer()
	composer.gotoScene("gameover")
end

-- loading the physics library:
local physics = require("physics")
physics.start()
physics.setGravity(0,0)

-- configure image sheet:
local sheetInfo = require("galagianSprite")
local objectSheet = graphics.newImageSheet("galagianSprite.png",
	sheetInfo:getSheet())

-- initializing variables:
local died = false

local fighterTable = {}
local boarderTable = {}
local kamikazeTable = {}
local meteorTable = {}
local meteorCount = {}
local scoreTable = {}
local livesTable = {}
local tm = {}
local boarderMoveTimer = {}
local linkTimer = {}

local ship
local barMultiplier
local wave
local message
local continue
local changeWave
local score = 0
local lives = 4
local multiplier = 5
local wave = 1
local enemyCollision = 0

local _W = display.contentWidth
local _H = display.contentHeight


-- declaring display groups:
local backGroup
local mainGroup
local uiGroup

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

-- helper method for setting up score board:
local function getScore(num)
	if(num == 0) then
		local zero = display.newImageRect(objectSheet,
			sheetInfo:getFrameIndex("num0"), 13,18)
		return zero
	elseif(num == 1) then
		local one = display.newImageRect(objectSheet,
			sheetInfo:getFrameIndex("num1"), 12,18)
		return one
	elseif(num == 2) then
		local two = display.newImageRect(objectSheet,
			sheetInfo:getFrameIndex("num2"), 12,18)
		return two
	elseif(num == 3) then
		local three = display.newImageRect(objectSheet,
			sheetInfo:getFrameIndex("num3"), 11,18)
		return three
	elseif(num == 4) then
		local four = display.newImageRect(objectSheet,
			sheetInfo:getFrameIndex("num4"), 12,18)
		return four
	elseif(num == 5) then
		local five = display.newImageRect(objectSheet,
			sheetInfo:getFrameIndex("num5"), 13,18)
		return five
	elseif(num == 6) then
		local six = display.newImageRect(objectSheet,
			sheetInfo:getFrameIndex("num6"), 12,18)
		return six
	elseif(num == 7) then
		local seven = display.newImageRect(objectSheet,
			sheetInfo:getFrameIndex("num7"), 12,18)
		return seven
	elseif(num == 8) then
		local eight = display.newImageRect(objectSheet,
			sheetInfo:getFrameIndex("num8"), 13,18)
		return eight
	elseif(num == 9) then
		local nine = display.newImageRect(objectSheet,
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

-- adding hud at bottom of screen:
local hud = display.newImageRect(objectSheet,
	sheetInfo:getFrameIndex("hud"), 320, 30)
hud.y = _H+30
hud.x = _W/2

-- handling hud objects:
local function handleHud()
	barMultiplier = display.newImageRect("barmultiply.png",
		98, 8)
	barMultiplier.x = _W/2 - 23
	barMultiplier.y = hud.y-6
	local waveMultiplier = display.newImageRect(objectSheet,
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

--handling player lives:
local livesImage1 = display.newImageRect(objectSheet,
	sheetInfo:getFrameIndex("life"), 34, 32)
livesImage1.x = 20
livesImage1.y = hud.y
livesImage1.myName = "liveImage1"

local livesImage2 = display.newImageRect(objectSheet,
	sheetInfo:getFrameIndex("life"), 34, 32)
livesImage2.x = 30
livesImage2.y = hud.y
livesImage2.myName = "liveImage2"

local livesImage3 = display.newImageRect(objectSheet,
	sheetInfo:getFrameIndex("life"), 34, 32)
livesImage3.x = 40
livesImage3.y = hud.y
livesImage3.myName = "liveImage3"

livesTable = {livesImage1, livesImage2, livesImage3 }

-- updating score multiplier during game:
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
	if multiplier < 1 then
		multiplier = 5
	end
	multiplier = multiplier - 1
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

-- handling player movement:
local function dragShip(event)

	moveShip = true

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

-- handling enemy movement:
local function createFighters()
	local fighter = display.newImageRect(mainGroup, objectSheet,
		sheetInfo:getFrameIndex("fighter"), 29, 29)
	table.insert(fighterTable, fighter)
	physics.addBody(fighter, "kinematic", {radius = 20})
	fighter.myName = "fighter"
	timer.performWithDelay(3000)
	fighter.x = math.random(50, 300)
	fighter.y = -40
	local ypos = math.random(50, 200)
	transition.to(fighter, {time = 1000, y = ypos})
	local function shoot()
		local enemyShot = display.newImageRect(mainGroup, objectSheet,
			sheetInfo:getFrameIndex("shot1"), 15, 10)
		physics.addBody(enemyShot, "dynamic", {isSensor = true})
		enemyShot.rotation = 90
		enemyShot.isBullet = true
		enemyShot.myName = "enemyShot"
		enemyShot.x = fighter.x
		enemyShot.y = fighter.y
		enemyShot:toBack()
		transition.to(enemyShot, {time = 2000, y=_H+30,
			onComplete = function() display.remove(enemyShot) end})
	end

	table.insert(tm, timer.performWithDelay(2000, shoot, 0))

	-- linking fighter movement to ship:
	local prevTime = 0
	local function timeLoop(event)
		if system.getTimer() - prevTime >= 500 then
			timer.performWithDelay(2500)
			local spread = math.random(-150, 150)
			if not died then
				transition.to(fighter, {time = 2000,
					x = ship.x+spread})
			end
			prevTime = system.getTimer()
		end
	end
	table.insert(linkTimer, timer.performWithDelay(10, timeLoop, 0))


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

-- handling boarders:
local function createBoarder()
	-- loading boarder image onto screen:
	local xpos = math.random(50, 250)
	local ypos = math.random(-100, -10)
	local boarder = display.newImageRect(mainGroup, objectSheet,
		sheetInfo:getFrameIndex("boarder"), 29, 29)
	boarder.x = xpos
	boarder.y = ypos
	table.insert(boarderTable, boarder)
	physics.addBody(boarder, "kinematic", {radius = 20})
	boarder.myName = "boarder"

	-- handling movement of boarder:
	local direction = math.random(1, 2)
	local speed = math.random(1,3)

	if direction == 1 then
		speed = -speed
	end

	moveBoarder = function(event)
		boarder.x = boarder.x + speed
		boarder.y = boarder.y + math.abs(speed)
		if speed < 1 then
			if boarder.x < 0 then
				boarder.x = _W
			end
		else
			if boarder.x > _W then
				boarder.x = -10
			end
		end

		if boarder.y > _H then
			boarder.y = -10
		end
	end
	-- handling boarder movement:
	--Runtime:addEventListener("enterFrame", moveBoarder)
	table.insert(boarderMoveTimer, timer.performWithDelay(
		10, moveBoarder, 0))

	-- handling boarder shot:
	local function shoot()
		enemyShot = display.newImageRect(mainGroup, objectSheet,
			sheetInfo:getFrameIndex("shot1"), 15, 10)
		physics.addBody(enemyShot, "dynamic", {isSensor = true})
		enemyShot.rotation = 90
		enemyShot.isBullet = true
		enemyShot.myName = "enemyShot"
		enemyShot.x = boarder.x
		enemyShot.y = boarder.y
		enemyShot:toBack()
		transition.to(enemyShot, {time = 2000, y=_H+30,
			onComplete = function() display.remove(enemyShot) end})
	end

	table.insert(tm, timer.performWithDelay(2000, shoot, 0))
end



-- handling kamikaze:
local function createKamikaze()
	local kamikaze = display.newImage(mainGroup, objectSheet,
		sheetInfo:getFrameIndex("kamikaze"), 29, 29)
	local num = math.random(1, 2)
	local speed = 2
	if num == 1 then
		kamikaze.x = 50
	else
		kamikaze.x = 320
		speed = -speed
	end
	kamikaze.y = -50
	kamikaze.myName = "kamikaze"
	physics.addBody(kamikaze, "kinematic", {radius = 20})
	table.insert(kamikazeTable, kamikaze)

	local ypos = math.random(80, 240)

	local function kamikazeLife()
		local kamikaze_alive = false
		for i=#kamikazeTable, 1, -1 do
			if kamikazeTable[i] == kamikaze then
				kamikaze_alive = true
			end
		end
		return kamikaze_alive
	end

	local function move()
		if kamikazeLife() then
			local function moveKamikaze()
				kamikaze.x = kamikaze.x + speed
				kamikaze.y = kamikaze.y + math.abs(speed)
				if kamikaze.y >= ypos or kamikaze.x >= _W-20 then					Runtime:removeEventListener("enterFrame", moveKamikaze)

					-- linking kamikaze movement to ship:
					local prevTime = 0
					local function timeLoop(event)
						if system.getTimer() - prevTime >= 500 then
							--timer.performWithDelay(2500)
							local spread = math.random(-80, 80)
							if not died then
								transition.to(kamikaze, {time = 1000,
									x = ship.x+spread})
							end
							prevTime = system.getTimer()
						end
					end
					Runtime:addEventListener("enterFrame", timeLoop)

					local function endTimeLoop()
						Runtime:removeEventListener("enterFrame", timeLoop)
						transition.to(kamikaze, {time=1000, y = _H+30,
							onComplete = function()
								kamikaze.alpha = 0
								kamikaze.isBodyActive = false
								transition.to(kamikaze, {time = 1000, y = -50,
								onComplete = function()
									kamikaze.alpha = 1
									kamikaze.isBodyActive = true
									move()
								end})
							end})
					end
					timer.performWithDelay(5000, endTimeLoop)

				end
			end
			Runtime:addEventListener("enterFrame", moveKamikaze)
		end
	end
	move()
end


-- handling meteors:
local function createMeteor()
	--timer.performWithDelay(10000)
	local meteor = display.newImage(mainGroup, objectSheet,
		sheetInfo:getFrameIndex("asteroid"), 50, 50)
	table.insert(meteorTable, meteor)
	-- for shooting meteor 10 times:
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
			--if meteorTable ~= nil then
				for i=1, #meteorTable, 1 do
					if meteorTable[i] == meteor then
						table.remove(meteorTable, i)
						break
					end
				end
			--end
		end})

end

-- restoring player ship after being shot:
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

-- local collision handler for crystals:
local function onLocalCollision(self, event)
	if( event.phase == "began") then
		if(self.myName == "crystal" and event.other.myName == "ship") then
			display.remove(self)
			self = nil
			score = score + 3
			updateScore(score)
		elseif(self.myName == "ship" and event.other.myName == "crystal") then
			display.remove(event.other)
			event.other = nil
			score = score + 3
			updateScore(score)
		end
	end
end

-- handling crystals:
local function crystals(xpos, ypos, enemy)
	local function create(spread)
		local num = math.random(1, 2)
		if num == 1 then
			local crystalSmall = display.newImage(mainGroup, objectSheet,
				sheetInfo:getFrameIndex("crys1"), 12, 12)
			physics.addBody(crystalSmall, "kinematic", {radius = 6})
			crystalSmall.x = xpos
			crystalSmall.y = ypos
			crystalSmall.myName = "crystal"
			crystalSmall.collision = onLocalCollision
			crystalSmall:addEventListener("collision")
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
			physics.addBody(crystalBig, "kinematic", {radius = 6})
			crystalBig.x = xpos
			crystalBig.y = ypos
			crystalBig.myName = "crystal"
			crystalBig.collision = onLocalCollision
			crystalBig:addEventListener("collision")
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

-- launching wave 001:
local function wave1()
	-- launching fighters:
	--local num = math.random(4,6)
	for i=1, 4, 1 do
		timer.performWithDelay(1000)
		createFighters()
	end

	-- launching meteors:
	--num = math.random(1, 3)
	meteorTimer = timer.performWithDelay(2000, createMeteor, 2)

	local function checkWave()
		--if fighterTable ~= nil and meteorTable ~= nil then
			if next(fighterTable) == nil and
				next(meteorTable) == nil then
				Runtime:removeEventListener("enterFrame", checkWave)
				changeWave()
			end
		--end
	end
	Runtime:addEventListener("enterFrame", checkWave)
end

-- launching wave 002:
local function wave2()
	-- launching fighters:
	--local num = math.random(4, 8)
	for i=1, 6, 1 do
		timer.performWithDelay(1000)
		createFighters()
	end

	-- launching meteors:
	--num = math.random(1, 5)
	meteorTimer = timer.performWithDelay(2000, createMeteor, 4)

	--launching boarder:
	createBoarder()

	local function checkWave()

		--if fighterTable ~= nil and meteorTable ~= nil and boarderTable ~= nil then
			if next(fighterTable) == nil and
				next(meteorTable) ==  nil and
				next(boarderTable) == nil then

				Runtime:removeEventListener("enterFrame", checkWave)
				changeWave()
			end
		--end
	end
	Runtime:addEventListener("enterFrame", checkWave)
end

-- launching wave 003:
local function wave3()
	-- launching fighters:
	--local num = math.random(4, 8)
	for i=1, 8, 1 do
		timer.performWithDelay(1000)
		createFighters()
	end

	-- launching meteors:
	--num = math.random(1, 5)
	meteorTimer = timer.performWithDelay(2000, createMeteor, 4)

	--launching boarder:
	for i=1, 3, 1 do
		timer.performWithDelay(1000)
		createBoarder()
	end

	-- launching kamikaze:
	createKamikaze()

	local function checkWave()

		--[[if fighterTable ~= nil and
			meteorTable ~= nil and
			boarderTable ~= nil and
			kamikazeTable ~= nil then--]]

			if next(fighterTable) == nil and
				next(meteorTable) ==  nil and
				next(boarderTable) == nil and
				next(kamikazeTable) == nil then

				Runtime:removeEventListener("enterFrame", checkWave)
				changeWave()
			end
		--end
	end
	Runtime:addEventListener("enterFrame", checkWave)
end

-- launching wave 004:
local function wave4()
	-- launching fighters:
	local num = math.random(6, 10)
	for i=1, 8, 1 do
		timer.performWithDelay(1000)
		createFighters()
	end

	-- launching meteors:
	num = math.random(1, 5)
	meteorTimer = timer.performWithDelay(2000, createMeteor, 4)

	--launching boarder:
	num = math.random(4, 6)
	for i=1, 5, 1 do
		timer.performWithDelay(1000)
		createBoarder()
	end

	-- launching kamikaze:
	num = math.random(4, 6)
	for i=1, 4, 1 do
		timer.performWithDelay(1000)
		createKamikaze()
	end

	local function checkWave()


		--[[if fighterTable ~= nil and
				meteorTable ~= nil and
				boarderTable ~= nil and
				kamikazeTable ~= nil then--]]

			if next(fighterTable) == nil and
				next(meteorTable) ==  nil and
				next(boarderTable) == nil and
				next(kamikazeTable) == nil then

				Runtime:removeEventListener("enterFrame", checkWave)
				changeWave()
			end
		--end
	end
	Runtime:addEventListener("enterFrame", checkWave)
end

-- launching wave 005:
local function wave5()
	-- launching fighters:
	local num = math.random(10,12)
	for i=1, num, 1 do
		timer.performWithDelay(1000)
		createFighters()
	end

	local function checkWave()
		--if fighterTable ~= nil then
			if next(fighterTable) == nil then
				Runtime:removeEventListener("enterFrame", checkWave)
				gotoGameOVer()
			end
		--end
	end
	Runtime:addEventListener("enterFrame", checkWave)
end

--[[
-- creating tables:
local function createTables()
	fighterTable = {}
	meteorTable = {}
	meteorCount = {}
	boarderTable = {}
	kamikazeTable = {}
end
--]]

-- handling waves of enemies:
local function waveChanger(num)

	--createTables()

	if num == 1 then
		wave = display.newText("Wave: 001", 150, 150, "font.ttf", 15)
		message = display.newText("INTRODUCING FIGHTERS \n JUST GETTING WARMED",
			170, 180, "font.ttf", 15)
	elseif num == 2 then
		wave = display.newText("Wave: 002", 150, 150, "font.ttf", 15)
		message = display.newText("INTRODUCING BOARDERS",
			170, 180, "font.ttf", 15)
	elseif num == 3 then
		wave = display.newText("Wave: 003", 150, 150, "font.ttf", 15)
		message = display.newText("INTRODUCING KAMIKAZE \n THEIR TOUCH IS DEADLY...",
			170, 180, "font.ttf", 15)
	elseif num == 4 then
		wave = display.newText("Wave: 004", 150, 150, "font.ttf", 15)
		message = display.newText(" ",170, 130, "font.ttf", 15)
	elseif num == 5 then
		wave = display.newText("Wave: 005", 150, 150, "font.ttf", 15)
		message = display.newText("CHALLENGE NO. 1",170, 180, "font.ttf", 15)
	end

	continue = display.newText("TAP TO CONTINUE", 170, message.y +50,
		"font.ttf", 15)

	local function checkForImageTouch(event)
		display.remove(wave)
		wave = nil
		display.remove(message)
		message = nil
		display.remove(continue)
		continue = nil

		Runtime:removeEventListener("touch", checkForImageTouch)
		if num == 1 then
			wave1()
		elseif num == 2 then
			wave2()
		elseif num == 3 then
			wave3()
		elseif num == 4 then
			wave4()
		elseif num == 5 then
			wave5()
		end
	end
	Runtime:addEventListener("touch", checkForImageTouch)
end

--[[
-- destroy all objects:
local function destroy()
	for i=#fighterTable, 1, -1 do
		timer.cancel(tm[i])
		timer.cancel(linkTimer[i])
		display.remove(fighterTable[i])
		table.remove(fighterTable, i)
		table.remove(tm, i)
		table.remove(linkTimer, i)
	end
	fighterTable = nil

	for i=#boarderTable, 1, -1 do
		timer.cancel(tm[i])
		timer.cancel(boarderMoveTimer[i])
		display.remove(boarderTable[i])
		table.remove(boarderTable, i)
		table.remove(tm, i)
		table.remove(boarderMoveTimer, i)
	end
	boarderTable = nil

	for i=#kamikazeTable, 1, -1 do
		display.remove(kamikazeTable[i])
		table.remove(kamikazeTable, i)
	end
	kamikazeTable = nil

	for i = 1, #meteorTable, 1 do
		display.remove(meteorTable[i])
		table.remove(meteorTable, i)
		table.remove(meteorCount, i)
	end
	meteorTable = nil
	meteorCount = nil
	waveNum = 1
end
--]]

-- handling collisions:
local function onCollision(event)
	if (event.phase == "began") then
		-- storing collision objects:
		local obj1 = event.object1
		local obj2 = event.object2
		local xpos, ypos, xScale, yScale = 0,0,0,0

		-- handling collision between fighter and ship shot:
		if((obj1.myName == "shot" and obj2.myName == "fighter") or
			(obj2.myName == "shot" and obj1.myName == "fighter")) then
			local object
			if obj1.myName == "fighter" then
				object = obj1
			elseif obj2.myName == "fighter" then
				object = obj2
			end
			xpos = object.x
			ypos = object.y
			explosion(xpos, ypos, 50, 50)
			display.remove(object)
			for i=#fighterTable, 1, -1 do
				if(fighterTable[i] == object) then
					timer.cancel(tm[i])
					timer.cancel(linkTimer[i])
					table.remove(fighterTable, i)
					table.remove(tm, i)
					table.remove(linkTimer, i)
					break
				end
			end
			score = score + 10
			updateScore(score)
			if(score%20 == 0) then
				updateMultiplier()
			end
			local myClosure = function() crystals(xpos, ypos, "fighter") end
			timer.performWithDelay(500, myClosure, 1)
		end


		-- handling collision between boarder and ship shot
		if((obj1.myName == "shot" and obj2.myName == "boarder") or
			(obj2.myName == "shot" and obj1.myName == "boarder")) then

			local object
			if obj1.myName == "boarder" then
				object = obj1
			elseif obj2.myName == "boarder" then
				object = obj2
			end
			xpos = object.x
			ypos = object.y
			explosion(xpos, ypos, 50, 50)
			display.remove(object)
			for i=#boarderTable, 1, -1 do
				if(boarderTable[i] == object) then
					timer.cancel(tm[i])
					timer.cancel(boarderMoveTimer[i])
					table.remove(boarderTable, i)
					table.remove(tm, i)
					table.remove(boarderMoveTimer, i)
					break
				end
			end
			score = score + 30
			updateScore(score)
			if(score%20 == 0) then
				updateMultiplier()
			end
			local myClosure = function() crystals(xpos, ypos, "fighter") end
			timer.performWithDelay(500, myClosure, 1)
		end

		-- handling collision between kamikaze and ship shot
		if((obj1.myName == "shot" and obj2.myName == "kamikaze") or
			(obj2.myName == "shot" and obj1.myName == "kamikaze")) then

			local object
			if obj1.myName == "kamikaze" then
				object = obj1
			elseif obj2.myName == "kamikaze" then
				object = obj2
			end
			xpos = object.x
			ypos = object.y
			explosion(xpos, ypos, 50, 50)
			display.remove(object)
			for i=#kamikazeTable, 1, -1 do
				if(kamikazeTable[i] == object) then
					table.remove(kamikazeTable, i)
					break
				end
			end
			score = score + 20
			updateScore(score)
			if(score%20 == 0) then
				updateMultiplier()
			end
			local myClosure = function() crystals(xpos, ypos, "fighter") end
			timer.performWithDelay(500, myClosure, 1)
		end

		-- handling collision between kamikaze and ship:
		if((obj1.myName == "kamikaze" and obj2.myName == "ship") or
			(obj1.myName == "ship" and obj2.myName == "kamikaze")) then

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
					--destroy()
					gotoGameOVer()
				else
					ship.alpha = 0
					timer.performWithDelay(1000, restorePlayer)
				end
			end
		end


		-- handling collision between ship and enemy:
		if((obj1.myName == "ship" and obj2.myName == "boarder") or
			(obj1.myName == "boarder" and obj2.myName == "ship") or
			(obj1.myName == "ship" and obj2.myName == "fighter") or
			(obj1.myName == "fighter" and obj2.myName == "ship"))then

			-- getting which object is the ship:
			local object = nil
			if obj1.myName == "ship" then
				xpos = obj1.x
				ypos = obj1.y
				object = obj1
			elseif obj2.myName == "ship" then
				xpos = obj2.x
				ypos = obj2.y
				object = obj2
			end

			enemyCollision = enemyCollision + 1
			if enemyCollision == 3 then

				explosion(xpos, ypos, 50, 50)

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
						--destroy()
						gotoGameOVer()
					else
						ship.alpha = 0
						timer.performWithDelay(1000, restorePlayer)
					end
				end
				enemyCollision = 0

			else
				for i=1, 5, 1 do
					transition.to(ship, {time = 500, alpha = 0,
						onComplete = function()
							transition.to(ship, {time = 500, alpha = 1})
						end})
				end
			end
		end



		-- handling collision between enemyshot and ship:
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
					--destroy()
					gotoGameOVer()
				else
					ship.alpha = 0
					timer.performWithDelay(1000, restorePlayer)
				end
			end
		end

		-- handling collision between meteor and ship shot:
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
						table.remove(meteorTable, i)
						score = score + 100
						updateScore(score)
						updateMultiplier()
						local myClosure = function() crystals(xpos, ypos, "fighter") end
						timer.performWithDelay(500, myClosure, 1)
						break
					else
						meteorCount[i] = meteorCount[i] + 1
					end
				end
			end
		end

		-- handling collision between meteor and ship:
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
					--destroy()
					gotoGameOVer()
				else
					ship.alpha = 0
					timer.performWithDelay(1000, restorePlayer)
				end
			end
		end
	end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()		-- temporarily pause the physics engine

	-- set up the display groups:
	backGroup = display.newGroup()	-- display group for the background images
	sceneGroup:insert( backGroup) 	-- insert into the scene's view group

	mainGroup = display.newGroup()	-- display group for the other objects
	sceneGroup:insert( mainGroup)	-- insert into the scene's view group


	-- adding the player's ship:
	ship = display.newImageRect(mainGroup, objectSheet,
		sheetInfo:getFrameIndex("ship2"), 29, 27)
	ship.x = display.contentCenterX
	ship.y = display.contentHeight - 100
	-- giving ship physical properties:
	physics.addBody(ship, "dynamic", {radius = 15})
	ship.myName = "ship"

	ship:addEventListener("touch", dragShip)
	ship:addEventListener("tap", fireShot)


end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

		physics.start()
		Runtime:addEventListener("collision", onCollision)

		-- load background:
		local background = display.newImageRect(backGroup, objectSheet,
			sheetInfo:getFrameIndex("bg"), 500, 1500)
		background.x = display.contentCenterX
		background.y = display.contentCenterY

		local background2 = display.newImageRect(backGroup, objectSheet,
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

		local num = 1
		waveChanger(num)

		changeWave = function()
			if num < 6 then
				num = num + 1
				waveChanger(num)
			end
		end

		-- launching boarders:
		--[[for i=1, 3, 1 do
			createBoarder()
		end

		-- launching kamikaze:
		local num = math.random(1, 4)
		for i=1, 4, 1 do
			timer.performWithDelay(1000)
			createKamikaze()
		end--]]




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
