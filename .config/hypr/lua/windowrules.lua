hl.workspace_rule({
	workspace = "w[tv1]", 
	gaps_out = 0,
	gaps_in = 0
})
hl.workspace_rule({
	workspace = "f[1]", 
	gaps_out = 0,
	gaps_in = 0
})
hl.workspace_rule({
	workspace = "special:magic", 
	on_created_empty = "kitty",
	layout = "monocle",
	gaps_out = 0,
	gaps_in = 0
})
hl.workspace_rule({
	workspace = "r[4-6]",
	default_name = "master"
})
hl.workspace_rule({
	workspace = "r[7-9]",
	default_name = "scrolling"
})
hl.workspace_rule({
	workspace = "10",
	default_name = "gaming",
	layout = "monocle",
	gaps_out = 0,
	no_rounding = true,
	decorate = false
})
hl.workspace_rule({
	workspace = "name:master",
	layout = "master"
})
hl.workspace_rule({
	workspace = "name:scrolling",
	layout = "scrolling",
	gaps_out = 0,
	gaps_in = 0,
	no_rounding = true
})
hl.window_rule({
	name = "smart-border",
	match = { float = false, workspace = "w[tv1]" },
	border_size = 0,
	rounding = 0,
})

hl.window_rule( {
	name = "no_looking",
	match = { class = "^(.*(obs).*)$" },
	no_screen_share = true,
})
hl.window_rule({
	name = "Steam-Rules",
	match = { class = "^(steam)$" , title = "^(.+)$" },
	float = true,
	animation = "gnomed",
	border_color = "rgb(171D25)",
	center = true,
	rounding = 0,
	decorate = false,
	size = {"(monitor_w*0.6)", "(monitor_h*0.8)"}
})
hl.window_rule({
	name = "Steam-Menu-Rules",
	match = {class = "^(steam)$",title = "^$"},
	float = true,
	no_focus = true,
})
hl.window_rule({
	name = "communication",
	match = {class = "^(discord|org.telegram.desktop|elecwhat)$"},
	size = {"(monitor_w*0.6)", "(monitor_h*0.6)"},
	center = true,
	float = true,
	rounding = 1,
})
hl.window_rule({
	name = "thunar",
	match = {class = "^(thunar)$"},
	size = {"(monitor_w*0.5)", "(monitor_h*0.5)"},
	center = true,
	float = true,
	rounding = 2,
	border_size= 1,
})
hl.window_rule({
	name = "PIP-Rules",
	match = {title = "^(.*Picture-in-Picture.*|.*Bild-im-Bild.*)$"},
	border_color = "rgb(ff0000)",
	float = true,
	move = "0 0", 
	size = "450 250",
	rounding = 0,
	pin = true,
})
hl.window_rule({
	name = "WiFi",
	match = {class = "^(wifi)$"},
	float = true,
	size = {"(monitor_w*0.5)", "(monitor_h*0.5)"},
	move = {"(monitor_w*0.5)", "50"},
	animation = "slide right",
})
hl.window_rule({
	name="Task-Manager",
	match = {class = "^(btop)$"},
	float = true,
	size = "730 710",
	animation = "slide top",
	center = true,
})
hl.window_rule({
	name = "Pavucontroll",
	match = {class ="^(org.pulseaudio.pavucontrol|update)$"},
	size = {"(monitor_w*0.4)", "(monitor_h*0.4)"},
	move = {"(monitor_w*0.6)", "50"},
	float = true,
	animation = "slide right",
	rounding = 0,
})
hl.window_rule({
	name = "Clock",
	match = {class="^(clock)$"},
	float = true,
	move = {"(monitor_w*0.4)", "50px"},
	size = {"(monitor_w*0.2)", "(monitor_h*0.1)"},
	no_blur=true,
	border_color = "rgba(00000000)",
	animation = "slide top",
})
hl.window_rule({
	name = "YouTube",
	match = {title = "^(.*YouTube.*)$"},
	border_color = "rgb(ffdd00)",
})
hl.window_rule({
	name="Steam-Big-Picture",
	match = {title = "^(Steam Big Picture Mode)$"},
	border_size = 0,
	dim_around = true,
	tile = true,
})
hl.window_rule({
	name="Steam_Apps",
	match = {class = "^(steam_app.*)$"},
	float = true,
	stay_focused = true,
	rounding = 0,
})
hl.window_rule({
	name="Ignore-Maximize",
	match ={class = ".*"},
	suppress_event = "maximize",
})
hl.window_rule({
	name = "xwayland-fix",
	match = {class = "^$" ,title = "^$",xwayland = 1,float = true,fullscreen = false,pin = false},
	no_focus = true,
})
hl.window_rule({
	name = "nvim",
	match ={title = "^(.*nvim.*)$"},
	rounding = 0,
	no_screen_share = true,
	opaque = true,
	idle_inhibit = "focus",
	decorate = true,
	border_color = "rgba(fe7446ff)",
	border_size = 4,
})
