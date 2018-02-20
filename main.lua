local composer = require("composer")

-- Hide status bar
display.setStatusBar(display.HiddenStatusBar)

-- seed the random number generator
math.randomseed( os.time())

-- go to the menu screen
composer.gotoScene("preloader")
