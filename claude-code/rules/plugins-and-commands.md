# プラグイン・MCP・コマンド

## MCP優先順位

1. **serena** — コード分析・編集・メモリ（プロジェクト作業前に必ず初期化）
2. **next-devtools** — Next.js専用（診断・アップグレード・Cache Components）
3. **context7** — ライブラリドキュメント検索
4. **chrome-devtools** / **puppeteer** — ブラウザ診断・自動化（→ web操作は下記「ブラウザ操作・web自動化の優先順位」を優先）
5. **shadcn** / **figma** / **mcp-pandoc** / **sequentialthinking** — 用途別

## ブラウザ操作・web自動化の優先順位

アプリのweb操作・ブラウザ自動化は以下の優先順位で選ぶ。

1. **`web:automating-browser`（agent-browser CLI）** — 🔴 第一選択。Vercel Labs 製の Rust ネイティブ・CDP 直結の高速 CLI（デーモンに Node/Playwright 不要）。スクレイピング・UI操作フロー・認証永続化（state / auth vault）・フォーム送信・データ抽出・`read`（Chrome 起動なしで URL→markdown）・`chat`（自然言語操作）・`batch`（一括実行）・`mcp`（MCP サーバー化）。未導入なら同スキルの `scripts/install.sh` で自動導入（`agent-browser install` が Chrome for Testing を取得）。
2. **`web:testing-e2e-with-playwright`** — E2E テストスイートの設計・実装（`@playwright/test`・`playwright.config.*` 検出時）。
3. **chrome-devtools MCP** — パフォーマンス計測・Lighthouse・詳細トレース等の診断補完。
4. **claude-in-chrome** — ユーザーの既存 Chrome タブ／ログイン済みセッションの操作。
5. **puppeteer MCP** — 上記で代替できない軽量スクリプト操作のフォールバック。

## herdr 環境での作業（ターミナル多重化）

`HERDR_ENV=1` が設定されたセッション（herdr = terminal-native agent multiplexer 管理下のペイン）で作業する場合は、🔴 **`operating-herdr` スキルを必ずロードする**。herdr CLI（`herdr` バイナリ・ローカル unix socket 経由）で以下を制御する。

1. **workspace / tab / pane 制御** — workspace（プロジェクト文脈）・tab（サブ文脈）・pane（端末分割）の list / create / focus / rename / close・`pane split`。
2. **別ペインの観測** — `pane read`（`--source visible`/`recent`/`recent-unwrapped`）で隣接ペインの出力を読む。
3. **待機** — `wait output`（`--match`/`--regex`/`--timeout`）で特定出力を、`wait agent-status`（`idle`/`working`/`blocked`/`done`）で他エージェント完了を待つ。
4. **エージェント spawn / 協調** — `pane split` + `pane run` で別ペインにサーバ・テスト・エージェントを起動し協調する。

- `HERDR_ENV` が `1` でない場合は**非適用**（herdr 外部から focused ペインを操作・検査しない）。
- Claude Code 内の並列タチコマ編成（`orchestrating-teams`）とは別物。herdr は OS レベルの端末ペインをまたぐ制御を担う。

## 主要スラッシュコマンド

| コマンド | 説明 |
|---------|------|
| `/serena "問題"` | トークン効率的な構造化開発 |
| `/reload` | CLAUDE.md再読み込み（compaction後） |
| `/code-review` | PRコードレビュー |
| `/feature-dev` | 機能開発ワークフロー |
| `software-security` スキル | 🔴 セキュリティチェック（実装後必須・devkit / Project CodeGuard 日本語版） |
| `/ralph-loop` / `/cancel-ralph` | 反復開発ループ |

その他のコマンド・プラグインは `/skills` `/plugins` で確認可能。
