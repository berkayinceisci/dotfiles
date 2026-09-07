-- Re-read DISPLAY from tmux before launching the viewer.
--
-- nvim's environment is a copy made at startup and never updates, so an nvim
-- that outlives an `ssh -Y` connection keeps pointing at a destroyed X11 proxy
-- (or, if its pane was created under mosh, at nothing at all). The viewer is
-- spawned via jobstart and inherits THIS env, not the pane shell's -- which
-- does self-heal, via the refresh-env precmd in zsh/.zsh/functions.zsh.
--
-- Hooked to the keymaps rather than the VimtexEventView autocmd: that event
-- fires AFTER the viewer has already been started (see the doautocmd at the
-- end of s:viewer.view in vimtex's autoload/vimtex/view/_template.vim), which
-- is too late to matter. Setting vim.env applies to the whole nvim process, so
-- one refresh holds until the next reconnect.
--
-- `tmux show-environment DISPLAY` prints either `DISPLAY=localhost:10.0` or
-- the bare unset marker `-DISPLAY`. The pattern below only matches the former,
-- so a marker left by a mosh attach can never clobber a good value -- the same
-- rule refresh-env follows deliberately. No-op outside tmux, and on macOS,
-- where Skim does not use DISPLAY.
local function refresh_display()
	if vim.env.TMUX == nil then
		return
	end
	local out = vim.fn.system({ "tmux", "show-environment", "DISPLAY" })
	if vim.v.shell_error ~= 0 then
		return
	end
	local value = out:match("^DISPLAY=(.-)%s*$")
	if value and value ~= "" then
		vim.env.DISPLAY = value
	end
end

return {
	"lervag/vimtex",
	ft = { "tex", "latex", "bib" },
	init = function()
		-- Viewer settings (OS-specific: Skim on macOS, Zathura on Linux)
		if vim.fn.has("mac") == 1 then
			vim.g.vimtex_view_method = "skim"
			vim.g.vimtex_view_skim_sync = 1
			vim.g.vimtex_view_skim_activate = 1
		else
			vim.g.vimtex_view_method = "general"
			vim.g.vimtex_view_general_viewer = "zathura"
			vim.g.vimtex_view_general_options =
				[[--synctex-forward @line:1:@tex @pdf -x "nvr --remote +%{line} %{input}"]]
		end

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
				vim.keymap.set("n", "<localleader>ll", function()
					refresh_display()
					vim.cmd("VimtexCompile")
				end, opts)
				vim.keymap.set("n", "<localleader>lk", "<cmd>VimtexStop<cr>", opts)
				vim.keymap.set("n", "<localleader>lK", "<cmd>VimtexStopAll<cr>", opts)
				vim.keymap.set("n", "<localleader>lc", "<cmd>VimtexClean<cr>", opts)
				vim.keymap.set("n", "<localleader>lC", "<cmd>VimtexClean!<cr>", opts)

				-- View
				vim.keymap.set("n", "<localleader>lv", function()
					refresh_display()
					vim.cmd("VimtexView")
				end, opts)

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
