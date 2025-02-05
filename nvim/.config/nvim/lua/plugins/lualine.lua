return {
	"nvim-lualine/lualine.nvim",
	name = "lualine",
	dependencies = { "nvim-tree/nvim-web-devicons", opt = true },
	config = function()
		local status, lualine = pcall(require, "lualine")
		if not status then
			print("lualine does not work")
			return
		end

		lualine.setup({
			options = {
				theme = "auto",
				icons_enabled = true,
				component_separators = "|",
				section_separators = "",
			},
		})

		vim.opt.fillchars = {
			stlnc = "─",
		}
	end,
}
