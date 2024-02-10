local cmp = require('cmp')

local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

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
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                if #cmp.get_entries() == 1 then
                    cmp.confirm({ select = true })
                else
                    cmp.select_next_item()
                end
            elseif has_words_before() then
                cmp.complete()
                if #cmp.get_entries() == 1 then
                    cmp.confirm({ select = true })
                end
            else
                fallback()
            end
        end, { "i", "s" }),
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

