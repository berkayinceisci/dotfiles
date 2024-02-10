local status, lualine = pcall(require, 'lualine')
if not status then
    print('lualine does not work')
    return
end

lualine.setup()
