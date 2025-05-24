local M = {
	"mrjones2014/smart-splits.nvim",
	version = ">=2.0.0",
}

M.config = function()
	-- moving between splits
	vim.keymap.set("n", "<C-w>h", require("smart-splits").move_cursor_left)
	vim.keymap.set("n", "<C-w>j", require("smart-splits").move_cursor_down)
	vim.keymap.set("n", "<C-w>k", require("smart-splits").move_cursor_up)
	vim.keymap.set("n", "<C-w>l", require("smart-splits").move_cursor_right)
	vim.keymap.set("n", "<C-w><C-h>", require("smart-splits").move_cursor_left)
	vim.keymap.set("n", "<C-w><C-j>", require("smart-splits").move_cursor_down)
	vim.keymap.set("n", "<C-w><C-k>", require("smart-splits").move_cursor_up)
	vim.keymap.set("n", "<C-w><C-l>", require("smart-splits").move_cursor_right)

	-- resizing splits
	vim.keymap.set("n", "<C-S-Left>", require("smart-splits").resize_left)
	vim.keymap.set("n", "<C-S-Down>", require("smart-splits").resize_down)
	vim.keymap.set("n", "<C-S-Up>", require("smart-splits").resize_up)
	vim.keymap.set("n", "<C-S-Right>", require("smart-splits").resize_right)

	-- swapping buffers between windows
	vim.keymap.set("n", "<leader>H", require("smart-splits").swap_buf_left)
	vim.keymap.set("n", "<leader>J", require("smart-splits").swap_buf_down)
	vim.keymap.set("n", "<leader>K", require("smart-splits").swap_buf_up)
	vim.keymap.set("n", "<leader>L", require("smart-splits").swap_buf_right)
end

return M
