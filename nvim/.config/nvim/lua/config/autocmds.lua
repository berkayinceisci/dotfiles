local autocmd_group = vim.api.nvim_create_augroup("lsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
    group = autocmd_group,
    callback = function(args)
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = args.buf,
            callback = function()
                vim.lsp.buf.format { async = false, id = args.data.client_id }
            end,
        })
    end
})
