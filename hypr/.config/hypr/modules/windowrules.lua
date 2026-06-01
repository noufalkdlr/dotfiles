--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

-- Better Control
hl.window_rule({
	name = "better-control-popup",
	match = { class = "better_control.py" },
	float = true,
	size = { 1000, 500 },
	center = true,
})

-- Cosmic Settings
hl.window_rule({
	name = "cosmic-settings-popup",
	match = { class = "com.system76.CosmicSettings" },
	float = true,
	size = { 1200, 700 },
	center = true,
})

-- GNOME Calculator
hl.window_rule({
	name = "gnome-calculator-popup",
	match = { class = "org.gnome.Calculator" },
	float = true,
	center = true,
})

-- MPV Video Player
hl.window_rule({
	name = "mpv-popup",
	match = { class = "mpv" },
	size = { 1200, 700 },
	float = true,
	center = true,
})

-- PulseAudio Control (pavucontrol)
hl.window_rule({
	name = "pavucontrol-popup",
	match = { class = "org.pulseaudio.pavucontrol" },
	float = true,
	size = { 1000, 500 },
	center = true,
})

-- IMV Image Viewer
hl.window_rule({
	name = "imv-popup",
	match = { class = "imv" },
	float = true,
	center = true,
})

-- Local Send
hl.window_rule({
	name = "local-send-popup",
	match = { class = "localsend" },
	size = { 900, 600 },
	float = true,
	center = true,
})

-- File Chooser Dialogs (Open/Save)
hl.window_rule({
	name = "file-picker",
	match = {
		class = "xdg-desktop-portal-gtk",
	},
	float = true,
	center = true,
	size = { 1200, 700 },
})

-- Blur Rules

-- GNOME Nautilus
hl.window_rule({
	name = "nautilus-blur",
	match = { class = "org.gnome.Nautilus" },
	opacity = "0.90 0.95",
})

-- Cosmic Settings
hl.window_rule({
	name = "cosmic-files-blur",
	match = { class = "com.system76.CosmicFiles" },
	opacity = "0.90 0.95",
})
