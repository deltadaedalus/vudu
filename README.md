# vudu
## visual unified debug utility for LÖVE2D

vudu is a simple to use in-game debugging system for the LÖVE2D game engine.

*vudu is currently in version 0.1.1, i.e. it has only just been released publicly.  Some amount of bugginess, unfriendliness, or instability is to be expected.  If you have any issues or suggestions, I would greatly appreciate your feedback on the issues page!*

## Using vudu

### Setup

Setting up vudu is quick and easy!  Drop the vudu folder into your project, and then add the following to your game code
```lua
vudu = require("vudu")

function love.load()
  vudu.initialize()
  --Your Game Code
end
```
That's it!  Just hit the **`** key to toggle the GUI!

While basic setup is simple for you, it's complex for vudu, so if your game changes `love.update`, `love.draw`, `love.keypressed`, or any other love callback or lua builtin at runtime, vudu may need to be notified of this by calling `vudu.hook()`

### GUI Navigation

Press **`** to show/hide the vudu GUI.

![alt text](https://i.imgur.com/7f220pj.png "vudu in action")

On the left side of the screen is the **Browser**, it allows you to browse through all of variables in your game.  To show or hide the contents of a table, press the button to the left of its name.  To edit a string or number, click its value in the browser, type a new value, and press Enter.

On the bottom right of the screen is the **Console**, it allows you to enter lua code to be interpreted and run.  The output of this code (or any error in its compilation) is shown in the console.  The output of `print()` is also shown in the console.

On the bottom left of the screen is the **Controller**, the speed of execution can be adjusted with the slider, and the game can be switched between running, paused with 0dt updates, and paused without updates.

### Hotkeys

To set up a hotkey, call `vudu.hotkey.addSequence()`

```lua
function love.load()
  vudu.initialize()
  vudu.hotkey.addSequence({'lctrl', 'lalt', 'escape'}, love.event.quit)
  vudu.hotkey.addSequence({'lctrl', 'lalt', 'p'}, function() vudu.control.setPauseType("Pause") end)
  vudu.hotkey.addSequence({'lctrl', 'lalt', 'r'}, function() vudu.control.setPauseType("Zero") end)
end
```

### Some useful functions

**Nothing described below is part of the official API**, but the functionality is intended to be accessible via an official API at some point.  For now, as vudu is in early alpha, here are some internal things you might find useful to tap into:

`vudu.control.SetPauseType(pauseType)` : pauseType is a string, and can be "Play", "Zero" (For 0dt updates), or "Stop" (For no updates)
`vudu.timeScale` : a number representing the log2 of the factor by which vudu multiplies dt. 0 is 1x, 2 is 4x, -2 is 0.25x, etc.  Currently, the slider on the control window goes from -3 to 3 (0.125x to 8x).
`vudu.browser.ignore` : a table with string indexes and bool values, which determines which variables to hide in the browser.  As an example, say you want to hide the love.graphics module in the browser, you would do `vudu.browser.ignore["love.graphics"] = true`
