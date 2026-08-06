---------------
---- INPUT ----
---------------
hl.config({
	input = {
		kb_layout = "de",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,

		sensitivity = 0,

		touchpad = {
			natural_scroll = false,
		},
	},
})
hl.device({
	name = "pixa3854:00-093a:0274-touchpad",
	enabled = true,
})
hl.device({
	name = "csw1322:00-3558:14fd",
	enabled = true,
	transform = 0,
})

