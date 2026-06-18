return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main", -- main-branch rewrite (requires Neovim 0.12+)
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		lazy = vim.fn.argc(-1) == 0,
		config = function()
			-- ensure_installed/auto_install no longer exist on the main branch.
			-- Install only the parsers that are not already present so startup
			-- doesn't recompile everything every time.
			local ensure_installed = {
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
				"diff",
				"ssh_config",
				"csv",
			}
			local already_installed = require("nvim-treesitter.config").get_installed()
			local to_install = vim.iter(ensure_installed)
				:filter(function(parser)
					return not vim.tbl_contains(already_installed, parser)
				end)
				:totable()
			if #to_install > 0 then
				require("nvim-treesitter").install(to_install)
			end

			-- Highlighting is per-buffer on the main branch: start it from a
			-- FileType autocmd instead of the old `highlight = { enable = true }`.
			-- latex/bibtex are intentionally excluded (we ignore those parsers).
			local no_treesitter = {
				latex = true,
				tex = true,
				bib = true,
				bibtex = true,
			}
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					if no_treesitter[vim.bo[args.buf].filetype] then
						return
					end
					pcall(vim.treesitter.start)
				end,
			})

			-- The FileType event for the buffer that triggered lazy-loading may
			-- have already fired, so start treesitter for loaded buffers now.
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(buf) and not no_treesitter[vim.bo[buf].filetype] then
					vim.api.nvim_buf_call(buf, function()
						pcall(vim.treesitter.start)
					end)
				end
			end

			-- Incremental selection: the master-branch `incremental_selection`
			-- module was removed in the rewrite, so reimplement the subset we
			-- used (<leader>v to start/grow, <bs> to shrink).
			local function node_range_equal(a, b)
				local a1, a2, a3, a4 = a:range()
				local b1, b2, b3, b4 = b:range()
				return a1 == b1 and a2 == b2 and a3 == b3 and a4 == b4
			end

			local selections = {} -- per-window stack of selected nodes

			local function select_node(node)
				local start_row, start_col, end_row, end_col = node:range()
				-- treesitter: rows 0-based; start_col 0-based inclusive,
				-- end_col 0-based exclusive. setpos cols are 1-based inclusive.
				if end_col == 0 then
					-- range ends at column 0 of the next line: back up to the
					-- end of the previous line so the mark stays on real text.
					end_row = end_row - 1
					end_col = #vim.fn.getline(end_row + 1)
				end
				vim.fn.setpos("'<", { 0, start_row + 1, start_col + 1, 0 })
				vim.fn.setpos("'>", { 0, end_row + 1, end_col, 0 })
				vim.cmd("normal! gv")
			end

			local function sel_init()
				local node = vim.treesitter.get_node()
				if not node then
					return
				end
				selections[vim.api.nvim_get_current_win()] = { node }
				select_node(node)
			end

			local function sel_increment()
				local win = vim.api.nvim_get_current_win()
				local stack = selections[win]
				if not stack or #stack == 0 then
					sel_init()
					return
				end
				local node = stack[#stack]
				local parent = node:parent()
				-- skip parents that don't actually expand the range
				while parent and node_range_equal(parent, node) do
					parent = parent:parent()
				end
				if parent then
					table.insert(stack, parent)
					select_node(parent)
				else
					select_node(node)
				end
			end

			local function sel_decrement()
				local stack = selections[vim.api.nvim_get_current_win()]
				if not stack or #stack <= 1 then
					return
				end
				table.remove(stack)
				select_node(stack[#stack])
			end

			vim.keymap.set("n", "<leader>v", sel_init, { desc = "Init selection" })
			vim.keymap.set("x", "<leader>v", sel_increment, { desc = "Increment selection" })
			vim.keymap.set("x", "<bs>", sel_decrement, { desc = "Decrement selection" })
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main", -- main-branch rewrite, matching nvim-treesitter
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
				},
				move = {
					set_jumps = true,
				},
			})

			-- Select (visual + operator-pending). The old `keymaps` table under
			-- configs.setup is gone; on main each mapping calls the API directly.
			local select_keymaps = {
				["a="] = { "@assignment.outer", "Select outer part of an assignment" },
				["i="] = { "@assignment.inner", "Select inner part of an assignment" },
				["a;"] = { "@statement.outer", "Select outer part of a statement" },
				["aa"] = { "@parameter.outer", "Select outer part of a parameter" },
				["ia"] = { "@parameter.inner", "Select inner part of a parameter" },
				["ai"] = { "@conditional.outer", "Select outer part of a conditional" },
				["ii"] = { "@conditional.inner", "Select inner part of a conditional" },
				["al"] = { "@loop.outer", "Select outer part of a loop" },
				["il"] = { "@loop.inner", "Select inner part of a loop" },
				["af"] = { "@function.outer", "Select outer part of a function" },
				["if"] = { "@function.inner", "Select inner part of a function" },
				["as"] = { "@class.outer", "Select outer part of a struct/class" },
				["is"] = { "@class.inner", "Select inner part of a struct/class" },
			}
			for lhs, spec in pairs(select_keymaps) do
				local query, desc = spec[1], spec[2]
				vim.keymap.set({ "x", "o" }, lhs, function()
					require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
				end, { desc = desc })
			end

			-- Swap
			vim.keymap.set("n", " l", function()
				require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
			end, { desc = "Swap next parameter" })
			vim.keymap.set("n", " h", function()
				require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
			end, { desc = "Swap previous parameter" })

			-- Move
			local moves = {
				goto_next_start = {
					["];"] = { "@statement.outer", "Next statement start" },
					["]a"] = { "@parameter.outer", "Next argument/parameter start" },
					["]f"] = { "@function.outer", "Next method/function def start" },
					["]s"] = { "@class.outer", "Next struct/class start" },
					["]i"] = { "@conditional.outer", "Next conditional start" },
					["]l"] = { "@loop.outer", "Next loop start" },
				},
				goto_next_end = {
					["]A"] = { "@parameter.outer", "Next argument/parameter end" },
					["]F"] = { "@function.outer", "Next method/function def end" },
					["]S"] = { "@class.outer", "Next struct/class end" },
					["]I"] = { "@conditional.outer", "Next conditional end" },
					["]L"] = { "@loop.outer", "Next loop end" },
				},
				goto_previous_start = {
					["[;"] = { "@statement.outer", "Prev statement start" },
					["[f"] = { "@function.outer", "Prev method/function def start" },
					["[s"] = { "@class.outer", "Prev struct/class start" },
					["[i"] = { "@conditional.outer", "Prev conditional start" },
					["[l"] = { "@loop.outer", "Prev loop start" },
				},
				goto_previous_end = {
					["[F"] = { "@function.outer", "Prev method/function def end" },
					["[S"] = { "@class.outer", "Prev struct/class end" },
					["[I"] = { "@conditional.outer", "Prev conditional end" },
					["[L"] = { "@loop.outer", "Prev loop end" },
				},
			}
			for fn_name, maps in pairs(moves) do
				for lhs, spec in pairs(maps) do
					local query, desc = spec[1], spec[2]
					vim.keymap.set({ "n", "x", "o" }, lhs, function()
						require("nvim-treesitter-textobjects.move")[fn_name](query, "textobjects")
					end, { desc = desc })
				end
			end

			-- Repeatable move
			local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
			vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
			vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
			vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
		end,
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
