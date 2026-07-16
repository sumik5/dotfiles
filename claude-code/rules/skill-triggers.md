# サブエージェントルーティング

本体の役割 =「適切な専門タチコマにルーティングする」こと。

## ルーティング表

| 検出条件 | 委譲先 subagent_type |
|---------|---------------------|
| `package.json` に `next` | `devkit:tachikoma-fw-nextjs` |
| Figma URL/.figma/Code Connect/トークン同期/Tailwind実装 | `devkit:tachikoma-fe-figma-impl` |
| DS構築/ガバナンス/パターンライブラリ/Figma変数管理 | `devkit:tachikoma-fe-design-system` |
| UX戦略/デザイン思考/グラフィック/AIエクスペリエンス | `devkit:tachikoma-fe-ux-design`（コード記述なし） |
| shadcn/ui/Storybook/データチャート | `devkit:tachikoma-fe-frontend` |
| NestJS/Express/Fastify | `devkit:tachikoma-fw-fullstack-js` |
| TypeScript型設計・高度な型 | `devkit:tachikoma-lang-typescript` |
| Python | `devkit:tachikoma-lang-python` |
| Go | `devkit:tachikoma-lang-go` |
| `.sh` / シェルスクリプト | `devkit:tachikoma-lang-bash` |
| Docker/CI-CD/DevOps/Podman | `devkit:tachikoma-cloud-infra` |
| `.tf` / Terraform | `devkit:tachikoma-cloud-terraform` |
| AWS (CDK/SAM/SDK/Bedrock) | `devkit:tachikoma-cloud-aws` |
| GCP (Cloud Run/GKE) / Firebase (Auth/Firestore/Functions・`firebase.json`/`firestore.rules`検出) | `devkit:tachikoma-cloud-gcp` |
| DB/SQL/Prisma/マイグレーション | `devkit:tachikoma-data-database` |
| AI/RAG/MCP/LLM / LLM評価・red-team（`promptfooconfig.yaml`） | `devkit:tachikoma-data-ai-ml` |
| テストファイル（`*test*`, `*spec*`等） | `devkit:tachikoma-qa-test` |
| Playwright/E2E | `devkit:tachikoma-qa-e2e-test` |
| アプリのweb操作・ブラウザ自動化（スクレイピング/UI操作/認証永続化・非E2E） | 本体直接（`web:automating-browser` ロード）or `devkit:tachikoma-qa-e2e-test` |
| 監視/OTel/ログ | `devkit:tachikoma-qa-observability` |
| 技術文書/記事/LaTeX | `devkit:tachikoma-doc-document` |
| 設計/DDD/アーキテクチャ | `devkit:tachikoma-str-architecture`（読取専用） |
| セキュリティ監査 | `devkit:tachikoma-qa-security`（読取専用） |
| コードレビュー主題（PR review・品質監査） | `devkit:tachikoma-qa-code-reviewer`（読取専用） |
| 研修設計/プレゼン内容改善 | `devkit:tachikoma-doc-training` |
| HTMLスライドデッキ作成（slides repo 3層モデル・テーマ・素材変換） | `devkit:tachikoma-doc-slide` |
| iOS/iPadOS/macOSアプリ開発（Swift/SwiftUI/UIKit・`.xcodeproj`/`.xcworkspace`/`Package.swift`/`.swift`検出）・App Store審査対応監査 | `devkit:tachikoma-mobile-ios` |
| Flutter/Dartクロスプラットフォーム開発（`pubspec.yaml`のflutter SDK依存・`.dart`ファイル検出） | `devkit:tachikoma-mobile-flutter` |
| 上記以外 | `devkit:tachikoma` |

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
| `searching-web` | Web検索（Exa MCP第一優先・geminiフォールバックを内包） |
| `capturing-learnings` | ユーザー訂正・非自明エラー・機能要望・反復パターン発生時（`.learnings/`記録→memory/CLAUDE.md昇格）。詳細: `rules/capturing-learnings.md` |
| `web:automating-browser` | アプリのweb操作・ブラウザ自動化時（agent-browser CLI・第一選択。未導入なら同スキルの`scripts/install.sh`で自動導入）。E2Eは`tachikoma-qa-e2e-test`へ。詳細: `rules/plugins-and-commands.md` |
| `operating-herdr` | 🔴 herdr 環境（`HERDR_ENV=1`）で作業時（**必ずロード**）。herdr = terminal-native agent multiplexer。workspace/tab/pane 制御・別ペイン出力読取・`wait output`/`wait agent-status` 待機・エージェント spawn/協調をCLIで行う。`HERDR_ENV` が `1` でなければ非適用（herdr 外部から focused ペインを操作しない）。詳細: `rules/plugins-and-commands.md` |

## オンデマンドスキル（明示的要求時のみ）

フラッシュカード(`certificate:creating-flashcards`) / プレゼン(`studio:creating-slides`, `studio:gws-slides`) / 図表(`studio:creating-diagrams`) / Codex(`orchestrating-codex`) / PM(`product:practicing-product-management`) / アルゴリズム(`lang:solving-algorithms`・言語非依存リファレンス・特定agent非割当=意図的省略)

> **スキル分割メモ**: `design:designing-ux` から `design:designing-ai-experiences`（AI体験設計）・`design:practicing-design-thinking`（デザイン思考プロセス・UXリサーチ）を分離。3スキルとも `tachikoma-fe-ux-design` が担当（上表「UX戦略/デザイン思考/AIエクスペリエンス」行に集約）。
