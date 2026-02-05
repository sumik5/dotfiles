return {
  "windwp/nvim-ts-autotag",
  event = { "BufReadPre", "BufNewFile" }, -- ファイル読み込み時に有効化
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("nvim-ts-autotag").setup({
      opts = {
        enable_close = true, -- <div> 入力で </div> を自動追加
        enable_rename = true, -- 開始タグ編集で終了タグも自動リネーム
        enable_close_on_slash = false, -- </ 入力で閉じタグ補完（falseで無効）
      },
      -- ファイルタイプ別のカスタム設定（必要に応じて）
      -- per_filetype = {
      --   ["html"] = {
      --     enable_close = true,
      --   },
      -- },
    })
  end,
  --
  -- 対応ファイルタイプ:
  --   HTML, JSX, TSX, Vue, Svelte, Astro, XML, PHP, Markdown 等
  --
  -- 機能:
  --   <div>| と入力 → <div>|</div> に自動補完
  --   <div> を <span> に変更 → </div> も </span> に自動リネーム
  --
  -- 必要なTreesitterパーサー:
  --   :TSInstall html javascript typescript tsx
}
