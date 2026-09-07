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

		-- Ctrl+Backspace = delete previous word in lazygit's text inputs (commit
		-- message, search, prompts). Those inputs are gocui's, and gocui/tcell fold
		-- both ^H (0x08) and DEL into a plain Backspace, so lazygit deletes a single
		-- char; ESC DEL it ignores outright. It does decode the CSI-u encoding of
		-- Ctrl+Backspace, \e[127;5u, as word-delete, so send that. Ctrl+W would work
		-- too but is not used: lazygit binds <c-w> globally to
		-- toggleWhitespaceInDiffView, so pressing Ctrl+Backspace outside a text input
		-- would silently flip that setting, whereas \e[127;5u is inert there.
		--
		-- Two maps because the byte depends on the terminal: wezterm.lua pins
		-- Ctrl+Backspace to ESC DEL, which nvim names <M-BS>, while terminals that do
		-- no such pinning still send legacy ^H.
		--
		-- Ctrl+Left / Ctrl+Right need no translation: lazygit parses \e[1;5D / \e[1;5C
		-- natively. It could not before 0.64 -- tcell only learned those xterm-style
		-- modified-cursor sequences from terminfo's kLFT5/kRIT5 caps, absent from our
		-- screen-256color TERM -- so this used to rewrite them to Alt+Left/Alt+Right,
		-- which 0.64 in turn ignores. Requires lazygit >= 0.64 everywhere.
		--
		-- ~/.config/tmux/tmux.conf does the same rewrite for panes whose foreground
		-- process IS lazygit, but here lazygit runs inside nvim's floating terminal,
		-- so the pane's process is nvim and that gate cannot see it -- hence this
		-- side too, writing the bytes straight to the terminal job.
		--
		-- Buffer-local on purpose -- a global tnoremap would hijack Ctrl+Backspace in
		-- ordinary :terminal shells, where zsh already handles it. lazygit.nvim sets
		-- filetype=lazygit on the buffer before turning it into a terminal, which is
		-- the only hook it offers; the channel is therefore read at keypress time, not
		-- now, since it does not exist yet.
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "lazygit",
			desc = "Translate Ctrl+Backspace for lazygit's gocui inputs",
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
				-- \27 = ESC, so this is ESC [ 127;5u -- Ctrl+Backspace in CSI-u.
				vim.keymap.set("t", "<C-h>", send("\27[127;5u"), opts)
				vim.keymap.set("t", "<M-BS>", send("\27[127;5u"), opts)
			end,
		})
	end,
}
