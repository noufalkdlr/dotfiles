local M = {}

-- Toggle the active window between tiled and floating-centered mode.
--
-- Used in binds.lua:
--   SUPER + D
--
-- When the active window is tiled, it:
--   1. makes the window floating
--   2. resizes it to 1200x700
--   3. centers it on the screen
--
-- When the active window is already floating, it returns it back to tiled mode.
function M.toggle_float_centered()
	local win = hl.get_active_window()

	if win and not win.floating then
		hl.dispatch(hl.dsp.window.float({ action = "set" }))

		hl.dispatch(hl.dsp.window.resize({
			x = 1200,
			y = 700,
			exact = true,
		}))

		hl.dispatch(hl.dsp.window.center())
	else
		hl.dispatch(hl.dsp.window.float({ action = "unset" }))
	end
end

return M
