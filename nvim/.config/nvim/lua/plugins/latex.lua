return {
	"lervag/vimtex",
	ft = { "tex", "latex", "bib" },
	init = function()
		-- Viewer settings (Zathura with SyncTeX)
		vim.g.vimtex_view_method = "general"
		vim.g.vimtex_view_general_viewer = "zathura"
		vim.g.vimtex_view_general_options = [[--synctex-forward @line:1:@tex @pdf -x "nvr --remote +%{line} %{input}"]]

		-- Compiler settings (latexmk)
		vim.g.vimtex_compiler_method = "latexmk"
		vim.g.vimtex_compiler_latexmk = {
			callback = 1,
			continuous = 1,
			executable = "latexmk",
			options = {
				"-pdf",
				"-shell-escape",
				"-verbose",
				"-file-line-error",
				"-synctex=1",
				"-interaction=nonstopmode",
			},
		}

		-- Don't open quickfix on warnings, only on errors
		vim.g.vimtex_quickfix_mode = 2
		vim.g.vimtex_quickfix_open_on_warning = 0

		-- Disable imaps (use snippets instead)
		vim.g.vimtex_imaps_enabled = 0

		-- Enable folding
		vim.g.vimtex_fold_enabled = 1

		-- Syntax conceal settings
		vim.g.vimtex_syntax_conceal = {
			accents = 1,
			ligatures = 1,
			cites = 1,
			fancy = 1,
			spacing = 1,
			greek = 1,
			math_bounds = 1,
			math_delimiters = 1,
			math_fracs = 1,
			math_super_sub = 1,
			math_symbols = 1,
			sections = 0,
			styles = 1,
		}

		-- TOC settings
		vim.g.vimtex_toc_config = {
			name = "TOC",
			layers = { "content", "todo", "include" },
			split_width = 25,
			todo_sorted = 0,
			show_help = 1,
			show_numbers = 1,
		}

		-- Disable default mappings to set custom ones
		vim.g.vimtex_mappings_enabled = 1
	end,
	config = function()
		-- Set up filetype-specific keymaps
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "tex", "latex" },
			callback = function()
				local opts = { buffer = true, silent = true }

				-- Compilation
				vim.keymap.set("n", "<localleader>ll", "<cmd>VimtexCompile<cr>", opts)
				vim.keymap.set("n", "<localleader>lk", "<cmd>VimtexStop<cr>", opts)
				vim.keymap.set("n", "<localleader>lK", "<cmd>VimtexStopAll<cr>", opts)
				vim.keymap.set("n", "<localleader>lc", "<cmd>VimtexClean<cr>", opts)
				vim.keymap.set("n", "<localleader>lC", "<cmd>VimtexClean!<cr>", opts)

				-- View
				vim.keymap.set("n", "<localleader>lv", "<cmd>VimtexView<cr>", opts)

				-- TOC
				vim.keymap.set("n", "<localleader>lt", "<cmd>VimtexTocToggle<cr>", opts)

				-- Info/status
				vim.keymap.set("n", "<localleader>li", "<cmd>VimtexInfo<cr>", opts)
				vim.keymap.set("n", "<localleader>ls", "<cmd>VimtexStatus<cr>", opts)
				vim.keymap.set("n", "<localleader>le", "<cmd>VimtexErrors<cr>", opts)
			end,
		})

		-- Integrate with texlab LSP (disable vimtex's omnifunc to use LSP completion)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "tex", "latex", "bib" },
			callback = function()
				vim.bo.omnifunc = ""
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "tex", "latex" },
			callback = function()
				vim.opt_local.conceallevel = 2
			end,
		})
	end,
}
