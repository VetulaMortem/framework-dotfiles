hl.config({
    plugin = {
        hyprgrass = {
            -- The default sensitivity is probably too low on tablet screens,
            -- I recommend turning it up to 4.0
            sensitivity = 1.0,

            -- in milliseconds
            long_press_delay = 400,

            -- resize windows by long-pressing on window borders and gaps.
            -- If general:resize_on_border is enabled, general:extend_border_grab_area is
            -- used for floating windows
            resize_on_border_long_press = true,

            -- in pixels, the distance from the edge that is considered an edge
            edge_margin = 10,
        }
    }
})
hl.plugin.hyprgrass.gesture {
    pattern = {kind = "swipe", fingers = 4, direction = "down"},
    action = "close",
}
hl.plugin.hyprgrass.gesture {
    pattern = {kind = "swipe", fingers = 3, direction = "horizontal"},
    action = "workspace",
}
hl.plugin.hyprgrass.gesture {
    pattern = {kind = "swipe", fingers = 3, direction = "up"},
    action = function (e) hl.exec_cmd(menu) end,
}
hl.plugin.hyprgrass.gesture {
    pattern = {kind = "swipe", fingers = 4, direction = "up"},
    action = function (e) hl.exec_cmd("pkill wvkbd || wvkbd-deskintl -L 300") end,
}
