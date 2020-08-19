--Default theme, based partly on Zerobrane Studio

return {
  colors_pre11 = {
    number = {80, 112, 255, 255},
    string = {128, 32, 16, 255},
    boolean = {127, 32, 96, 255},
    ["function"] = {32, 127, 96, 255},
    table = {96, 96, 96, 255},
    userdata = {192, 160, 48, 255},
    label = {48, 48, 48, 255},
    text = {0, 0, 0, 255},
    --
    window = {250, 250, 250, 255},
    highlight = {128, 96, 192, 255},
    midhighlight = {224, 224, 224, 255},
    lowlight = {128, 128, 128, 255},
    --
    buttonIdle = {192, 192, 192, 255},
    buttonHover = {200, 200, 200, 255},
    buttonPress = {208, 192, 240, 255},
    --
    consoleCommand = {208, 216, 224, 255},
    consoleResponse = {224, 232, 240, 255},
    consoleError = {240, 224, 232, 255},
  },

  colors = {
    number = {5/16, 7/16, 1},
    string = {1/2, 1/8, 1/16},
    boolean = {1/2, 1/8, 3/8},
    ["function"] = {1/8, 1/2, 3/8},
    table = {3/8, 3/8, 3/8},
    userdata = {3/4, 5/8, 3/16},
    label = {3/16, 3/16, 3/16},
    text = {0, 0, 0},
    --
    window = {250/255, 250/255, 250/255},
    highlight = {1/2, 3/8, 3/4},
    midhighlight = {7/8, 7/8, 7/8},
    lowlight = {1/2, 1/2, 1/2},
    --
    buttonIdle = {3/4, 3/4, 3/4},
    buttonHover = {25/32, 25/32, 25/32},
    buttonPress = {13/16, 3/4, 15/16},
    --
    consoleCommand = {13/16, 27/32, 7/8},
    consoleResponse = {7/8, 29/32, 15/16},
    consoleError = {15/16, 7/8, 29/32},
  },
}