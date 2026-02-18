local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action
local super_key
local alt_key

local function select_random_wallpaper()
	local wallpapers = {}
	local wallpapers_glob = wezterm.home_dir .. "/wallpapers/**"
	for _, v in ipairs(wezterm.glob(wallpapers_glob)) do
		table.insert(wallpapers, v)
	end

	if next(wallpapers) ~= nil then
		config.background = {
			{
				source = {
					File = wallpapers[math.random(1, #wallpapers)],
				},
				hsb = {
					brightness = 0.15,
					hue = 1.0,
					saturation = 1.0,
				},
				vertical_align = "Middle",
				horizontal_align = "Center",
				repeat_x = "NoRepeat",
				repeat_y = "NoRepeat",
				height = "100%",
				width = "Cover",
			},
		}
	end
end

if wezterm.target_triple == "aarch64-apple-darwin" then
	super_key = "ALT" -- option key
	alt_key = "SUPER" -- cmd key
	-- config.macos_window_background_blur = 30
	-- config.window_background_opacity = 0.7
	-- select_random_wallpaper()

	wezterm.on("update-status", function(window, pane)
		local date = wezterm.strftime("%a %b %-d  %H:%M")
		window:set_right_status(wezterm.format({
			{ Text = date .. "  " },
		}))
	end)
else
	super_key = "SUPER" -- windows key
	alt_key = "ALT" -- alt key
	-- select_random_wallpaper()
end

local function get_font_size(screen_height)
	if wezterm.target_triple == "aarch64-apple-darwin" then
		return 18.0
	end

	if screen_height >= 2160 then
		return 16.0 -- 4K
	elseif screen_height >= 1440 then
		return 12.0 -- 1440p
	else
		return 10.0 -- 1080p
	end
end

local function adjust_font_for_display(window)
	local overrides = window:get_config_overrides() or {}
	local screens = wezterm.gui.screens()
	local screen = screens.active
	local new_size = get_font_size(screen.height)

	if overrides.font_size ~= new_size then
		overrides.font_size = new_size
		window:set_config_overrides(overrides)
	end
end

wezterm.on("window-resized", function(window, pane)
	adjust_font_for_display(window)
end)

wezterm.on("window-config-reloaded", function(window, pane)
	adjust_font_for_display(window)
end)

config.font = wezterm.font_with_fallback({
	"JetBrainsMono Nerd Font",
	"Hack Nerd Font Mono",
})

-- config.color_scheme = "Glacier"
-- config.color_scheme = "Google (dark) (terminal.sexy)"
-- config.color_scheme = "Gruvbox Dark (Gogh)"
-- config.color_scheme = "JetBrains Darcula"
-- config.color_scheme = "jubi"
config.color_scheme = "Quiet (Gogh)"

config.window_padding = {
	left = 10,
	right = 10,
	top = 10,
	bottom = 0,
}

config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false

config.enable_kitty_keyboard = false

config.keys = {
	{ key = "\r", mods = super_key, action = act.ToggleFullScreen },
	{ key = "r", mods = super_key, action = act.ReloadConfiguration },
	{ key = "t", mods = alt_key, action = wezterm.action.DisableDefaultAssignment },
	{ key = "t", mods = super_key, action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = alt_key, action = wezterm.action.DisableDefaultAssignment },
	{ key = "n", mods = super_key, action = act.SpawnWindow },
	{ key = "q", mods = super_key, action = act.CloseCurrentTab({ confirm = false }) },
	{ key = "[", mods = super_key, action = act.MoveTabRelative(-1) },
	{ key = "]", mods = super_key, action = act.MoveTabRelative(1) },
	{ key = "h", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "j", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "k", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "l", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "LeftArrow", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "UpArrow", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "DownArrow", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
}

for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = super_key,
		action = act.ActivateTab(i - 1),
	})
end

return config
