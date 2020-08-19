# vudu
## visual unified debug utility for LÖVE2D

vudu is a simple to use in-game debugging system for the LÖVE2D game engine.

*vudu is currently in version 0.2.1, it has only recently been released publicly.  Some amount of bugginess, unfriendliness, or instability is possible, and is being worked on.  If you have any issues or suggestions, I would greatly appreciate your feedback on the issues page!*

*vudu currently supports Love2D versions 0.10.x and 0.11.x*

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

In the top right is a small button, pressing this will open a dropdown with a few settings, currently these settings only filter what variables are shown in the browser

On the left side of the screen is the **Browser**, it allows you to browse through all of variables in your game.  To show or hide the contents of a table, press the button to the left of its name.  To edit a string or number, click its value in the browser, type a new value, and press Enter.  To edit a bool, simply click it to flip its value.  Sometimes values push their way out of range of the browser, to see these values you can scroll left/right with shift+scrollwheel.

By right clicking the name of a value in the browser, you can either ignore (remove from the browser) that value, or create a watch window for it.

On the bottom right of the screen is the **Console**, it allows you to enter lua code to be interpreted and run.  The output of this code (or any error in its compilation) is shown in the console.  The output of `print()` is also shown in the console.  You can click a bubble in the console output to copy it to your clipboard.  When typing in the console, autofill options will appear, and you can press `tab` to autofill with the lowest option on the list.

On the bottom left of the screen is the **Controller**, the speed of execution can be adjusted with the slider, and the game can be switched between running, paused with 0dt updates, and paused without updates.  The camera can also be moved and zoomed, to get a look at things being rendered off-screen, or to zoom in on small details.

In the top right corner of the screen is the settings menu, under which you can find the following settings to tailor your vudu experience:

| Name | Purpose |
| ---- | ------- |
| `Show Functions` | Determines whether or not function values are shown in the browser. |
| `Show Underscores` | Determines whether or not variables starting with an '_' are shown in the browser. |

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

You can call ```vudu.initializeDefaultHotkeys``` to enable the following set of hotkeys:

*lalt can be replaced with any other specific modifier key you like by passing its keycode to initializeDefaultHotkeys*

| Sequence | Action |
| -------- | ------ |
| `lalt + space` | Toggle between 0dt Pause and Playing |
| `lalt + p` | 0dt Pause |
| `lalt + lshift + p` | No-Update Pause |
| `lalt + 1` | Advance 1 Frame |
| `lalt + ,` | Slow down the game |
| `lalt + .` | Speed up the game |
| `lalt + /` | Reset game speed |
| `lalt + [Arrow Key]` | Move the Camera in the specified direction |
| `lalt + -` | Zoom Out |
| `lalt + =` | Zoom In |
| `lalt + left + right` | Reset Camera |


### Graphics

The `vudu.graphics` module allows you to render simple visual elements over-top of your game.  All `vudu.graphics` objects have a color and a duration, they will be drawn with the given color (duh) and will fade out over the given duration.  Objects drawn with duration 0 will exist for the frame they are drawn on.

```lua
function love.update(dt)
  vudu.graphics.drawText({1,1,1}, 0, 20, 20, dt)
  local mousex, mousey = love.mouse.getPosition()
  vudu.graphics.drawCircle({0.5,0,0}, 0, mousex, mousey, 10)
end

function love.mouspressed(x, y)
  vudu.graphics.drawCircle({1,0,0}, 1, x, y, 8)
end
```

For a full list of things you can draw, see the Full API below.

### Physics

The `vudu.physics` module renders the given physics world in wireframe, including joints and contacts.  Use `vudu.physics.setWorld(world)` to set the world to be rendered, and `vudu.physics.setTransformation([x, y, z, r])` to control the offset and scale at which it is rendered.

![alt text](https://i.imgur.com/mXntMrR.gif "Boing")

### Full API

| Function | Functionality |
| -------- | ------------- |
| `vudu.initialize()` | initializes vudu |
| `vudu.hook()` | re-attaches vudu to the game, necessary if you do things like re-override love.draw or love.update |
| `vudu.addIgnore(ignore)` | `ignore` is either a string or a table of strings which represent the names of variables not to be shown in the browser.  i.e. `vudu.addIgnore("love.graphics")` |
| `vudu.hotkey.addSequence(keys, callback)` | `keys` is an ordered table of KeyConstant strings, `callback` is a 0-argument function |
| `vudu.physics.setWorld(world)` | Sets the physics world `world` as the world for vudu.physics to render |
| `vudu.physics.setTransformation([x, y, z, r])` | transforms the visuals in physics module such that `x, y` is the top left corner of the screen, `z` is the zoom level, and `r` is the rotation around the top left. |
| `vudu.graphics.setTransformation([x, y, z, r])` | see above, operates on the graphics module |
| `vudu.graphics.drawPoint(color, duration, x, y, [w])` | draws a point at `x, y` with radius `w`.  All vudu.graphics.draw_ operations are drawn with `color`, and remain on screen for `duration` |
| `vudu.graphics.drawLine(color, duration, sx, sy, ex, ey, [w])` | draws a line from `sx, sy` to `ex, ey` with width `w` |
| `vudu.graphics.drawCircle(color, duration, x, y, r, [w])` | draws a circle with radius `r` around the point `x, y`, with edge width `w` |
| `vudu.graphics.drawText(color, duration, x, y, text)` | prints `text` at position `x, y`|
| `vudu.graphics.drawPing(color, duration, x, y, r)` | draws an attention-grabbing animation with size `r` at `x, y`

This list is not exhaustive, there is more functionality which is currently internal, but will be exposed down the line.

###Some Useful Bits

**Nothing described below is part of the official API**, but the functionality is intended to be accessible via an official API at some point.  For now, as vudu is in early stages, here are some internal things you might find useful to tap into:

`vudu.control.SetPauseType(pauseType)` : pauseType is a string, and can be "Play", "Zero" (For 0dt updates), "Stop" (For no updates), or "Freeze" (For no updates or draw calls, the last rendered frame remains on screen)

`vudu.timeScale` : a number representing the log2 of the factor by which vudu multiplies dt. 0 is 1x, 2 is 4x, -2 is 0.25x, etc.  Currently, the slider on the control window goes from -3 to 3 (0.125x to 8x).
