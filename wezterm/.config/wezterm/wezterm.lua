local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local hostname = wezterm.hostname()
local act = wezterm.action

config.font = wezterm.font_with_fallback {
    'JetbrainsMono Nerd Font',
    'Hack Nerd Font Mono',
}
if hostname == 'berkays-air' or hostname == 'berkays-air.local' then
    config.font_size = 18.0
else
    config.font_size = 18.0
end

config.color_scheme = 'Catppuccin Mocha (Gogh)'
config.window_decorations = 'RESIZE'
config.use_fancy_tab_bar = false

-- Dim inactive panes
config.inactive_pane_hsb = {
    brightness = 0.4,
    saturation = 0.6
}

if hostname == 'berkays-air' or hostname == 'berkays-air.local' then
    config.macos_window_background_blur = 50
    config.window_background_opacity = 0.5
else
    local wallpapers = {}
    local wallpapers_glob = wezterm.home_dir .. '/Wallpapers/**'
    for _, v in ipairs(wezterm.glob(wallpapers_glob)) do
        table.insert(wallpapers, v)
    end
    config.window_background_image = wallpapers[math.random(1, #wallpapers)]
    config.window_background_image_hsb = {
        -- Darken the background image by reducing it to 1/3rd
        brightness = 0.2,

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
local super_key
if hostname == 'berkays-air' then
    super_key = 'ALT'
else
    super_key = 'SUPER'
end

config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
    { key = '\r', mods = 'ALT',          action = wezterm.action.DisableDefaultAssignment },
    { key = '\r', mods = super_key,      action = act.ToggleFullScreen },
    { key = 'y',  mods = 'LEADER',       action = act.ActivateCopyMode },
    { key = '%',  mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = '"',  mods = 'LEADER|SHIFT', action = act.SplitVertical { domain = "CurrentPaneDomain" } },
    { key = 'h',  mods = 'LEADER',       action = act.ActivatePaneDirection("Left") },
    { key = 'j',  mods = 'LEADER',       action = act.ActivatePaneDirection("Down") },
    { key = 'k',  mods = 'LEADER',       action = act.ActivatePaneDirection("Up") },
    { key = 'l',  mods = 'LEADER',       action = act.ActivatePaneDirection("Right") },
    { key = 'q',  mods = 'LEADER',       action = act.CloseCurrentPane { confirm = true } },
    { key = 'f',  mods = 'LEADER',       action = act.TogglePaneZoomState },
    {
        key = 'r',
        mods = 'LEADER',
        action = act.ActivateKeyTable {
            name = 'resize_pane',
            one_shot = false,
        },
    },
    { key = 'c', mods = 'LEADER',  action = act.SpawnTab 'CurrentPaneDomain' },
    { key = '[', mods = super_key, action = act.ActivateTabRelative(-1) },
    { key = ']', mods = super_key, action = act.ActivateTabRelative(1) },
    { key = '{', mods = super_key, action = act.MoveTabRelative(-1) },
    { key = '}', mods = super_key, action = act.MoveTabRelative(1) },
}

for i = 1, 9 do
    -- LEADER + number to activate that tab
    table.insert(config.keys, {
        key = tostring(i),
        mods = 'LEADER',
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

        { key = 'r',          mods = 'LEADER',                           action = 'PopKeyTable' },
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
