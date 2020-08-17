--Similar to Standard, but semi-transparent and tinted cyanish

local colors = {
  number = {5/16, 7/16, 1},
  string = {1/2, 1/8, 1/16},
  boolean = {1/2, 1/8, 3/8},
  ["function"] = {1/8, 1/2, 3/8},
  table = {3/8, 3/8, 3/8},
  userdata = {3/4, 5/8, 3/16},
  label = {3/16, 3/16, 3/16},
  text = {0, 0, 0},
  --
  window = {7/8, 15/16, 15/16, 1/3},
  highlight = {6/16, 10/16, 13/16, 2/3},
  midhighlight = {13/16, 7/8, 15/16, 1/3},
  lowlight = {1/2, 9/16, 10/16, 1/3},
  --
  buttonIdle = {3/4, 13/16, 13/16, 1/4},
  buttonHover = {25/32, 27/32, 27/32, 1/4},
  buttonPress = {12/16, 14/16, 1, 1/4},
  --
  consoleCommand = {13/16, 27/32, 7/8, 1/3},
  consoleResponse = {7/8, 29/32, 15/16, 1/3},
  consoleError = {15/16, 7/8, 29/32, 1/3},
}

local colors_pre11 = {}
for i, v in pairs(colors) do colors_pre11[i] = {v[1]*255, v[2]*255, v[3]*255, (v[4] or 1)*255} end

return {colors = colors, colors_pre11 = colors_pre11}