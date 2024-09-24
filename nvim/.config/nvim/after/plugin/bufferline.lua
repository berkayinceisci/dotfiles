require("bufferline").setup {
    options = {
        mode = 'buffers',
        offsets = {
            {
                filetype = 'NvimTree',
                text = 'File Explorer',
                highlight = 'Directory',
                separator = true
            }
        }
    }
}

-- choose buffer
vim.keymap.set("n", "<leader>cb", ":BufferLinePick<CR>")
