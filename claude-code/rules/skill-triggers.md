# サブエージェント委譲ガイド

専門タチコマ21体の導入により、Claude Code本体がスキルをロードして自ら実装する必要はなくなった。
本体の役割は「適切な専門タチコマにルーティングする」こと。

---

## 🔴 サブエージェントルーティング表

コード実装・変更タスクを受けた場合、以下の検出条件から適切な専門タチコマを選択し委譲する:

| 検出条件 | 委譲先 subagent_type | 主要プリロードスキル |
|---------|---------------------|-------------------|
| `package.json` に `next` | `sumik:タチコマ（Next.js）` | developing-nextjs, developing-react, using-next-devtools |
| Figma URL/Make/.figma/design-system-rules/デザインシステム構築/Tailwind設計 | `sumik:タチコマ（デザイン）` | implementing-design, implementing-figma, applying-design-guidelines, building-design-systems, styling-with-tailwind |
| shadcn/ui/コンポーネント実装/Storybook/データチャート | `sumik:タチコマ（フロントエンド）` | designing-frontend, developing-storybook, designing-data-visualizations |
| NestJS/Express/Fastify | `sumik:タチコマ（フルスタックJS）` | developing-fullstack-javascript, designing-web-apis, developing-api-spec-first |
| TypeScript型設計・高度な型 | `sumik:タチコマ（TypeScript）` | mastering-typescript |
| Python | `sumik:タチコマ（Python）` | developing-python, building-adk-agents |
| Go | `sumik:タチコマ（Go）` | developing-go, developing-api-spec-first |
| `.sh` / シェルスクリプト | `sumik:タチコマ（Bash）` | developing-bash |
| Docker/CI-CD/DevOps | `sumik:タチコマ（インフラ）` | managing-docker, practicing-devops |
| Containerfile/podman/buildah/skopeo | `sumik:タチコマ（インフラ）` | managing-podman |
| `.tf` / Terraform | `sumik:タチコマ（Terraform）` | developing-terraform |
| AWS (CDK/SAM/SDK/Bedrock) | `sumik:タチコマ（AWS）` | developing-aws |
| GCP (Cloud Run/GKE) | `sumik:タチコマ（Google Cloud）` | developing-google-cloud |
| DB/SQL/Prisma/マイグレーション | `sumik:タチコマ（データベース）` | designing-relational-databases, avoiding-sql-antipatterns |
| AI/RAG/MCP/LLM | `sumik:タチコマ（AI/ML）` | integrating-ai-web-apps, building-rag-systems, developing-mcp, building-langchain-agents |
| テストファイル（`*test*`, `*spec*`, `*_test.go`, `test_*.py` 等） | `sumik:タチコマ（テスト）` | testing-code |
| Playwright/E2E/ブラウザテスト | `sumik:タチコマ（E2Eテスト）` | testing-e2e-with-playwright, automating-browser |
| 監視/OTel/ログ/メトリクス | `sumik:タチコマ（オブザーバビリティ）` | designing-monitoring, implementing-opentelemetry |
| 技術文書/記事/LaTeX | `sumik:タチコマ（ドキュメント）` | writing-effective-prose, writing-zenn-articles |
| 設計/DDD/アーキテクチャ判断 | `sumik:タチコマ（アーキテクチャ）` | applying-domain-driven-design, architecting-microservices, applying-clean-architecture（読取専用） |
| セキュリティ監査/脆弱性分析 | `sumik:タチコマ（セキュリティ）` | securing-code, securing-serverless（読取専用） |
| 研修設計/プレゼン改善/ワークショップ | `sumik:タチコマ（研修・プレゼン）` | improving-presentations, writing-effective-prose, designing-training, applying-behavior-design |
| 上記以外 | `sumik:タチコマ` | 汎用フォールバック（スキルプリロードなし） |

### ルーティング判断のポイント

- **タチコマ（デザイン）vs タチコマ（フロントエンド）**: Figma MCP全面活用・デザイントークン同期・Code Connect・デザインシステム構築・Tailwind CSS設計・UI/UX原則 → タチコマ（デザイン）。shadcn/uiコンポーネント実装・Storybook・データビジュアライゼーション → タチコマ（フロントエンド）
- **複数の検出条件に該当** → より専門的な方を優先（例: Next.js + UI → タチコマ（Next.js）をメイン、タチコマ（フロントエンド）をサブ）
- **並列実行時** → 異なる専門タチコマを同時起動可能（例: タチコマ（Next.js）+ タチコマ（E2Eテスト）
- **同一専門タチコマの複数起動** → 可能（例: タチコマ（Next.js）を2体起動して異なるページを並列実装）
- **テストエージェント vs 言語エージェント**: テスト設計・カバレッジ改善・TDD・テストリファクタリングが主題 → タチコマ（テスト）。機能実装の一部としてテストも書く → 言語エージェント（各言語エージェントも testing-code スキルを持つ）

### tmux pane起動ルール（🔴 必須）

- **🔴 ToolSearch 必須（最重要）**: Agent Teams API ツール（TeamCreate, TeamDelete, TaskCreate, TaskUpdate, TaskList, SendMessage）は**遅延ツール**。`ToolSearch("TeamCreate team")` 等で**事前にロード**しないと呼び出せない。これがtmux paneが開かない最大の原因
- **TeamCreate 必須**: タチコマ起動前に必ず TeamCreate でチームを作成（軽微修正でも必須）
- Task tool に `team_name` + `run_in_background: true` を**両方**指定 → tmux pane起動
- ⚠️ `run_in_background: true` のみ（`team_name` なし）→ バックグラウンド実行されるが**tmux paneには表示されない**
- 1メッセージ内で複数のTask tool呼び出しを行い、tmux paneで並列起動
- Bash toolでのタチコマ起動は禁止
- 単体タスク完了後は TeamDelete でチームを解放（1セッション1チーム制約）

---

## 🟡 本体が直接使用するスキル

以下のスキルは専門タチコマに委譲せず、Claude Code本体が直接Skillツールでロードして使用する:

### メタ・運用
| スキル | トリガー | 概要 |
|--------|---------|------|
| `orchestrating-teams` | 軽微修正以外のすべての開発タスク（デフォルト） | planner-first パターン: チーム編成 → planner計画策定 → 専門タチコマ実装 |
| `managing-claude-md` | CLAUDE.md改善・罠追記時 | 設定ファイル管理（8原則） |
| `researching-libraries` | 新機能実装前 | 既存ライブラリ調査（車輪の再発明禁止） |
| `using-serena` | `/serena` コマンド使用時 | トークン効率的構造化開発 |
| `authoring-skills` | 新スキル作成時 | スキル作成ガイド |

### バージョン管理・品質（本体が判断するもの）
| スキル | トリガー | 概要 |
|--------|---------|------|
| `applying-semantic-versioning` | バージョン判断時 | SemVer 2.0.0準拠 |
| `writing-conventional-commits` | コミットメッセージ作成時 | Conventional Commits 1.0.0 |

### 情報収集
| スキル | トリガー | 概要 |
|--------|---------|------|
| `searching-with-exa` | Web検索・情報収集時 | Exa MCP第一優先 |
| `searching-web` | Exa MCP使用不可時 | gemini CLI フォールバック |

---

## 🟢 オンデマンドスキル（特殊用途）

以下はユーザーの明示的な要求がある場合のみロードする:

| トリガー | スキル | 概要 |
|---------|--------|------|
| フラッシュカード作成 | `creating-flashcards`, `using-anki-mcp` | Ankiフラッシュカード |
| プレゼン作成 | `generating-google-slides`, `slidekit-create`, `slidekit-templ` | スライド生成 |
| 翻訳 | `translating-with-lmstudio` | LMStudio翻訳 |
| Codex相談 | `using-codex` | OpenAI Codex CLI |
| 差分表示 | `viewing-diffs` | 差分ビューア |
| 図表作成 | `mermaid-diagrams`, `using-drawio-mcp` | 図表生成 |
| PM業務 | `using-claude-code-as-pm` | PM向けClaude活用 |
