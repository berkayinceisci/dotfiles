-- csvview.nvim: show CSV/TSV files as aligned columns (virtual text only,
-- the file itself is not changed). Enabled automatically for csv/tsv
-- buffers; :CsvViewToggle switches it off and on, :CsvViewInfo shows the
-- detected delimiter and header. The default delimiter map already has
-- csv = "," and tsv = "\t".
local filetypes = { "csv", "tsv" }

return {
	{
		"hat0uma/csvview.nvim",
		ft = filetypes,
		cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle", "CsvViewInfo" },
		config = function()
			require("csvview").setup({
				view = {
					-- draw a vertical border between columns
					display_mode = "border",
					-- keep the first column (the row id) in place when scrolling sideways
					sticky_columns = { enabled = true, count = 1 },
				},
			})

			-- lazy.nvim replays the FileType event after loading the plugin, so
			-- this can run twice for the first buffer. csvview attaches
			-- asynchronously (after parsing), so is_enabled() is still false on
			-- the second call; a buffer flag set before the first call is not.
			local function enable(buf)
				if vim.b[buf].csvview_auto or require("csvview").is_enabled(buf) then
					return
				end
				vim.b[buf].csvview_auto = true
				vim.api.nvim_buf_call(buf, function()
					vim.opt_local.wrap = false
					vim.cmd("CsvViewEnable")
				end)
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("csvview_auto", { clear = true }),
				pattern = filetypes,
				callback = function(args)
					enable(args.buf)
				end,
			})

			-- the FileType event that loaded the plugin has already fired for
			-- the buffer being opened, so enable it there directly
			local buf = vim.api.nvim_get_current_buf()
			if vim.tbl_contains(filetypes, vim.bo[buf].filetype) then
				enable(buf)
			end
		end,
	},
}
