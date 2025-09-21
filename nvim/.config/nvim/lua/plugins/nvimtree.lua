return {
	"nvim-tree/nvim-tree.lua",
	dependencies = "b0o/nvim-tree-preview.lua",
	config = function()
		-- disable netrw at the very start of your init.lua (strongly advised)
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		-- set termguicolors to enable highlight groups
		vim.opt.termguicolors = true

		local sorter = function(nodes)
			table.sort(nodes, function(a, b)
				local function natural_compare(str1, str2)
					local i1, i2 = 1, 1

					while i1 <= #str1 and i2 <= #str2 do
						local c1, c2 = str1:sub(i1, i1), str2:sub(i2, i2)

						-- If both characters are digits, compare the whole numbers
						if c1:match("%d") and c2:match("%d") then
							local num1, num2 = "", ""

							-- Extract full number from str1
							while i1 <= #str1 and str1:sub(i1, i1):match("%d") do
								num1 = num1 .. str1:sub(i1, i1)
								i1 = i1 + 1
							end

							-- Extract full number from str2
							while i2 <= #str2 and str2:sub(i2, i2):match("%d") do
								num2 = num2 .. str2:sub(i2, i2)
								i2 = i2 + 1
							end

							local n1, n2 = tonumber(num1), tonumber(num2)
							if n1 ~= n2 then
								return n1 < n2
							end
						else
							-- Regular character comparison
							if c1 ~= c2 then
								return c1 < c2
							end
							i1, i2 = i1 + 1, i2 + 1
						end
					end

					-- If one string is shorter, it comes first
					return #str1 < #str2
				end

				return natural_compare(a.name, b.name)
			end)
		end

		require("nvim-tree").setup({
			sort_by = sorter,
			renderer = {
				group_empty = true,
			},
			filters = {
				dotfiles = false,
			},
			update_focused_file = {
				enable = true,
				update_root = true,
			},
			actions = {
				open_file = {
					quit_on_open = true,
				},
			},
			on_attach = function(bufnr)
				local api = require("nvim-tree.api")
				local lib = require("nvim-tree.lib")

				-- Important: When you supply an `on_attach` function, nvim-tree won't
				-- automatically set up the default keymaps. To set up the default keymaps,
				-- call the `default_on_attach` function. See `:help nvim-tree-quickstart-custom-mappings`.
				api.config.mappings.default_on_attach(bufnr)

				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				-- grug-far
				local grug_far_replace = function()
					local node = lib.get_node_at_cursor()
					if node then
						local prefills = {
							-- get the current path and get the parent directory if a file is selected
							paths = node.type == "directory" and node.absolute_path
								or vim.fn.fnamemodify(node.absolute_path, ":h"),
						}

						local grug_far = require("grug-far")
						-- instance check
						if not grug_far.has_instance("explorer") then
							grug_far.open({
								instanceName = "explorer",
								prefills = prefills,
								staticTitle = "Find and Replace from Explorer",
							})
						else
							grug_far.open_instance("explorer")
							-- updating the prefills without clearing the search and other fields
							grug_far.update_instance_prefills("explorer", prefills, false)
						end
					end
				end

				vim.keymap.set("n", "S", grug_far_replace, opts("Search in directory"))

				-- nvim-tree-preview
				local preview = require("nvim-tree-preview")

				vim.keymap.set("n", "P", preview.watch, opts("Preview (Watch)"))
				vim.keymap.set("n", "<Esc>", preview.unwatch, opts("Close Preview/Unwatch"))

				-- Option A: Smart tab behavior: Only preview files, expand/collapse directories (recommended)
				vim.keymap.set("n", "<Tab>", function()
					local ok, node = pcall(api.tree.get_node_under_cursor)
					if ok and node then
						if node.type == "directory" then
							api.node.open.edit()
						else
							preview.node(node, { toggle_focus = true })
						end
					end
				end, opts("Preview"))

				-- Option B: Simple tab behavior: Always preview
				-- vim.keymap.set('n', '<Tab>', preview.node_under_cursor, opts 'Preview')
			end,
		})

		vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
	end,
}
