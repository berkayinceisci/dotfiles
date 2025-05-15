local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action
local super_key

local function select_random_wallpaper()
	local wallpapers = {}
	local wallpapers_glob = wezterm.home_dir .. "/Wallpapers/**"
	for _, v in ipairs(wezterm.glob(wallpapers_glob)) do
		table.insert(wallpapers, v)
	end

	if next(wallpapers) == nil then
		-- empty
	else
		config.window_background_image = wallpapers[math.random(1, #wallpapers)]
		config.window_background_image_hsb = {
			brightness = 0.2,
			hue = 1.0,
			saturation = 1.0,
		}
	end
end

if wezterm.target_triple == "aarch64-apple-darwin" then
	super_key = "ALT" -- option key
	config.font_size = 18.0
	config.macos_window_background_blur = 30
	config.window_background_opacity = 0.7
else
	super_key = "SUPER" -- windows key
	select_random_wallpaper()
end

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

config.font = wezterm.font_with_fallback({
	"JetbrainsMono Nerd Font",
	"Hack Nerd Font Mono",
})

config.color_scheme = "Catppuccin Mocha (Gogh)"
config.window_decorations = "RESIZE"

config.window_padding = {
	left = 10,
	right = 10,
	top = 10,
	bottom = 0,
}

config.disable_default_key_bindings = true

config.keys = {
	{ key = "\r", mods = super_key, action = act.ToggleFullScreen },
	{ key = "r", mods = super_key, action = act.ReloadConfiguration },
}

return config
