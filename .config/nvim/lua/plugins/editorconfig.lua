return {
  "gpanders/editorconfig.nvim",
  event = { "BufReadPre", "BufNewFile" }, -- ファイル読み込み時に有効化
  --
  -- EditorConfig とは:
  --   プロジェクトごとのコーディングスタイルを統一するための設定ファイル
  --   .editorconfig ファイルでインデント、改行コード、文字コード等を指定
  --
  -- 機能:
  --   .editorconfig の設定を自動的にNvimに適用
  --   - indent_style: tab/space
  --   - indent_size: インデント幅
  --   - tab_width: タブ幅
  --   - end_of_line: 改行コード (lf/crlf/cr)
  --   - charset: 文字コード (utf-8等)
  --   - trim_trailing_whitespace: 末尾空白の削除
  --   - insert_final_newline: 最終行に改行を追加
  --
  -- 注意:
  --   Nvim 0.9+ には組み込みのEditorConfigサポートがあるが、
  --   このプラグインはより高度な機能と互換性を提供
  --
}
