return {
	"akinsho/bufferline.nvim",
	name = "bufferline",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		require("bufferline").setup({
			options = {
				mode = "buffers",
				offsets = {
					{
						filetype = "NvimTree",
						text = "File Explorer",
						highlight = "Directory",
						separator = true,
					},
				},
			},
		})

		-- switch between buffers
		vim.keymap.set("n", "<C-h>", "<cmd>BufferLineCyclePrev<CR>")
		vim.keymap.set("n", "<C-l>", "<cmd>BufferLineCycleNext<CR>")
		-- swap buffers
		vim.keymap.set("n", "<C-j>", "<cmd>BufferLineMovePrev<CR>")
		vim.keymap.set("n", "<C-k>", "<cmd>BufferLineMoveNext<CR>")
	end,
}
