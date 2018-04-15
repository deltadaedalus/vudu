# vudu
## visual unified debug utility for LÖVE2D

---
vudu is a simple to use in-game debugging system for the LÖVE2D game engine.

**vudu is currently in version 0.1.0, i.e. it has only just been released publicly.  Some amount of bugginess, unfriendliness, or instability is to be expected.  If you have any issues or suggestions, I would greatly appreciate your feedback on the issues page!**


## Using vudu

### Setup

Drop the vudu folder into your project and import it with **vudu = require("vudu")**

vudu works by hooking itself into your game, to use it, simply call **vudu.initialize()** from love.load. If your game is set up simply, that's it, you're good to go!

If your game changes **love.update**, **love.draw**, **love.keypressed**, or any other love callback or lua builtin at runtime, vudu may need to be notified of this by calling **vudu.hook()**

### Use

Press **`** to show/hide vudu.

On the left side of the screen is the **Browser**, it allows you to browse through all of variables in your game.  To show or hide the contents of a table, press the button to the left of its name.  To edit a string or number, click its value in the browser, type a new value, and press Enter.

On the bottom left of the screen is the **Console**, it allows you to enter lua code to be interpreted and run.  The output of this code (or any error in its compilation) is shown in the console.  The output of print() is also shown in the console.

On the bottom right of the screen is the **Controller**, the speed of execution can be adjusted with the slider, and the game can be switched between running, paused with 0dt updates, and paused without updates.
