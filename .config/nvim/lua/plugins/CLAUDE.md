# CLAUDE.md - Neovim プラグイン設定ガイド

このディレクトリは Neovim の **lazy.nvim** プラグイン設定ディレクトリです。
`lua/plugins/` 配下の全 `.lua` ファイルが自動的にインポートされます。

## プラグイン追加時の必須ルール

### 1. README.md を必ず更新する

プラグインの追加・削除・キーマップ変更時は、同ディレクトリの `README.md` を必ず更新すること。

更新対象セクション:
- **全プラグイン一覧**: 該当カテゴリの表に追加
- **全キーマップ一覧**: 新しいキーマップがあれば追加
- **コマンド一覧**: 新しいコマンドがあれば追加
- **ディレクトリ構造**: ファイルを追加した場合
- **依存関係**: 新しい共通依存があれば追加

### 2. ファイル命名規則

- 1プラグイン = 1ファイル（原則）
- ファイル名はプラグインの機能を端的に表す英語名（例: `filer.lua`, `completion.lua`）
- 関連プラグインをまとめる場合はグループ名（例: `treesitter.lua` に textobjects も含む）

### 3. Leaderキー プレフィックス割り当て（衝突回避必須）

以下のプレフィックスは使用済み。新プラグインは空きプレフィックスを使うか、既存グループに追加する。

| プレフィックス | 用途 | 定義元 |
|---------------|------|--------|
| `<leader>f` | Telescope（find files, grep, buffers, help） | init.lua |
| `<leader>e` | ファイラー（NvimTree toggle/focus） | filer.lua |
| `<leader>j` | Jujutsu VCS（status, log, describe, new, edit 等） | jj.lua |
| `<leader>jb` | Jujutsu bookmark（create, delete, move） | jj.lua |
| `<leader>jp` | Jujutsu picker（status, file history） | jj.lua |
| `<leader>jg` | Jujutsu annotate（file, line） | jj.lua |
| `<leader>g` | Git UI（gg=Neogit, gu=GitUI） | neogit.lua, gitui.lua |
| `<leader>lg` | LazyGit | lazygit.lua |
| `<leader>df` | DiffviewOpen | diffview.lua |
| `<leader>ws` | 空白削除オペレータ | better-whitespace.lua |
| `<leader>c` | CSV操作（CSVファイル内のみ） | csv-tools.lua |
| `<leader>p` | Yank History | yanky.lua |

**空きプレフィックス例**: `<leader>t`, `<leader>s`, `<leader>m`, `<leader>n`, `<leader>h`, `<leader>r`, `<leader>x`, `<leader>z`

## 設定パターン（このプロジェクトの慣例）

### 基本形: lazy.nvim spec

```lua
-- パターン1: 最小構成（設定不要なプラグイン）
return {
  "author/plugin.nvim",
}

-- パターン2: lazy-load + keys（推奨）
return {
  "author/plugin.nvim",
  lazy = true,
  dependencies = { "dep/plugin.nvim" },
  cmd = { "PluginCommand" },
  keys = {
    { "<leader>xx", function() require("plugin").action() end, desc = "Plugin: action" },
  },
  config = function()
    require("plugin").setup({
      -- 設定
    })
  end,
}

-- パターン3: イベント駆動（エディタ拡張向け）
return {
  "author/plugin.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("plugin").setup({})
  end,
}
```

### 遅延読み込み戦略

| 方法 | 用途 | 例 |
|------|------|-----|
| `lazy = true` + `keys` | キーマップで起動するプラグイン | jj.lua, filer.lua |
| `lazy = true` + `cmd` | コマンドで起動するプラグイン | lazygit.lua, neogit.lua |
| `event = { "BufReadPre", "BufNewFile" }` | ファイル読み込みで起動 | autotag.lua, matchup.lua |
| `event = "InsertEnter"` | 挿入モードで起動 | completion.lua, lsp_signature.lua |
| `ft = { "csv" }` | 特定のファイルタイプのみ | csv-tools.lua |
| `lazy = false` | 常時起動（カラースキーム等） | nightfox.lua, copilot.lua |
| `lazy = false` + `priority = 1000` | 最優先ロード（カラースキームのみ） | nightfox.lua |

### キーマップの desc 規則

```lua
-- フォーマット: "プラグイン名: 操作"
{ "<leader>jl", ..., desc = "jj: log" }
{ "<leader>ee", ..., desc = "NvimTreeToggle" }
```

### コメント言語

- コード内コメントは**日本語**で記述
- 設定の意図・理由を簡潔に説明する
- 例: `-- Diffバックエンドにdiffviewを使用`

## 環境情報

- **プラグインマネージャー**: lazy.nvim（auto-import）
- **Leaderキー**: `<Space>`
- **カラースキーム**: nightfox
- **VCS**: Jujutsu (jj)（Git互換ツールも併用）
- **Treesitter**: 全FileTypeで自動起動
- **LSP**: Mason + mason-lspconfig（automatic_enable）
- **共通依存**: plenary.nvim, nvim-web-devicons, snacks.nvim

## プラグイン追加チェックリスト

新しいプラグインを追加する際は以下を確認:

- [ ] Leaderキーの衝突がないか（上の割り当て表を確認）
- [ ] 遅延読み込みを適切に設定したか（不要な常時ロードを避ける）
- [ ] dependencies に必要なプラグインを記載したか
- [ ] keys の desc を設定したか
- [ ] コメントを日本語で記載したか
- [ ] `README.md` を更新したか（プラグイン一覧、キーマップ、コマンド）
