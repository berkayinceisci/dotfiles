local M = {}
local installed = false

function M.setup()
	if installed then
		return
	end

	local utils = require("lualine.utils.utils")
	local timer_call = utils.timer_call

	-- Timers keep firing at hit-enter prompts while scheduled work cannot run.
	-- Keep at most one pending callback per timer, retaining lualine's error handling.
	utils.timer_call = function(timer, augroup, fn, max_err, err_msg)
		local pending = false
		local callback = timer_call(timer, augroup, function(...)
			pending = false
			return fn(...)
		end, max_err, err_msg)

		return function(...)
			if pending then
				return
			end
			pending = true
			local ok, err = pcall(callback, ...)
			if not ok then
				pending = false
				error(err, 0)
			end
		end
	end

	installed = true
end

return M
