local M = {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
}

M.config = function()
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
            -- vim.keymap.set({ 'n', 'x' }, '<F3>', '<CMD>lua vim.lsp.buf.format({async = false})<CR>', opts)
            vim.keymap.set('n', '<F4>', '<CMD>lua vim.lsp.buf.code_action()<CR>', opts)

            vim.keymap.set('n', '<leader>fd', "<CMD>Telescope diagnostics<CR>", opts)
            vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)

            vim.keymap.set("n", 'gh',
                function()
                    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ 0 }), { 0 })
                end)
        end
    })

    local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

    local default_setup = function(server)
        require('lspconfig')[server].setup({
            capabilities = lsp_capabilities,
        })
    end

    require('mason').setup({
        ui = {
            border = "rounded",
        }
    })

    require('mason-tool-installer').setup({
        ensure_installed = {
            -- lsp
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
            "verible",
        },
    })

    require('mason-lspconfig').setup({
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
            end,
            verible = function()
                require('lspconfig').verible.setup({
                    capabilities = lsp_capabilities,
                    root_dir = vim.fn.getcwd()
                })
            end,
            rust_analyzer = function()
                require('lspconfig').rust_analyzer.setup({
                    capabilities = lsp_capabilities,
                    settings = {
                        ['rust-analyzer'] = {
                            inlayHints = {
                                reborrowHints = {
                                    enable = true
                                },
                                lifetimeElisionHints = {
                                    enable = "always",
                                },
                                genericParameterHints = {
                                    const = true,
                                    lifetime = true,
                                    type = true,
                                },
                                implicitDrops = {
                                    enable = true
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
end

return M
