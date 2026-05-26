local monitor_names = require("lua.monitor_names")

hl.monitor({
    output = monitor_names.laptop,
    mode = "3072x1920@120",
    position = "0x0",
    scale = 2,
    vrr = 0,
    cm = "auto",
})

hl.monitor({
    output = monitor_names.external,
    mode = "1920x1080@100",
    position = "auto",
    scale = 1,
    cm = "auto",
})

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})
