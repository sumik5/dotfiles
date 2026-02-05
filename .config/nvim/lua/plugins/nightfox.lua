return {
  "EdenEast/nightfox.nvim",
  lazy = false, -- カラースキームは遅延読み込みしない
  priority = 1000, -- 他のプラグインより先に読み込む
  config = function()
    require("nightfox").setup({
      options = {
        compile_path = vim.fn.stdpath("cache") .. "/nightfox", -- コンパイル済みファイルの保存先
        compile_file_suffix = "_compiled", -- コンパイルファイルのサフィックス
        transparent = false, -- 背景の透過設定
        terminal_colors = true, -- ターミナルの色を設定
        dim_inactive = false, -- 非アクティブウィンドウを薄暗くする
        module_default = true, -- デフォルトでプラグインモジュールを有効化
        styles = {
          -- 使用可能なスタイル: "bold", "italic", "underline", "undercurl", "strikethrough"
          -- 複数指定: "bold,italic" のようにカンマ区切り
          -- 無効化: "NONE" または ""
          comments = "italic", -- コメント: イタリックで本文と区別
          conditionals = "italic", -- if/else/switch: イタリックで制御フローを強調
          constants = "bold", -- 定数: 太字で不変値を明示
          functions = "bold", -- 関数名: 太字で呼び出し箇所を目立たせる
          keywords = "bold", -- return/local/function等: 太字で構文を強調
          numbers = "", -- 数値: デフォルト（色のみで区別）
          operators = "", -- 演算子(+/-/=等): デフォルト
          strings = "italic", -- 文字列: イタリックでリテラルを区別
          types = "bold,italic", -- 型名(class/interface等): 太字+イタリックで最も目立たせる
          variables = "", -- 変数名: デフォルト（頻出のため装飾控えめ）
        },
        inverse = {
          match_paren = false, -- 対応する括弧の反転表示
          visual = false, -- ビジュアルモードの反転表示
          search = false, -- 検索結果の反転表示
        },
        colorblind = {
          enable = false, -- 色覚異常モード（必要に応じて有効化）
          simulate_only = false,
          severity = {
            protan = 0, -- 赤色覚異常
            deutan = 0, -- 緑色覚異常
            tritan = 0, -- 青色覚異常
          },
        },
        modules = {
          -- 対応プラグインのハイライトを有効化
          cmp = true,
          diagnostic = {
            enable = true,
            background = true,
          },
          gitsigns = true,
          native_lsp = {
            enable = true,
            background = true,
          },
          neogit = true,
          telescope = true,
          treesitter = true,
          whichkey = true,
        },
      },
      palettes = {},
      specs = {},
      groups = {},
    })

    -- カラースキームを適用（お好みで変更可能）
    -- 利用可能: nightfox, dayfox, dawnfox, duskfox, nordfox, terafox, carbonfox
    vim.cmd("colorscheme nightfox")
  end,
}
