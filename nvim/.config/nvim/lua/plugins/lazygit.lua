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

		-- Word-wise editing in lazygit's text inputs (commit message, search, prompts).
		-- Those inputs are gocui's, and gocui/tcell fold both ^H (0x08) and DEL into a
		-- plain Backspace, so lazygit deletes a single char. Which sequence word-deletes
		-- instead is a PLATFORM split, not a version one -- lazygit v0.65.0 built for
		-- darwin ships the old gocui/tcell input layer while the same version for linux
		-- ships the new one. Verified against each machine's own binary, under
		-- screen-256color, tmux-256color and xterm-256color alike, so not terminfo:
		--
		--                         linux 0.64.1/0.65.0   darwin 0.65.0
		--   ESC b / ESC f              word motion       word motion
		--   \e[1;5D  (Ctrl+Left)       word motion       ignored
		--   \e[127;5u (Ctrl+BS)        word delete       ignored
		--   ESC DEL                    ignored           word delete
		--
		-- So word motion is sent as ESC b / ESC f unconditionally -- the one form both
		-- understand -- while word-delete is chosen per platform below. Ctrl+W would
		-- word-delete on every build and need no split, but lazygit binds <c-w> globally
		-- to toggleWhitespaceInDiffView and nothing here can tell whether a text input
		-- is focused, so Ctrl+Backspace outside one would silently flip that setting.
		--
		-- Two Ctrl+Backspace maps because its byte depends on the terminal: wezterm.lua
		-- pins it to ESC DEL, which nvim names <M-BS>, while terminals that do no such
		-- pinning still send legacy ^H. On darwin both simply re-emit ESC DEL.
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
				-- \27 = ESC, \127 = DEL. So darwin gets ESC DEL and linux gets
				-- ESC [ 127;5u, the CSI-u encoding of Ctrl+Backspace.
				local word_delete = vim.fn.has("mac") == 1 and "\27\127" or "\27[127;5u"
				vim.keymap.set("t", "<C-h>", send(word_delete), opts)
				vim.keymap.set("t", "<M-BS>", send(word_delete), opts)
				vim.keymap.set("t", "<C-Left>", send("\27b"), opts)
				vim.keymap.set("t", "<C-Right>", send("\27f"), opts)
			end,
		})
	end,
}
