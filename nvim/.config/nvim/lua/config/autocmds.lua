local autocmd = vim.api.nvim_create_autocmd

-- Set comment style for C-like languages
autocmd({ "FileType" }, {
	pattern = { "c", "cpp", "cs", "java" },
	callback = function()
		vim.bo.commentstring = "// %s"
	end,
})

-- Auto-reload files when changed externally (e.g., by Claude Code)
vim.opt.autoread = true
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	pattern = "*",
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd("checktime")
		end
	end,
})
