vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set('n', 'K', '<CMD>lua vim.lsp.buf.hover()<CR>', opts)
        vim.keymap.set('n', 'gd', '<CMD>lua vim.lsp.buf.definition()<CR>', opts)
        vim.keymap.set('n', 'gD', '<CMD>lua vim.lsp.buf.declaration()<CR>', opts)
        vim.keymap.set('n', 'gt', '<CMD>lua vim.lsp.buf.type_definition()<CR>', opts)
        vim.keymap.set('n', 'gi', '<CMD>lua vim.lsp.buf.implementation()<CR>', opts)
        vim.keymap.set('n', 'gs', '<CMD>lua vim.lsp.buf.signature_help()<CR>', opts)
        vim.keymap.set('n', '<F2>', '<CMD>lua vim.lsp.buf.rename()<CR>', opts)
        vim.keymap.set({ 'n', 'x' }, '<F3>', '<CMD>lua vim.lsp.buf.format({async = true})<CR>', opts)
        vim.keymap.set('n', '<F4>', '<CMD>lua vim.lsp.buf.code_action()<CR>', opts)

        vim.keymap.set('n', '<leader>fp', "<CMD>Telescope diagnostics<CR>", opts)
        vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)
    end
})

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

local default_setup = function(server)
    require('lspconfig')[server].setup({
        capabilities = lsp_capabilities,
    })
end

require('mason').setup()

require('mason-lspconfig').setup({
    ensure_installed = {
        "clangd",
        "cmake",
        "dockerls",
        "docker_compose_language_service",
        "bashls",
        "cssls",
        "html",
        "jsonls",
        "ts_ls",
        "lua_ls",
        "pyright",
        "rust_analyzer",
        "taplo",
        "svlangserver"
    },
    handlers = {
        default_setup,
        lua_ls = function()
            require('lspconfig').lua_ls.setup({
                capabilities = lsp_capabilities,
                settings = {
                    Lua = {
                        runtime = {
                            version = 'LuaJIT'
                        },
                        diagnostics = {
                            globals = { 'vim' },
                        },
                        workspace = {
                            library = {
                                vim.env.VIMRUNTIME,
                            }
                        }
                    }
                }
            })
        end
    },
})

-- setup borders
local _border = "single"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = _border
    }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
        border = _border
    }
)

vim.diagnostic.config {
    float = { border = _border }
}
