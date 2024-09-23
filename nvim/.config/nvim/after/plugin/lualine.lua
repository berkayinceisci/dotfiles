local status, lualine = pcall(require, 'lualine')
if not status then
    print('lualine does not work')
    return
end

lualine.setup {
    options = {
        icons_enabled = true,
        component_separators = '|',
        section_separators = '',
    },
    sections = {
        lualine_a = { 'buffers' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {},
    }

}
