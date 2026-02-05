return {
  "wakatime/vim-wakatime",
  lazy = false, -- 常に読み込む（時間追跡のため）
  -- 初回起動時に :WakaTimeApiKey でAPIキーを設定
  -- APIキーは https://wakatime.com/settings/api-key で取得
  --
  -- 便利なコマンド:
  --   :WakaTimeApiKey    - APIキーの設定・変更
  --   :WakaTimeToday     - 本日のコーディング時間を表示
  --   :WakaTimeDebugEnable/Disable - デバッグモード切替
}
