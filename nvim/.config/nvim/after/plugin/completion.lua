local cmp = require('cmp')

cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'nvim_lsp_signature_help' },
    },
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    preselect = 'none',
    completion = {
        completeopt = 'menu,menuone,noinsert,noselect'
    },
    window = {
        documentation = cmp.config.window.bordered(),
        completion = cmp.config.window.bordered({
            winhighlight = 'Normal:CmpPmenu,CursorLine:PmenuSel,Search:None'
        }),
    },
    mapping = cmp.mapping.preset.insert({
        ["<CR>"] = cmp.mapping({
            i = function(fallback)
                if cmp.visible() and cmp.get_active_entry() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                else
                    fallback()
                end
            end,
            s = cmp.mapping.confirm({ select = true }),
            c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
        }),
        ['<C-k>'] = cmp.mapping({
            i = function()
                if cmp.visible() then
                    cmp.close()
                    vim.lsp.buf.signature_help()
                else
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        -- close signature help window
                        if vim.api.nvim_win_get_config(win).relative == "win" then
                            vim.api.nvim_win_close(win, false)
                        end
                    end
                    cmp.complete()
                end
            end,
        }),
    }),
})
