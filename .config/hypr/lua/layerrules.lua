hl.layer_rule({
	name="wofi-rules",
	match = { namespace = "wofi" },
	animation = "slide bottom linear",
	dim_around = true,
})
hl.layer_rule({
	name="layer-slide-top",
	match = {namespace = "^(swaync-notification-window|swaync-control-center)$"},
	animation = "slide top",
	no_screen_share = false,
})
hl.layer_rule({
	name="layer-slide-top",
	match = {namespace = "^(waybar|quickshell-bar)$"},
	animation = "slide top",
	--no_screen_share = true,
})
hl.layer_rule({
	name="layer-slide-right",
	match = {namespace = "^(swaync-control-center)$"},
	animation = "slide right",
	no_screen_share = true,
	dim_around = true,
})
hl.layer_rule({
	name="layer-slide-bottom",
	match = {namespace = "^(wob|quickshell-osd)$"},
	animation = "slide bottom linear",
	no_screen_share = false,
})
hl.layer_rule({
	name="nosharebackground",
	match = {namespace = "^(hyprpaper|mpvpaper)$"},
	order = 100
})
hl.layer_rule({
	name="muteoverlay",
	match = {namespace = "^(mute_overlay)$"},
	animation = "slide bottom linear"
})

