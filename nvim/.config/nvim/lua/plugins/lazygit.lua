return {
	"kdheepak/lazygit.nvim",
	lazy = true,
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},
	-- optional for floating window border decoration
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	-- setting the keybinding for LazyGit with 'keys' is recommended in
	-- order to load the plugin when the command is run for the first time
	keys = {
		{ "<leader>.g", "<cmd>LazyGit<cr>", desc = "LazyGit" },
	},
	config = function()
		vim.g.lazygit_use_custom_config_file_path = 1 -- config file path is evaluated if this value is 1
		vim.g.lazygit_config_file_path = vim.fn.expand("~/.config/lazygit/config.yml") -- custom config file path
		vim.g.lazygit_on_exit_callback = function()
			require("gitsigns").refresh()
		end

		-- Word-wise editing in lazygit's text inputs (commit message, search,
		-- prompts). lazygit's inputs are gocui's, and gocui/tcell only recognise
		-- word-delete on Alt+Backspace and word-motion on Alt+Left/Alt+Right --
		-- see the `ModAlt` cases in lazygit's pkg/gui/editors.go. Ctrl+Arrow arrives
		-- as \e[1;5D / \e[1;5C, which tcell can only decode via terminfo's
		-- kLFT5/kRIT5 caps; those are absent from our screen-256color TERM, so the
		-- arrows do nothing useful untranslated. Ctrl+Backspace from WezTerm is
		-- already ESC DEL (Alt+Backspace) and lazygit handles it natively.
		--
		-- ~/.config/tmux/tmux.conf rewrites these keys for panes whose foreground
		-- process IS lazygit, but here lazygit runs inside nvim's floating terminal,
		-- so the pane's process is nvim and that gate cannot see it. Translate the
		-- arrows, plus legacy ^H as a fallback, on this side by writing Alt-flavoured
		-- bytes straight to the terminal job. ESC-prefix is how tcell derives ModAlt,
		-- generically, without consulting terminfo.
		--
		-- Buffer-local on purpose -- a global tnoremap would break Ctrl+Arrow in
		-- ordinary :terminal shells, where zsh wants the \e[1;5D form it binds in
		-- .zshrc. lazygit.nvim sets filetype=lazygit on the buffer before turning
		-- it into a terminal, which is the only hook it offers; the channel is
		-- therefore read at keypress time, not now, since it does not exist yet.
		--
		-- The <C-h> map is a fallback for terminals that still encode
		-- Ctrl+Backspace as legacy ^H (0x08): turn that into ESC DEL before it reaches
		-- lazygit. It is not used on the WezTerm path, where wezterm.lua emits ESC DEL
		-- directly. Ctrl+Arrow still needs the buffer-local translations below.
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "lazygit",
			desc = "Translate Ctrl+Backspace/Ctrl+Arrow for lazygit's gocui inputs",
			callback = function(ev)
				local function send(bytes)
					return function()
						local chan = vim.bo[ev.buf].channel
						if chan ~= 0 then
							vim.api.nvim_chan_send(chan, bytes)
						end
					end
				end
				local opts = { buffer = ev.buf, silent = true }
				-- \27 = ESC, \127 = DEL. ESC DEL = Alt+Backspace; ESC ESC [ D/C =
				-- Alt+Left / Alt+Right (ESC + the unmodified cursor sequence).
				vim.keymap.set("t", "<C-h>", send("\27\127"), opts)
				vim.keymap.set("t", "<C-Left>", send("\27\27[D"), opts)
				vim.keymap.set("t", "<C-Right>", send("\27\27[C"), opts)
			end,
		})
	end,
}
