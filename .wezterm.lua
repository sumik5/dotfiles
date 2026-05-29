local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.automatically_reload_config = true
config.font_size = 21.0
config.font = wezterm.font("Moralerspace Argon HW", {weight="Regular", stretch="Normal", style="Normal"})
config.font = wezterm.font_with_fallback({
  { family = "Moralerspace Argon HW" }
})
config.use_ime = true
config.window_background_opacity = 0.75
config.macos_window_background_blur = 10
config.inactive_pane_hsb = {
  saturation = 0.25,
  brightness = 0.25,
}
-- config.window_decorations = "RESIZE"
config.color_scheme = "iTerm2 Tango Dark"

-- Pane
config.keys = {
  {
    key = "|",
    mods = "CMD|SHIFT",
    action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" },
  },
  {
    key = "-",
    mods = "CMD|SHIFT",
    action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" },
  },
  {
    key = "o",
    mods = "CMD",
    action = wezterm.action.ActivatePaneDirection "Next",
  },
  {
    key = "n",
    mods = "CMD|SHIFT",
    action = wezterm.action.PromptInputLine {
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        if line ~= nil then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  {
    key = "o",
    mods = "CMD|SHIFT",
    action = wezterm.action.ActivateTabRelative(1),
  },
}

----------------------------------------------------
-- Tab
----------------------------------------------------
-- タイトルバーを非表示
config.window_decorations = "RESIZE"
-- タブバーの表示
config.show_tabs_in_tab_bar = true
-- タブが一つの時は非表示
config.hide_tab_bar_if_only_one_tab = true
-- falseにするとタブバーの透過が効かなくなる
-- config.use_fancy_tab_bar = false

-- タブバーの透過
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
  font = wezterm.font { family = "Moralerspace Argon HW", weight = "Regular" },
  font_size = 18.0,
}

-- タブバーを背景色に合わせる
config.window_background_gradient = {
  colors = { "#000000" },
}

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false
-- nightlyのみ使用可能
-- タブの閉じるボタンを非表示
config.show_tab_index_in_tab_bar = true

-- タブ同士の境界線を非表示
config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

-- タブの形をカスタマイズ
-- タブの左側の装飾
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
-- タブの右側の装飾
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"
  local edge_background = "none"
  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#FFFFFF"
  end
  local edge_foreground = background
  local raw_title = tab.tab_title
  if raw_title == nil or #raw_title == 0 then
    raw_title = tab.active_pane.title
  end
  local title = "   " .. wezterm.truncate_right(raw_title, max_width - 1) .. "   "
  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

-- 最初から最大化で起動
local mux = wezterm.mux
wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window{}
  window:gui_window():maximize()
end)

-- 最初からフルスクリーンで起動
-- local mux = wezterm.mux
-- wezterm.on("gui-startup", function(cmd)
--     local tab, pane, window = mux.spawn_window(cmd or {})
--     window:gui_window():toggle_fullscreen()
-- end)

-- backgound
-- config.background = {
--   {
--     source = {
--       File = '/demo/sample/wall.jpg'
--     },
--     hsb =  { brightness = 0.06 },
--     opacity = 0.9,
--     attachment = { Parallax = 0.5 },
--     horizontal_offset = 0,
--     vertical_offset = 0
--   }
-- }

return config
