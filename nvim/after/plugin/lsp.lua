local lsp = require('lsp-zero').preset({})

lsp.ensure_installed({
    "clangd",
    "cmake",
    "dockerls",
    "docker_compose_language_service",
    "bashls",
    "cssls",
    "html",
    "jsonls",
    "tsserver",
    "lua_ls",
    "pyright",
    "rust_analyzer",
    "taplo",
    "svlangserver"
})

lsp.on_attach(function(_, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp.default_keymaps({ buffer = bufnr })
end)

-- (Optional) Configure lua language server for neovim
-- If omitted, "vim" variable cannot be detected by lsp
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup_nvim_cmp({
    preselect = 'none',
    completion = {
        completeopt = 'menu,menuone,noinsert,noselect'
    },
})

lsp.setup()

-- setup signature plugin
local cfg = {
    bind = true,
    doc_lines = 0, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
    -- set to 0 if you DO NOT want any API comments be shown
    -- This setting only take effect in insert mode, it does not affect signature help in normal
    -- mode, 10 by default

    floating_window = true,                    -- show hint in a floating window, set to false for virtual text only mode
    hint_enable = false,                        -- virtual hint enable
}

-- recommended:
require 'lsp_signature'.setup(cfg) -- no need to specify bufnr if you don't use toggle_key

