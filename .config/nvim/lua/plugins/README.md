# Neovim プラグイン設定ドキュメント

## 📁 ディレクトリ構造

```
~/.config/nvim/
├── init.lua                  # メイン設定（diagnostic, keymaps, LSP）
├── lua/
│   ├── config/
│   │   └── lazy.lua          # lazy.nvim ブートストラップ
│   └── plugins/              # プラグイン設定ディレクトリ（auto-import）
│       ├── alpha.lua
│       ├── autotag.lua
│       ├── better-whitespace.lua
│       ├── completion.lua
│       ├── copilot.lua
│       ├── csv-tools.lua
│       ├── diffview.lua
│       ├── editorconfig.lua
│       ├── filer.lua
│       ├── finder.lua
│       ├── fzf.lua
│       ├── gitsgns.lua
│       ├── gitui.lua
│       ├── hlchunk.lua
│       ├── jj.lua
│       ├── lazygit.lua
│       ├── lsp_signature.lua
│       ├── lualine.lua
│       ├── markview.lua
│       ├── mason.lua
│       ├── matchup.lua
│       ├── neogit.lua
│       ├── nightfox.lua
│       ├── schema.lua
│       ├── scrollbar.lua
│       ├── treesitter.lua
│       ├── undo-grow.lua
│       ├── wakatime.lua
│       └── yanky.lua
```

## 🎯 設定の特徴

- **プラグインマネージャー**: lazy.nvim（`lua/plugins/` auto-import、起動時sync）
- **カラースキーム**: nightfox（priority=1000で最優先ロード）
- **Leader**: `<Space>`
- **Local Leader**: `\`
- **クリップボード**: unnamedplus（システムクリップボード統合）
- **Diagnostic**: virtual_text（source名+code付き）、カスタムsignsアイコン
- **LSP**: Mason経由のautomatic_enable、lua_lsはvim global設定済み
- **Treesitter**: 全FileTypeでpcall(vim.treesitter.start)
- **VCS**: Jujutsu (jj) メイン、Git互換ツール併用（gitsigns/neogit/lazygit/gitui）

## 📦 全プラグイン一覧（カテゴリ別）

### 🎨 UI / 見た目

| プラグイン | ファイル | 説明 |
|-----------|---------|------|
| `EdenEast/nightfox.nvim` | nightfox.lua | カラースキーム（nightfox）、priority=1000、スタイル設定あり（italic comments, bold functions等） |
| `xiyaowong/transparent.nvim` | schema.lua | 背景透過 |
| `neanias/everforest-nvim` | schema.lua | everforestカラースキーム（代替） |
| `goolord/alpha-nvim` | alpha.lua | ダッシュボード（起動画面）、NEOVIMアスキーアート、Telescopeショートカットボタン |
| `nvim-lualine/lualine.nvim` | lualine.lua | ステータスライン、カスタムテーマ（c/xセクションのblue背景 #3d59a1） |
| `shellRaining/hlchunk.nvim` | hlchunk.lua | インデントガイド、chunk/indent/line_num/blank全有効 |
| `petertriho/nvim-scrollbar` | scrollbar.lua | スクロールバー、cursor/diagnostic/gitsigns連携、nightfox配色 |

### 🔍 検索 / ファジーファインダー

| プラグイン | ファイル | 説明 |
|-----------|---------|------|
| `nvim-telescope/telescope.nvim` | finder.lua | ファジーファインダー（plenary依存） |
| `ibhagwan/fzf-lua` | fzf.lua | fzfベースのファインダー、mise経由のfzf_bin固定、markdown内@でファイルパス挿入機能 |

### 📝 エディタ拡張

| プラグイン | ファイル | 説明 |
|-----------|---------|------|
| `hrsh7th/nvim-cmp` | completion.lua | 自動補完（LSP/buffer/path/cmdline）、関連ソース: cmp-nvim-lsp, cmp-buffer, cmp-path, cmp-cmdline |
| `github/copilot.vim` | copilot.lua | GitHub Copilot、lazy=false（常時起動） |
| `ray-x/lsp_signature.nvim` | lsp_signature.lua | 関数シグネチャ表示（InsertEnter時ロード） |
| `OXY2DEV/markview.nvim` | markview.lua | Markdownプレビュー（blink.cmp依存）、lazy=false |
| `windwp/nvim-ts-autotag` | autotag.lua | HTML/JSX自動タグ閉じ・リネーム（treesitter依存） |
| `andymass/vim-matchup` | matchup.lua | マッチペア強化（%ジャンプ、i%/a%テキストオブジェクト、ds%/cs%操作、treesitter統合） |
| `ntpeters/vim-better-whitespace` | better-whitespace.lua | 末尾空白ハイライト・自動削除（保存時） |
| `gpanders/editorconfig.nvim` | editorconfig.lua | .editorconfigの自動適用 |
| `Decodetalkers/csv-tools.lua` | csv-tools.lua | CSV表示支援（ヘッダー固定表示、カラムハイライト） |
| `y3owk1n/undo-glow.nvim` | undo-grow.lua | undo/redo/pasteのハイライトアニメーション（yanky, substitute, flash依存） |
| `gbprod/yanky.nvim` | yanky.lua | ヤンク履歴管理、snacks.nvimのPickerでヤンク履歴からペースト |

### 🗂️ ファイラー

| プラグイン | ファイル | 説明 |
|-----------|---------|------|
| `nvim-tree/nvim-tree.lua` | filer.lua | ファイルツリー |

### 🌳 シンタックス / パーサー

| プラグイン | ファイル | 説明 |
|-----------|---------|------|
| `nvim-treesitter/nvim-treesitter` | treesitter.lua | Treesitter（main branch）、TSUpdate自動実行 |
| `nvim-treesitter/nvim-treesitter-textobjects` | treesitter.lua | Treesitterベースのテキストオブジェクト |

### 🔧 LSP / 開発ツール

| プラグイン | ファイル | 説明 |
|-----------|---------|------|
| `neovim/nvim-lspconfig` | mason.lua | LSP設定 |
| `williamboman/mason.nvim` | mason.lua | LSPサーバー管理 |
| `williamboman/mason-lspconfig.nvim` | mason.lua | Mason-LSP連携（automatic_enable=true） |

### 🥋 バージョン管理（Jujutsu）

| プラグイン | ファイル | 説明 |
|-----------|---------|------|
| `nicolasgb/jj.nvim` | jj.lua | Jujutsu VCS統合（status/log/describe/new/edit/squash/rebase/bookmark/push/fetch/annotate/PR）、diffviewバックエンド、snacks.nvim picker |

### 🔀 バージョン管理（Git互換ツール）

| プラグイン | ファイル | 説明 |
|-----------|---------|------|
| `lewis6991/gitsigns.nvim` | gitsgns.lua | Git差分サイン（行横の+/-表示） |
| `NeogitOrg/neogit` | neogit.lua | Git操作UI（lazy、Neogitコマンドで起動） |
| `sindrets/diffview.nvim` | diffview.lua | Diff閲覧（jj.nvimのバックエンドとしても使用） |
| `kdheepak/lazygit.nvim` | lazygit.lua | LazyGit統合 |
| `akinsho/toggleterm.nvim` | gitui.lua | フローティングターミナル（gitui用） |

### ⏱️ その他

| プラグイン | ファイル | 説明 |
|-----------|---------|------|
| `wakatime/vim-wakatime` | wakatime.lua | コーディング時間追跡 |
| `folke/snacks.nvim` | （yanky.lua, jj.lua の依存） | Pickerなどの汎用ユーティリティ |
| `nvim-lua/plenary.nvim` | （複数の依存） | Lua汎用ライブラリ |
| `nvim-tree/nvim-web-devicons` | （複数の依存） | ファイルアイコン |

## ⌨️ 全キーマップ一覧

### グローバルキーマップ（init.lua定義）

**Leader**: `<Space>`

| キー | 操作 | 定義元 |
|------|------|--------|
| `<leader>ff` | Telescope find files | init.lua |
| `<leader>fg` | Telescope live grep | init.lua |
| `<leader>fb` | Telescope buffers | init.lua |
| `<leader>fh` | Telescope help tags | init.lua |
| `u` | Undo（ハイライト付き） | init.lua (undo-glow) |
| `U` | Redo（ハイライト付き） | init.lua (undo-glow) |
| `p` | Paste below（ハイライト付き、末尾移動） | init.lua (undo-glow) |
| `P` | Paste above（ハイライト付き、末尾移動） | init.lua (undo-glow) |

### プラグイン別キーマップ

#### 🥋 jj.nvim（`<leader>j` プレフィックス）

| キー | 操作 |
|------|------|
| `<leader>jj` | jj status |
| `<leader>jl` | jj log |
| `<leader>jL` | jj log（全change） |
| `<leader>jd` | jj describe |
| `<leader>jn` | jj new |
| `<leader>je` | jj edit |
| `<leader>js` | jj squash |
| `<leader>ju` | jj undo |
| `<leader>jr` | jj rebase |
| `<leader>ja` | jj abandon |
| `<leader>jf` | jj fetch |
| `<leader>jp` | jj push |
| `<leader>jo` | jj open PR |
| `<leader>jO` | jj open PR（bookmark選択） |
| `<leader>jbc` | jj bookmark create |
| `<leader>jbd` | jj bookmark delete |
| `<leader>jbm` | jj bookmark move |
| `<leader>jD` | jj diff current buffer（vertical） |
| `<leader>jps` | jj picker status |
| `<leader>jph` | jj picker file history |
| `<leader>jga` | jj annotate file |
| `<leader>jgA` | jj annotate line |

#### 🥋 jj.nvim Logバッファ内キーマップ

| キー | 操作 |
|------|------|
| `<CR>` | changeをedit |
| `<S-CR>` | changeをedit（immutable無視） |
| `d` | describe |
| `<S-d>` | diff |
| `e` | edit |
| `n` | new（分岐） |
| `<C-n>` | new（after） |
| `<S-n>` | new（after、immutable無視） |
| `<S-u>` | undo |
| `<S-r>` | redo |
| `a` | abandon |
| `b` | bookmark作成/移動 |
| `f` | fetch |
| `p` | push（カーソル行のbookmark） |
| `<S-p>` | push（picker） |
| `o` | open PR |
| `<S-o>` | open PR（bookmark選択） |
| `r` | rebase mode |
| `s` | squash mode |
| `<S-s>` | quick squash（parent） |
| `<S-k>` | summary tooltip |
| `q` / `<Esc>` | 閉じる |

#### 🥋 jj.nvim Statusバッファ内キーマップ

| キー | 操作 |
|------|------|
| `<CR>` | ファイルを開く |
| `<S-x>` | ファイルをrestore |
| `q` / `<Esc>` | 閉じる |

#### 🗂️ ファイラー

| キー | 操作 |
|------|------|
| `<leader>ee` | NvimTree トグル |
| `<leader>ef` | NvimTree フォーカス |

#### 🔀 Git

| キー | 操作 |
|------|------|
| `<leader>gg` | Neogit UI |
| `<leader>gu` | GitUI（フローティング） |
| `<leader>lg` | LazyGit |
| `<leader>df` | DiffviewOpen |

#### 📋 ヤンク

| キー | 操作 |
|------|------|
| `<leader>p` | Yank History（snacks picker） |

#### 🧹 空白

| キー | 操作 |
|------|------|
| `<leader>ws{motion}` | 指定範囲の空白削除 |

#### 📊 CSV（CSVファイル内のみ）

| キー | 操作 |
|------|------|
| `<leader>ct` | CSVヘッダーウィンドウを開く |
| `<leader>cc` | CSVヘッダーウィンドウを閉じる |

#### 🔗 matchup（ビルトイン拡張）

| キー | 操作 |
|------|------|
| `%` | マッチペアへジャンプ |
| `g%` | 逆方向ジャンプ |
| `[%` / `]%` | 外側の開き/閉じへ移動 |
| `z%` | ブロック内部へ移動 |
| `i%` / `a%` | ブロック内部/全体テキストオブジェクト |
| `ds%` | 周囲マッチペア削除 |
| `cs%` | 周囲マッチペア変更 |

#### 🎨 Alpha ダッシュボード

| キー | 操作 |
|------|------|
| `f` | Find file（Telescope） |
| `r` | Recent files |
| `g` | Live grep |
| `c` | Configuration（init.lua） |
| `p` | Plugins（Lazy） |
| `q` | Quit |

## 📝 コマンド一覧

| コマンド | プラグイン | 説明 |
|---------|-----------|------|
| `:J {subcommand}` | jj.nvim | jjコマンド実行 |
| `:Jdiff [rev]` | jj.nvim | 縦分割diff |
| `:Jvdiff [rev]` | jj.nvim | 縦分割diff |
| `:Jhdiff [rev]` | jj.nvim | 横分割diff |
| `:Neogit` | neogit | Git操作UI |
| `:LazyGit` | lazygit.nvim | LazyGit起動 |
| `:DiffviewOpen` | diffview.nvim | Diff閲覧 |
| `:NvimTreeToggle` | nvim-tree | ファイルツリー切替 |
| `:NvimTreeFocus` | nvim-tree | ファイルツリーにフォーカス |
| `:StripWhitespace` | better-whitespace | 末尾空白一括削除 |
| `:WakaTimeToday` | wakatime | 本日のコーディング時間 |
| `:TopWindow` | csv-tools | CSVヘッダー表示 |
| `:Lazy` | lazy.nvim | プラグインマネージャー |
| `:Mason` | mason.nvim | LSPサーバー管理 |
| `:TSUpdate` | treesitter | パーサー更新 |

## 🔧 Diagnostic設定

### Signs（アイコン）

| Severity | アイコン |
|----------|---------|
| ERROR | `` |
| WARN | `` |
| INFO | `` |
| HINT | `` |

### Virtual Text

診断メッセージには以下の形式で表示されます：

```
<message> (<source>: <code>)
```

例：
```
Undefined variable 'foo' (lua_ls: undefined-global)
```

## 🎨 カラースキーム設定

### nightfox.nvim（メイン）

- **Priority**: 1000（最優先ロード）
- **スタイル設定**:
  - コメント: italic
  - 関数: bold
  - その他のカスタムスタイル対応

### その他のスキーム

- **transparent.nvim**: 背景透過サポート
- **everforest.nvim**: 代替カラースキーム（オプション）

## 🚀 起動時の動作

1. **lazy.nvim ブートストラップ**: 未インストールの場合は自動クローン
2. **プラグイン自動インポート**: `lua/plugins/` ディレクトリ内の全.luaファイル
3. **起動時Sync**: VimEnter時に`require("lazy").sync({ show = false })`を自動実行
4. **Treesitter自動起動**: FileTypeイベントで`vim.treesitter.start()`を自動実行

## 📚 主な依存関係

### 共通依存

- `nvim-lua/plenary.nvim`: Lua汎用ライブラリ
- `nvim-tree/nvim-web-devicons`: ファイルアイコン
- `folke/snacks.nvim`: Picker等のユーティリティ

### プラグイン別依存

- **markview.nvim** → blink.cmp
- **autotag** → treesitter
- **matchup** → treesitter
- **undo-glow** → yanky, substitute, flash
- **jj.nvim** → diffview, snacks.nvim
- **scrollbar** → gitsigns

## 🔗 関連リソース

- [lazy.nvim Documentation](https://github.com/folke/lazy.nvim)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [Mason.nvim](https://github.com/williamboman/mason.nvim)
- [jj.nvim](https://github.com/nicolasgb/jj.nvim)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
