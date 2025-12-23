return {
	"nvim-telescope/telescope.nvim",
	tag = "v0.2.0",
	dependencies = "nvim-lua/plenary.nvim",
	config = function()
		local status, telescope = pcall(require, "telescope")
		if not status then
			print("telescope does not work")
			return
		end

		local actions = require("telescope.actions")
		telescope.setup({
			defaults = {
				-- Default configuration for telescope goes here:
				-- config_key = value,
				mappings = {
					i = {
						-- map actions.which_key to <C-h> (default: <C-/>)
						-- actions.which_key shows the mappings for your picker,
						-- e.g. git_{create, delete, ...}_branch for the git_branches picker
						["<C-h>"] = actions.preview_scrolling_left,
						["<C-l>"] = actions.preview_scrolling_right,
					},
				},
				vimgrep_arguments = {
					"rg",
					"--follow", -- Follow symbolic links
					"--hidden", -- Search for hidden files
					"--no-heading", -- Don't group matches by each file
					"--with-filename", -- Print the file path with the matched lines
					"--line-number", -- Show line numbers
					"--column", -- Show column numbers
					"--smart-case", -- Smart case search

					-- Exclude some patterns from search
					"--glob=!**/.git/*",
					"--glob=!**/.idea/*",
					"--glob=!**/.vscode/*",
					"--glob=!**/build/*",
					"--glob=!**/dist/*",
					"--glob=!**/yarn.lock",
					"--glob=!**/package-lock.json",
				},
			},
			pickers = {
				find_files = {
					find_command = {
						"fd",
						"--type",
						"f",
						"--color=never",
						"--hidden",
						"--follow",
						"-E",
						".git/*",
					},
				},
			},
		})

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>ff", builtin.find_files)
		vim.keymap.set("n", "<leader>fg", builtin.live_grep)
		vim.keymap.set("n", "<leader>f?", builtin.help_tags)
		vim.keymap.set("n", "<leader>fh", builtin.command_history)
		vim.keymap.set("n", "<leader>fs", builtin.grep_string)
	end,
}
