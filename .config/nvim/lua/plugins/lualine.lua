return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- autoテーマを取得してc/xセクションの背景をブルーに統一
    local custom_theme = require("lualine.themes.auto")
    local blue_bg = { fg = "#ffffff", bg = "#3d59a1" }
    for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "inactive" }) do
      if custom_theme[mode] then
        custom_theme[mode].c = blue_bg
      end
    end

    require("lualine").setup({
      options = {
        theme = custom_theme, -- カスタムテーマ（c/xセクションをブルー背景に）
        section_separators = "", -- セクション区切り文字
        component_separators = "", -- コンポーネント区切り文字
        icons_enabled = true, -- アイコン表示（devicons推奨）
      },
      sections = {
        lualine_a = { "mode" }, -- 左端: モード表示
        lualine_b = { "branch", "diff" }, -- 左: Gitブランチ、変更差分
        lualine_c = { { "filename", path = 2 } }, -- 中央: ファイル名
        lualine_x = { "encoding", "fileformat", "filetype" }, -- 右: 文字コードなど
        lualine_y = { "progress" }, -- 右: 進行バー
        lualine_z = { "location" }, -- 右端: 行・列番号
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { "filename", path = 2 } },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = {},
    })
  end,
}
