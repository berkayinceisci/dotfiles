function Color(color)
  color = color or "rose-pine"

  if color == "rose-pine" then
    require("rose-pine").setup({ disable_italics = true, disable_background = false })
  end

  vim.cmd.colorscheme(color)
end

Color()
