local M = {}

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
