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

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()

