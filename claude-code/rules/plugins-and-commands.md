# プラグイン・MCP・コマンド

## MCP優先順位

1. **serena** — コード分析・編集・メモリ（プロジェクト作業前に必ず初期化）
2. **next-devtools** — Next.js専用（診断・アップグレード・Cache Components）
3. **context7** — ライブラリドキュメント検索
4. **puppeteer** / **chrome-devtools** — ブラウザ自動化
5. **shadcn** / **figma** / **mcp-pandoc** / **sequentialthinking** — 用途別

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
