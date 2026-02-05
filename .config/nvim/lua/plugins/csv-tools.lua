return {
  "Decodetalkers/csv-tools.lua",
  ft = { "csv" }, -- CSVファイルのみで読み込み
  config = function()
    require("csvtools").setup({
      before = 10, -- カーソル前の表示行数
      after = 10, -- カーソル後の表示行数
      clearafter = true, -- バッファ移動後にハイライトをクリア
      showoverflow = true, -- オーバーフロー表示
      titelflow = true, -- タイトル行を独立表示
    })

    -- キーマップ設定（CSVファイル専用）
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "csv",
      callback = function()
        local opts = { buffer = true, silent = true }
        vim.keymap.set("n", "<Leader>ct", "<cmd>TopWindow<cr>", vim.tbl_extend("force", opts, { desc = "Open CSV header window" }))
        vim.keymap.set("n", "<Leader>cc", "<cmd>CloseWindow<cr>", vim.tbl_extend("force", opts, { desc = "Close CSV header window" }))
      end,
    })
  end,
  --
  -- コマンド:
  --   :TopWindow   - CSVカラムヘッダーを表示するウィンドウを開く
  --   :CloseWindow - ヘッダーウィンドウを閉じる
  --
  -- キーマップ (CSVファイル内):
  --   <Leader>ct - ヘッダーウィンドウを開く
  --   <Leader>cc - ヘッダーウィンドウを閉じる
  --
  -- 機能:
  --   - カラムヘッダーを常に表示
  --   - カーソル位置のカラムをハイライト
  --   - データの見やすさを向上
}
