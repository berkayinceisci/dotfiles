-- return {
-- 	"christoomey/vim-tmux-navigator",
-- 	cmd = {
-- 		"TmuxNavigateLeft",
-- 		"TmuxNavigateDown",
-- 		"TmuxNavigateUp",
-- 		"TmuxNavigateRight",
-- 	},
-- 	keys = {
-- 		{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
-- 		{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
-- 		{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
-- 		{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
-- 	},
-- }

local M = {
	"mrjones2014/smart-splits.nvim",
	version = ">=2.0.0",
}

M.config = function()
	-- moving between splits
	vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
	vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
	vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
	vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)

	-- resizing splits
	vim.keymap.set("n", "<C-S-Left>", require("smart-splits").resize_left)
	vim.keymap.set("n", "<C-S-Down>", require("smart-splits").resize_down)
	vim.keymap.set("n", "<C-S-Up>", require("smart-splits").resize_up)
	vim.keymap.set("n", "<C-S-Right>", require("smart-splits").resize_right)

	-- swapping buffers between windows
	vim.keymap.set("n", "<leader><leader>h", require("smart-splits").swap_buf_left)
	vim.keymap.set("n", "<leader><leader>j", require("smart-splits").swap_buf_down)
	vim.keymap.set("n", "<leader><leader>k", require("smart-splits").swap_buf_up)
	vim.keymap.set("n", "<leader><leader>l", require("smart-splits").swap_buf_right)
end

return M
