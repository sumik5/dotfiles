# サブエージェントルーティング

本体の役割 =「適切な専門タチコマにルーティングする」こと。

## ルーティング表

| 検出条件 | 委譲先 subagent_type |
|---------|---------------------|
| `package.json` に `next` | `sumik:タチコマ（Next.js）` |
| Figma URL/.figma/Code Connect/トークン同期/Tailwind実装 | `sumik:タチコマ（Figma実装）` |
| DS構築/ガバナンス/パターンライブラリ/Figma変数管理 | `sumik:タチコマ（デザインシステム）` |
| UX戦略/デザイン思考/グラフィック/AIエクスペリエンス | `sumik:タチコマ（UXデザイン）`（コード記述なし） |
| shadcn/ui/Storybook/データチャート | `sumik:タチコマ（フロントエンド）` |
| NestJS/Express/Fastify | `sumik:タチコマ（フルスタックJS）` |
| TypeScript型設計・高度な型 | `sumik:タチコマ（TypeScript）` |
| Python | `sumik:タチコマ（Python）` |
| Go | `sumik:タチコマ（Go）` |
| `.sh` / シェルスクリプト | `sumik:タチコマ（Bash）` |
| Docker/CI-CD/DevOps/Podman | `sumik:タチコマ（インフラ）` |
| `.tf` / Terraform | `sumik:タチコマ（Terraform）` |
| AWS (CDK/SAM/SDK/Bedrock) | `sumik:タチコマ（AWS）` |
| GCP (Cloud Run/GKE) | `sumik:タチコマ（Google Cloud）` |
| DB/SQL/Prisma/マイグレーション | `sumik:タチコマ（データベース）` |
| AI/RAG/MCP/LLM | `sumik:タチコマ（AI/ML）` |
| テストファイル（`*test*`, `*spec*`等） | `sumik:タチコマ（テスト）` |
| Playwright/E2E | `sumik:タチコマ（E2Eテスト）` |
| 監視/OTel/ログ | `sumik:タチコマ（オブザーバビリティ）` |
| 技術文書/記事/LaTeX | `sumik:タチコマ（ドキュメント）` |
| 設計/DDD/アーキテクチャ | `sumik:タチコマ（アーキテクチャ）`（読取専用） |
| セキュリティ監査 | `sumik:タチコマ（セキュリティ）`（読取専用） |
| 研修/プレゼン | `sumik:タチコマ（研修・プレゼン）` |
| 上記以外 | `sumik:タチコマ` |

### 判断ポイント

- **複数条件該当** → より専門的な方を優先（例: Next.js+UI → Next.jsメイン）
- **テスト主題（TDD・カバレッジ改善）** → タチコマ（テスト）。機能実装の一部 → 言語タチコマ
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
