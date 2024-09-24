local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local hostname = wezterm.hostname()
local act = wezterm.action

if hostname == 'berkays-air' then
    config.font_size = 18.0
else
    config.font_size = 18.0
    config.font = wezterm.font_with_fallback {
        'Jetbrains Mono',
        'Hack Nerd Font Mono',
    }
end

config.color_scheme = 'Gruvbox Dark (Gogh)'
config.window_decorations = 'RESIZE'
config.use_fancy_tab_bar = false

-- Dim inactive panes
config.inactive_pane_hsb = {
    brightness = 0.4,
    saturation = 0.6
}

if hostname == 'berkays-air' then
    config.macos_window_background_blur = 50
    config.window_background_opacity = 0.5
else
    -- TODO: changing wallpapers
    config.window_background_image = wezterm.home_dir .. '/Wallpapers/1.png'
    config.window_background_image_hsb = {
        -- Darken the background image by reducing it to 1/3rd
        brightness = 0.08,

        -- You can adjust the hue by scaling its value.
        -- a multiplier of 1.0 leaves the value unchanged.
        hue = 1.0,

        -- You can adjust the saturation also.
        saturation = 1.0,
    }
end

config.window_padding = {
    left = 10,
    right = 0,
    top = 10,
    bottom = 0,
}

-- Location(super key on normal keyboard layout) == Location(alt key on mac keyboard layout)
local tab_mode_key
if hostname == 'berkays-air' then
    tab_mode_key = 'ALT'
else
    tab_mode_key = 'SUPER'
end

config.keys = {
    { key = '\r', mods = 'ALT',        action = wezterm.action.DisableDefaultAssignment },
    { key = '\r', mods = tab_mode_key, action = act.ToggleFullScreen },
    { key = 'y',  mods = tab_mode_key, action = act.ActivateCopyMode },
    { key = '-',  mods = tab_mode_key, action = act.SplitVertical { domain = "CurrentPaneDomain" } },
    { key = ';',  mods = tab_mode_key, action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = 'h',  mods = tab_mode_key, action = act.ActivatePaneDirection("Left") },
    { key = 'j',  mods = tab_mode_key, action = act.ActivatePaneDirection("Down") },
    { key = 'k',  mods = tab_mode_key, action = act.ActivatePaneDirection("Up") },
    { key = 'l',  mods = tab_mode_key, action = act.ActivatePaneDirection("Right") },
    { key = 'c',  mods = tab_mode_key, action = act.CloseCurrentPane { confirm = true } },
    { key = 'f',  mods = tab_mode_key, action = act.TogglePaneZoomState },
    {
        key = 'r',
        mods = tab_mode_key,
        action = act.ActivateKeyTable {
            name = 'resize_pane',
            one_shot = false,
        },
    },
    { key = '[', mods = tab_mode_key, action = act.ActivateTabRelative(-1) },
    { key = ']', mods = tab_mode_key, action = act.ActivateTabRelative(1) },
    { key = '{', mods = tab_mode_key, action = act.MoveTabRelative(-1) },
    { key = '}', mods = tab_mode_key, action = act.MoveTabRelative(1) },
}

for i = 1, 9 do
    -- ALT + number to activate that tab
    table.insert(config.keys, {
        key = tostring(i),
        mods = tab_mode_key,
        action = act.ActivateTab(i - 1),
    })
end

config.key_tables = {
    resize_pane = {
        { key = 'LeftArrow',  action = act.AdjustPaneSize { 'Left', 1 } },
        { key = 'h',          action = act.AdjustPaneSize { 'Left', 1 } },

        { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 1 } },
        { key = 'l',          action = act.AdjustPaneSize { 'Right', 1 } },

        { key = 'UpArrow',    action = act.AdjustPaneSize { 'Up', 1 } },
        { key = 'k',          action = act.AdjustPaneSize { 'Up', 1 } },

        { key = 'DownArrow',  action = act.AdjustPaneSize { 'Down', 1 } },
        { key = 'j',          action = act.AdjustPaneSize { 'Down', 1 } },

        { key = 'r',          mods = tab_mode_key,                       action = 'PopKeyTable' },
    },
}

wezterm.on('update-right-status', function(window, pane)
    -- Each element holds the text for a cell in a "powerline" style << fade
    local cells = {}

    -- Figure out the cwd and host of the current pane.
    -- This will pick up the hostname for the remote host if your
    -- shell is using OSC 7 on the remote host.
    local cwd_uri = pane:get_current_working_dir()
    if cwd_uri then
        local cwd = ''

        if type(cwd_uri) == 'userdata' then
            -- Running on a newer version of wezterm and we have
            -- a URL object here, making this simple!

            cwd = cwd_uri.file_path
            hostname = cwd_uri.host or wezterm.hostname()
        else
            -- an older version of wezterm, 20230712-072601-f4abf8fd or earlier,
            -- which doesn't have the Url object
            cwd_uri = cwd_uri:sub(8)
            local slash = cwd_uri:find '/'
            if slash then
                hostname = cwd_uri:sub(1, slash - 1)
                -- and extract the cwd from the uri, decoding %-encoding
                cwd = cwd_uri:sub(slash):gsub('%%(%x%x)', function(hex)
                    return string.char(tonumber(hex, 16))
                end)
            end
        end

        -- Remove the domain name portion of the hostname
        local dot = hostname:find '[.]'
        if dot then
            hostname = hostname:sub(1, dot - 1)
        end
        if hostname == '' then
            hostname = wezterm.hostname()
        end

        table.insert(cells, cwd)
        table.insert(cells, hostname)
    end

    -- I like my date/time in this style: "Wed Mar 3 08:14"
    local date = wezterm.strftime '%a %b %-d %H:%M'
    table.insert(cells, date)

    -- An entry for each battery (typically 0 or 1 battery)
    for _, b in ipairs(wezterm.battery_info()) do
        table.insert(cells, string.format('%.0f%%', b.state_of_charge * 100))
    end

    -- The powerline < symbol
    local LEFT_ARROW = utf8.char(0xe0b3)
    -- The filled in variant of the < symbol
    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

    -- Color palette for the backgrounds of each cell
    local colors = {
        '#3c1361',
        '#52307c',
        '#663a82',
        '#7c5295',
        '#b491c8',
    }

    -- Foreground color for the text across the fade
    local text_fg = '#c0c0c0'

    -- The elements to be formatted
    local elements = {}
    -- How many cells have been formatted
    local num_cells = 0

    -- Translate a cell into elements
    function push(text, is_last)
        local cell_no = num_cells + 1
        table.insert(elements, { Foreground = { Color = text_fg } })
        table.insert(elements, { Background = { Color = colors[cell_no] } })
        table.insert(elements, { Text = ' ' .. text .. ' ' })
        if not is_last then
            table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
            table.insert(elements, { Text = SOLID_LEFT_ARROW })
        end
        num_cells = num_cells + 1
    end

    while #cells > 0 do
        local cell = table.remove(cells, 1)
        push(cell, #cells == 0)
    end

    window:set_right_status(wezterm.format(elements))
end)

return config
