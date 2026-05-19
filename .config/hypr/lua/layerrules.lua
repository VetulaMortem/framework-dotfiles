hl.layer_rule({
	name="wofi-rules",
	match = { namespace = "wofi" },
	animation = "slide bottom linear",
})
hl.layer_rule({
	name="layer-slide-top",
	match = {namespace = "^(waybar|swaync-notification-window|swaync-control-center)$"},
	animation = "slide top",
	no_screen_share = false,
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
	match = {namespace = "^(swayosd)$"},
	animation = "popin 20%",
	no_screen_share = false,
})
