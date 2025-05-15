return {
	{
		"sindrets/diffview.nvim",
		config = function()
			-- Lua
			local actions = require("diffview.actions")
			require("diffview").setup({
				keymaps = {
					file_panel = {
						{ "n", "<c-u>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
						{ "n", "<c-d>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
					},
					file_history_panel = {
						{ "n", "<c-u>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
						{ "n", "<c-d>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
					},
				},
			})
			vim.keymap.set(
				"n",
				"<leader>gf",
				"<CMD>DiffviewFileHistory %<CR>",
				{ desc = "Open git history for the current file" }
			)
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				on_attach = function(bufnr)
					local gitsigns = require("gitsigns")

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "]c", bang = true })
						else
							gitsigns.nav_hunk("next")
						end
					end)

					map("n", "[c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "[c", bang = true })
						else
							gitsigns.nav_hunk("prev")
						end
					end)

					-- Actions
					map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "stage hunk" })
					map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "reset hunk" })
					map("v", "<leader>gs", function()
						gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "stage hunk" })
					map("v", "<leader>gr", function()
						gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "reset hunk" })
					map("n", "<leader>gS", gitsigns.stage_buffer, { desc = "reset buffer" })
					map("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "undo stage hunk" })
					map("n", "<leader>gR", gitsigns.reset_buffer, { desc = "reset buffer" })
					map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "preview hunk" })
					map("n", "<leader>gb", function()
						gitsigns.blame_line({ full = true })
					end)
					map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
					map("n", "<leader>gd", gitsigns.diffthis, { desc = "show diff" })
					map("n", "<leader>gD", function()
						gitsigns.diffthis("~")
					end)
					map("n", "<leader>td", gitsigns.toggle_deleted)

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
				end,
			})
		end,
	},
}
