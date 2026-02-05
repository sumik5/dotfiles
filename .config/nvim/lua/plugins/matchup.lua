return {
  "andymass/vim-matchup",
  event = "BufReadPost", -- ファイル読み込み時に有効化
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    -- Treesitter統合を有効化
    vim.g.matchup_matchparen_offscreen = { method = "popup" } -- 画面外マッチをポップアップ表示
    vim.g.matchup_matchparen_deferred = 1 -- 遅延ハイライト（パフォーマンス向上）
    vim.g.matchup_matchparen_hi_surround_always = 1 -- 常に周囲をハイライト
    vim.g.matchup_surround_enabled = 1 -- ds%/cs% で周囲削除・変更を有効化
    vim.g.matchup_transmute_enabled = 1 -- マッチペア変換を有効化
  end,
  --
  -- モーション:
  --   %   - マッチする単語へジャンプ（if→endif, {→} など）
  --   g%  - 逆方向にジャンプ
  --   [%  - 外側の開き単語へ移動
  --   ]%  - 外側の閉じ単語へ移動
  --   z%  - 内側のブロック内へ移動
  --
  -- テキストオブジェクト:
  --   i%  - ブロック内部を選択
  --   a%  - ブロック全体を選択
  --
  -- 周囲操作（surround_enabled=1時）:
  --   ds% - 周囲のマッチペアを削除
  --   cs% - 周囲のマッチペアを変更
}
