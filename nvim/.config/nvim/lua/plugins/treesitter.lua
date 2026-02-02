return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master", -- Use old stable API (new version is incompatible rewrite)
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		lazy = vim.fn.argc(-1) == 0,
		config = function()
			require("nvim-treesitter.configs").setup({
				ignore_install = { "latex", "bibtex" },
				ensure_installed = {
					"bash",
					"c",
					"cpp",
					"make",
					"lua",
					"toml",
					"json",
					"vim",
					"vimdoc",
					"markdown",
					"markdown_inline",
					"query",
					"rust",
					"javascript",
					"typescript",
					"python",
				},
				sync_install = false,
				auto_install = true,
				highlight = {
					enable = true,
					disable = { "latex" },
					additional_vim_regex_highlighting = false,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<leader>v",
						node_incremental = "<leader>v",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
							["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
							["a;"] = { query = "@statement.outer", desc = "Select outer part of a statement" },
							["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter" },
							["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter" },
							["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
							["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },
							["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
							["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },
							["af"] = { query = "@function.outer", desc = "Select outer part of a function" },
							["if"] = { query = "@function.inner", desc = "Select inner part of a function" },
							["as"] = { query = "@class.outer", desc = "Select outer part of a struct/class" },
							["is"] = { query = "@class.inner", desc = "Select inner part of a struct/class" },
						},
					},
					swap = {
						enable = true,
						swap_next = { [" l"] = "@parameter.inner" },
						swap_previous = { [" h"] = "@parameter.inner" },
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["];"] = { query = "@statement.outer", desc = "Next statement start" },
							["]a"] = { query = "@parameter.outer", desc = "Next argument/parameter start" },
							["]f"] = { query = "@function.outer", desc = "Next method/function def start" },
							["]s"] = { query = "@class.outer", desc = "Next struct/class start" },
							["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
							["]l"] = { query = "@loop.outer", desc = "Next loop start" },
						},
						goto_next_end = {
							["]A"] = { query = "@parameter.outer", desc = "Next argument/parameter end" },
							["]F"] = { query = "@function.outer", desc = "Next method/function def end" },
							["]S"] = { query = "@class.outer", desc = "Next struct/class end" },
							["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
							["]L"] = { query = "@loop.outer", desc = "Next loop end" },
						},
						goto_previous_start = {
							["[;"] = { query = "@statement.outer", desc = "Prev statement start" },
							["[f"] = { query = "@function.outer", desc = "Prev method/function def start" },
							["[s"] = { query = "@class.outer", desc = "Prev struct/class start" },
							["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
							["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
						},
						goto_previous_end = {
							["[F"] = { query = "@function.outer", desc = "Prev method/function def end" },
							["[S"] = { query = "@class.outer", desc = "Prev struct/class end" },
							["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
							["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
						},
					},
				},
			})

			-- Repeatable move setup
			local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
			vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
			vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
			vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		lazy = true,
	},

	-- 3. Treesitter Context
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("treesitter-context").setup({
				enable = true,
				max_lines = 0,
				min_window_height = 0,
				line_numbers = true,
				multiline_threshold = 20,
				trim_scope = "outer",
				mode = "cursor",
				zindex = 20,
			})

			vim.keymap.set("n", "[x", function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end, { silent = true, desc = "Jump to context header" })
		end,
	},
}
