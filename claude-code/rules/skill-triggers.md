# サブエージェントルーティング

本体の役割 =「適切な専門タチコマにルーティングする」こと。

## ルーティング表

| 検出条件 | 委譲先 subagent_type |
|---------|---------------------|
| `package.json` に `next` | `sumik:tachikoma-fw-nextjs` |
| Figma URL/.figma/Code Connect/トークン同期/Tailwind実装 | `sumik:tachikoma-fe-figma-impl` |
| DS構築/ガバナンス/パターンライブラリ/Figma変数管理 | `sumik:tachikoma-fe-design-system` |
| UX戦略/デザイン思考/グラフィック/AIエクスペリエンス | `sumik:tachikoma-fe-ux-design`（コード記述なし） |
| shadcn/ui/Storybook/データチャート | `sumik:tachikoma-fe-frontend` |
| NestJS/Express/Fastify | `sumik:tachikoma-fw-fullstack-js` |
| TypeScript型設計・高度な型 | `sumik:tachikoma-lang-typescript` |
| Python | `sumik:tachikoma-lang-python` |
| Go | `sumik:tachikoma-lang-go` |
| `.sh` / シェルスクリプト | `sumik:tachikoma-lang-bash` |
| Docker/CI-CD/DevOps/Podman | `sumik:tachikoma-cloud-infra` |
| `.tf` / Terraform | `sumik:tachikoma-cloud-terraform` |
| AWS (CDK/SAM/SDK/Bedrock) | `sumik:tachikoma-cloud-aws` |
| GCP (Cloud Run/GKE) | `sumik:tachikoma-cloud-gcp` |
| DB/SQL/Prisma/マイグレーション | `sumik:tachikoma-data-database` |
| AI/RAG/MCP/LLM | `sumik:tachikoma-data-ai-ml` |
| テストファイル（`*test*`, `*spec*`等） | `sumik:tachikoma-qa-test` |
| Playwright/E2E | `sumik:tachikoma-qa-e2e-test` |
| 監視/OTel/ログ | `sumik:tachikoma-qa-observability` |
| 技術文書/記事/LaTeX | `sumik:tachikoma-doc-document` |
| 設計/DDD/アーキテクチャ | `sumik:tachikoma-str-architecture`（読取専用） |
| セキュリティ監査 | `sumik:tachikoma-qa-security`（読取専用） |
| コードレビュー主題（PR review・品質監査） | `sumik:tachikoma-qa-code-reviewer`（読取専用） |
| 研修/プレゼン | `sumik:tachikoma-doc-training` |
| 上記以外 | `sumik:tachikoma` |

### 判断ポイント

- **複数条件該当** → より専門的な方を優先（例: Next.js+UI → Next.jsメイン）
- **テスト主題（TDD・カバレッジ改善）** → tachikoma-qa-test。機能実装の一部 → 言語タチコマ
- **デザイン3体**: Figma→コード → Figma実装。DS運用 → デザインシステム。UX戦略 → UXデザイン

## 本体が直接使用するスキル

| スキル | トリガー |
|--------|---------|
| `orchestrating-teams` | 軽微修正以外の開発タスク（デフォルト） |
| `managing-claude-md` | CLAUDE.md改善時 |
| `researching-libraries` | 新機能実装前 |
| `applying-semantic-versioning` | バージョン判断時 |
| `writing-conventional-commits` | コミットメッセージ作成時 |
| `searching-with-exa` | Web検索（第一優先。fallback: `searching-web`） |

## オンデマンドスキル（明示的要求時のみ）

フラッシュカード(`using-anki-mcp`) / プレゼン(`slidekit-create`, `generating-google-slides`) / 図表(`mermaid-diagrams`, `using-drawio-mcp`) / Codex(`using-codex`) / PM(`using-claude-code-as-pm`)
