
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




-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImageRect(sceneGroup, objectSheet,
		sheetInfo:getFrameIndex("Preloader"), 400, 590)
	background.x = 150
	background.y = 250

	local preloadingBar = display.newImage(sceneGroup, objectSheet,
		sheetInfo:getFrameIndex("PreloadingBar"), 307, 28)
	preloadingBar.x = 75
	preloadingBar.y = 295
	preloadingBar:scale(0.3, 0.99)
	transition.scaleTo(preloadingBar, {xScale = 0.8, yscale = 0.0,
			time = 2300, x = 150, onComplete = function()
				local startButton = display.newImage(sceneGroup, objectSheet,
					sheetInfo:getFrameIndex("PressHereToStart"), 466,32)
				startButton.x = 150
				startButton.y = 150
				startButton:scale(0.5, 0.99)

				startButton:addEventListener("tap", gotoTitle)
				end
			})

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
