--Dark Theme for tryhards

local colors = {
  number = {0, 3/4, 1},
  string = {1, 1/4, 0},
  boolean = {1, 0, 3/4},
  ["function"] = {0, 1, 3/4},
  table = {3/4, 3/4, 3/4},
  userdata = {1, 1, 0},
  label = {0, 1, 0},
  text = {0, 1, 0},
  --
  window = {1/4, 1/4, 1/4},
  highlight = {0, 1/2, 0},
  midhighlight = {1/8, 3/8, 1/8},
  lowlight = {1/8, 1/8, 1/8},
  --
  buttonIdle = {3/16, 3/16, 3/16},
  buttonHover = {1/8, 1/8, 1/8},
  buttonPress = {1/16, 1/4, 1/16},
  --
  consoleCommand = {3/16, 1/4, 3/16},
  consoleResponse = {3/16, 5/16, 3/16},
  consoleError = {5/16, 3/16, 3/16},
}

local colors_pre11 = {}
for i, v in pairs(colors) do colors_pre11[i] = {v[1]*255, v[2]*255, v[3]*255, (v[4] or 1)*255} end

return {colors = colors, colors_pre11 = colors_pre11}