function Color(color)
    color = color or "catppuccin" -- default

    if color == "base16" then
        local fav_base16_colors = {
            atelier_dune = "base16-atelier-dune",
            atelier_forest = "base16-atelier-forest",
            atelier_estuary = "base16-atelier-estuary",
        }
        color = fav_base16_colors.atelier_estuary or "base16-classic-dark"
    elseif color == "rose-pine" then
        require("rose-pine").setup({
            variant = "main", -- main (dark), dawn (light), moon,
            styles = {
                italic = false,
                bold = true,
            },
        })
    elseif color == "catppuccin" then
        require("catppuccin").setup({
            flavour = "frappe",            -- latte (light), frappe, macchiato, mocha
            transparent_background = true, -- disables setting the background color
            no_italic = false,             -- Force no italic
            no_bold = false,               -- Force no bold
            highlight_overrides = {
                all = function(_)
                    return {
                        -- how catppuccin do signature highlights can easily be confused with other colors of the theme
                        LspSignatureActiveParameter = { fg = "#7CFC00" }
                    }
                end,
            },
        })
    end

    vim.cmd.colorscheme(color)
end

-- Color("base16")     -- has a bug (not that harmful) when used with lualine
-- Color("rose-pine")
Color("catppuccin")
