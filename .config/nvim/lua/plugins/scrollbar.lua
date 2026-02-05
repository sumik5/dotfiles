return {
  "petertriho/nvim-scrollbar",
  lazy = false, -- 遅延読み込みしない（確実に表示）
  dependencies = {
    "lewis6991/gitsigns.nvim",
  },
  config = function()
    require("scrollbar").setup({
      show = true,
      show_in_active_only = false,
      set_highlights = true,
      hide_if_all_visible = false, -- 全体が見えていても常に表示
      handle = {
        text = "█", -- 太いブロック文字でハンドルを目立たせる
        blend = 0, -- 透過なしで鮮明に
        hide_if_all_visible = false,
        color = "#565f89", -- ハンドルの色
      },
      marks = {
        Cursor = { text = "█", priority = 0, color = "#7aa2f7" }, -- カーソル位置（青）
        Search = { text = { "█", "█" }, priority = 1, color = "#e0af68" }, -- 検索（黄）
        Error = { text = { "█", "█" }, priority = 2, color = "#f7768e" }, -- エラー（赤）
        Warn = { text = { "█", "█" }, priority = 3, color = "#ff9e64" }, -- 警告（オレンジ）
        Info = { text = { "█", "█" }, priority = 4, color = "#7dcfff" }, -- 情報（水色）
        Hint = { text = { "█", "█" }, priority = 5, color = "#9ece6a" }, -- ヒント（緑）
        Misc = { text = { "█", "█" }, priority = 6, color = "#bb9af7" }, -- その他（紫）
        GitAdd = { text = "▎", priority = 7, color = "#9ece6a" }, -- Git追加（緑）
        GitChange = { text = "▎", priority = 7, color = "#e0af68" }, -- Git変更（黄）
        GitDelete = { text = "▁", priority = 7, color = "#f7768e" }, -- Git削除（赤）
      },
      excluded_buftypes = {
        "terminal",
      },
      excluded_filetypes = {
        "alpha",
        "TelescopePrompt",
        "lazy",
        "mason",
      },
      handlers = {
        cursor = true,
        diagnostic = true,
        gitsigns = true,
        handle = true,
        search = false,
        ale = false,
      },
    })

    -- gitsigns連携
    require("scrollbar.handlers.gitsigns").setup()
  end,
}
