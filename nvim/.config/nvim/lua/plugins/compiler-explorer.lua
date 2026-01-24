local function get_compiler_version(cmd)
	local handle = io.popen(cmd .. " 2>/dev/null")
	if not handle then
		return nil
	end
	local result = handle:read("*a")
	handle:close()
	return result
end

local function detect_gcc_version()
	local output = get_compiler_version("gcc --version")
	if output then
		local major, minor = output:match("(%d+)%.(%d+)")
		if major and minor then
			return string.format("cg%s%s", major, minor)
		end
	end
	return nil
end

local function detect_gpp_version()
	local output = get_compiler_version("g++ --version")
	if output then
		local major, minor = output:match("(%d+)%.(%d+)")
		if major and minor then
			return string.format("g%s%s", major, minor)
		end
	end
	return nil
end

local function detect_rust_version()
	local output = get_compiler_version("rustc --version")
	if output then
		local major, minor, patch = output:match("(%d+)%.(%d+)%.(%d+)")
		if major and minor and patch then
			return string.format("r%s%s%s0", major, minor, patch)
		end
	end
	return nil
end

local compilers = {
	c = detect_gcc_version(),
	cpp = detect_gpp_version(),
	rust = detect_rust_version(),
}

local function get_compiler_for_filetype()
	return compilers[vim.bo.filetype]
end

local preprocessors = {
	c = "gcc -E -P",
	cpp = "g++ -E -P",
}

local function compile()
	local ft = vim.bo.filetype
	local compiler = compilers[ft]
	local preprocessor = preprocessors[ft]

	if preprocessor then
		local file = vim.fn.expand("%:p")
		local dir = vim.fn.expand("%:p:h")
		-- Preprocess with include path set to file's directory
		local output = vim.fn.system(preprocessor .. " -I" .. dir .. " " .. file .. " 2>&1")

		if vim.v.shell_error ~= 0 then
			vim.notify("Preprocessing failed:\n" .. output, vim.log.levels.ERROR)
			return
		end

		-- Create scratch buffer with preprocessed content
		vim.cmd("enew")
		vim.bo.buftype = "nofile"
		vim.bo.filetype = ft
		vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n"))
	end

	vim.ui.input({ prompt = "Compiler flags: " }, function(flags)
		if flags == nil then
			return
		end
		local cmd = compiler and ("CECompile compiler=" .. compiler) or "CECompile"
		if flags ~= "" then
			cmd = cmd .. " flags=" .. flags
		end
		vim.cmd(cmd)
	end)
end

local function compile_visual()
	local ft = vim.bo.filetype
	local compiler = compilers[ft]
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)

	vim.ui.input({ prompt = "Compiler flags: " }, function(flags)
		if flags == nil then
			return
		end
		local cmd = compiler and ("'<,'>CECompile compiler=" .. compiler) or "'<,'>CECompile"
		if flags ~= "" then
			cmd = cmd .. " flags=" .. flags
		end
		vim.cmd(cmd)
	end)
end

return {
	"krady21/compiler-explorer.nvim",
	cmd = { "CECompile", "CECompileLive", "CEFormat", "CEAddLibrary", "CELoadExample", "CEOpenWebsite" },
	keys = {
		{ "<leader>ce", compile, mode = "n", desc = "Compile buffer (Compiler Explorer)" },
		{ "<leader>ce", compile_visual, mode = "v", desc = "Compile selection (Compiler Explorer)" },
		{ "<leader>cl", ":CECompileLive<CR>", mode = "n", desc = "Compile live (auto on save)" },
		{ "<leader>ct", ":CEShowTooltip<CR>", mode = "n", desc = "Show instruction tooltip" },
		{ "<leader>cx", ":CEOpenWebsite<CR>", mode = { "n", "v" }, desc = "Open in godbolt.org" },
	},
	opts = {
		line_match = {
			highlight = true,
			jump = false,
		},
		open_qflist = true,
	},
}
