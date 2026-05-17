---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us, in",
		kb_variant = ",mal_poorna",
		kb_model = "",
		kb_options = "grp:win_space_toggle, caps:escape_shifted_capslock",
		kb_rules = "",

		follow_mouse = 1,

		sensitivity = -0.8, -- -1.0 - 1.0, 0 means no modification.

		repeat_rate = 80,
		repeat_delay = 250,

		touchpad = {
			natural_scroll = false,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})
