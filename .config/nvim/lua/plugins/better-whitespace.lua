return {
  "ntpeters/vim-better-whitespace",
  event = { "BufReadPost", "BufNewFile" }, -- ファイル読み込み時に有効化
  config = function()
    -- ハイライト色の設定（赤系で目立たせる）
    vim.g.better_whitespace_guicolor = "#f7768e" -- GUI用（赤）
    vim.g.better_whitespace_ctermcolor = "red" -- ターミナル用

    -- 基本設定
    vim.g.better_whitespace_enabled = 1 -- ハイライト有効
    vim.g.strip_whitespace_on_save = 1 -- 保存時に自動削除
    vim.g.strip_whitespace_confirm = 0 -- 確認なしで削除
    vim.g.strip_only_modified_lines = 0 -- 変更行だけでなく全行を対象
    vim.g.strip_max_file_size = 5000 -- 5000行以上のファイルは自動削除しない

    -- 現在行の空白は除外（編集中は気にならないように）
    vim.g.current_line_whitespace_disabled_soft = 1

    -- 空白のみの行もハイライト対象にする
    vim.g.better_whitespace_skip_empty_lines = 0

    -- タブの前にあるスペースもハイライト
    vim.g.show_spaces_that_precede_tabs = 1

    -- ハイライト除外するファイルタイプ
    vim.g.better_whitespace_filetypes_blacklist = {
      "diff",
      "git",
      "gitcommit",
      "unite",
      "qf",
      "help",
      "fugitive",
      "toggleterm",
      "TelescopePrompt",
      "alpha",
      "lazy",
      "mason",
    }

    -- キーマップ: <Leader>ws で空白削除オペレータ
    vim.g.better_whitespace_operator = "<Leader>ws"
  end,
  --
  -- コマンド:
  --   :StripWhitespace        - 末尾空白を一括削除
  --   :EnableWhitespace       - ハイライト有効化
  --   :DisableWhitespace      - ハイライト無効化
  --   :ToggleWhitespace       - ハイライト切り替え
  --   :NextTrailingWhitespace - 次の空白へジャンプ
  --   :PrevTrailingWhitespace - 前の空白へジャンプ
  --
  -- オペレータ:
  --   <Leader>ws{motion} - 指定範囲の空白を削除
  --   例: <Leader>wsip   - 段落内の空白を削除
}
