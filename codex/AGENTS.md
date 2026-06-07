# エージェントガイド

このリポジトリでは `agents/` ディレクトリに定義されたエージェント（タチコマ）群を使用して、タスクを専門領域ごとに委譲・並列実行します。

---

## エージェント体制の概要

| 役割 | エージェント数 | モデル | 説明 |
|------|-------------|--------|------|
| **専門タチコマ** | 21体 | Sonnet/Opus | ドメイン特化の実装ワーカー（スキルプリロード済み） |
| **汎用タチコマ** | 1体 | Sonnet | 専門タチコマでカバーされないタスクのフォールバック |
| **Serena Expert** | 1体 | Sonnet | `/serena` コマンドによるトークン効率的な開発 |

---

## エージェント一覧とルーティング

タスクの内容に応じて、以下の検出条件から最適なエージェントを選択して委譲します。

### 言語・フレームワーク特化

| # | エージェント名 | ファイル | 検出条件 | 専門領域 | モード |
|---|--------------|---------|---------|---------|-------|
| 1 | タチコマ（Next.js） | `tachikoma-nextjs.toml` | `package.json` に `next` | Next.js 16.x App Router, React 19.x, Server/Client Components, Cache Components, next-devtools MCP | 実装 |
| 2 | タチコマ（フロントエンド） | `tachikoma-frontend.toml` | shadcn/ui, コンポーネント実装, Storybook, データチャート | shadcn/ui, Storybook CSF3, データビジュアライゼーション, a11y | 実装 |
| 3 | タチコマ（フルスタックJS） | `tachikoma-fullstack-js.toml` | NestJS, Express, Fastify | NestJS/Expressアーキテクチャ, RESTful API設計, 構造化ログ, 認証・認可 | 実装 |
| 4 | タチコマ（TypeScript） | `tachikoma-typescript.toml` | TypeScript型設計・高度な型 | Generics, Conditional Types, Mapped Types, GoFパターンのTS実装 | 実装 |
| 5 | タチコマ（Python） | `tachikoma-python.toml` | `pyproject.toml`, `requirements.txt`, Python | Python 3.13+, uv/ruff/mypy, FastAPI/FastMCP, Google ADK, pytest | 実装 |
| 6 | タチコマ（Go） | `tachikoma-go.toml` | `go.mod`, Goコード | Concurrencyパターン, インターフェース設計, エラーハンドリング, テーブル駆動テスト | 実装 |
| 7 | タチコマ（Bash） | `tachikoma-bash.toml` | `.sh` ファイル, シェルスクリプト | Bash strict mode, I/Oパイプライン, プロセス制御, ShellCheck | 実装 |

### インフラ・クラウド

| # | エージェント名 | ファイル | 検出条件 | 専門領域 | モード |
|---|--------------|---------|---------|---------|-------|
| 8 | タチコマ（インフラ） | `tachikoma-infra.toml` | Dockerfile, docker-compose.yml, CI/CD設定 | Docker, Compose v2, マルチステージビルド, CI/CDパイプライン, DevOps | 実装 |
| 9 | タチコマ（Terraform） | `tachikoma-terraform.toml` | `.tf` ファイル, `terragrunt.hcl` | HCL構文, モジュール設計, state管理, Terragruntパターン | 実装 |
| 10 | タチコマ（AWS） | `tachikoma-aws.toml` | `cdk.json`, `samconfig.toml`, `@aws-sdk`, `boto3` | Lambda, API Gateway, DynamoDB, CDK, EKS, Bedrock, IAM, FinOps | 実装 |
| 11 | タチコマ（Google Cloud） | `tachikoma-google-cloud.toml` | `cloudbuild.yaml`, `.gcloudignore`, `@google-cloud` | Cloud Run, BigQuery, VPC, Memorystore, GCPセキュリティ, データエンジニアリング | 実装 |

### 設計・品質・セキュリティ

| # | エージェント名 | ファイル | 検出条件 | 専門領域 | モード |
|---|--------------|---------|---------|---------|-------|
| 12 | タチコマ（アーキテクチャ） | `tachikoma-architecture.toml` | 設計/DDD/アーキテクチャ判断 | DDD戦略・戦術, CQRS, Event Sourcing, Sagaパターン, ADR, マルチテナントSaaS | **読取専用**（Opus） |
| 13 | タチコマ（セキュリティ） | `tachikoma-security.toml` | セキュリティ監査/脆弱性分析 | OWASP Top 10, サーバーレスセキュリティ, 動的認可(ABAC/ReBAC/Cedar), Keycloak, AI開発セキュリティ | **読取専用**（Opus） |
| 14 | タチコマ（データベース） | `tachikoma-database.toml` | `schema.prisma`, `.sql`, DB関連パッケージ | エンティティモデリング, 正規化, SQLアンチパターン, DBインターナル(B-tree/LSM/MVCC), インデックス設計 | 実装 |

### テスト

| # | エージェント名 | ファイル | 検出条件 | 専門領域 | モード |
|---|--------------|---------|---------|---------|-------|
| 15 | タチコマ（テスト） | `tachikoma-test.toml` | `*test*`, `*spec*`, `*_test.go`, `test_*.py` | TDD, AAAパターン, Vitest/Jest/RTL, Go testing, pytest, モック戦略 | 実装 |
| 16 | タチコマ（E2Eテスト） | `tachikoma-e2e-test.toml` | Playwright, E2E, `playwright.config.*` | Playwright Test, POM, ビジュアルテスト, a11yテスト, CI/CD統合, Browser Agent CLI | 実装 |

### AI・オブザーバビリティ

| # | エージェント名 | ファイル | 検出条件 | 専門領域 | モード |
|---|--------------|---------|---------|---------|-------|
| 17 | タチコマ（AI/ML） | `tachikoma-ai-ml.toml` | AI/RAG/MCP/LLM関連コード | Vercel AI SDK, LangChain.js, RAGシステム, MCP開発, LLMOps | 実装 |
| 18 | タチコマ（オブザーバビリティ） | `tachikoma-observability.toml` | `@opentelemetry/*`, `prometheus.yml` | 監視設計, OpenTelemetry計装, 構造化ログ, SLO/SLI, アラート設計 | 実装 |

### デザイン・ドキュメント・研修

| # | エージェント名 | ファイル | 検出条件 | 専門領域 | モード |
|---|--------------|---------|---------|---------|-------|
| 19 | タチコマ（デザイン） | `tachikoma-design.toml` | Figma URL, デザインシステム構築, Tailwind設計 | Figma MCP全13ツール, Code Connect, デザイントークン同期, デザインシステム構築, Tailwind CSS, UI/UX原則 | 実装 |
| 20 | タチコマ（ドキュメント） | `tachikoma-document.toml` | 技術文書/記事/LaTeX | 文章基礎(7Cs), AI臭検出・除去, LaTeX, Zenn記事, コピーライティング | **コード非記述** |
| 21 | タチコマ（研修・プレゼン） | `tachikoma-training-presenter.toml` | 研修設計/プレゼン改善/ワークショップ | ニーズ分析, インストラクショナルデザイン, 行動変容(CREATE), ストーリー構成, PUNCH原則 | **コード非記述**（自己進化型） |

### 汎用・特殊

| # | エージェント名 | ファイル | 検出条件 | 専門領域 | モード |
|---|--------------|---------|---------|---------|-------|
| 22 | タチコマ（汎用） | `tachikoma.toml` | 上記以外すべて | 専門タチコマでカバーされない汎用タスク | 実装 |
| 23 | Serena Expert | `serena-expert.toml` | `/serena` コマンド使用時 | トークン効率的な開発全般（Component/API/Test/System） | 実装 |

---

## ルーティング判断のポイント

- **タチコマ（デザイン） vs タチコマ（フロントエンド）**: Figma MCP・デザイントークン同期・Code Connect・デザインシステム構築・Tailwind CSS設計・UI/UX原則 → デザイン。shadcn/ui実装・Storybook・データビジュアライゼーション → フロントエンド
- **タチコマ（テスト） vs 言語別タチコマ**: テスト設計・カバレッジ改善・TDD・テストリファクタリングが主題 → テスト。機能実装の一部としてテストも書く → 言語別タチコマ
- **複数の検出条件に該当** → より専門的な方を優先（例: Next.js + UI → Next.js をメイン、フロントエンドをサブ）
- **並列実行** → 異なる専門タチコマを同時起動可能（例: Next.js + E2Eテスト）。同一タチコマの複数起動も可能
- **読取専用エージェント**（アーキテクチャ・セキュリティ）→ 設計ドキュメント・レポートのみ出力。実装コードは書かない

## 共通仕様

すべてのタチコマは以下の共通仕様に従います:

- **言語**: 日本語で応答（技術用語を除く）
- **バージョン管理**: Jujutsu (jj) 使用（git原則禁止）
- **コミット**: Conventional Commits形式
- **品質**: SOLID原則・型安全性（any禁止）・テスト（AAAパターン）・セキュリティチェック（CodeGuard）
- **報告**: 完了報告は【完了報告】フォーマットでCodex本体に送信
- **並列実行**: `docs/plan-xxx.md` の担当セクションを正式な仕様書として参照

---

## 📥 スキル改善提案 (inbox)

sumik-claude-plugin スキルの改善提案キュー（Codex 版）。捕捉(C)→消費(D=`authoring-plugins` の「🔄 改善提案INTAKE」)を繋ぐ。Claude Code 側の `~/.claude/CLAUDE.md` inbox と**対になる Codex 側 inbox** で、INTAKE は両方を走査する。**openのみ保持**し、消費後は削除（本ファイルを肥大させない）。フォーマット全仕様は `authoring-plugins/references/IMPROVEMENT-INTAKE.md §2`。

**捕捉ルール（発見時の振る舞い）**: sumik-claude-plugin スキルを読込/使用中に改善余地（description不正確・肥大・統合余地・知見追記漏れ・参照切れ・規約違反）を発見したら、**即編集せず**下記へ提案を1件追記する（軽微typoは即修正可）。①実際に読込/使用したスキルに限る（未読の推測提案禁止）②1スキル1セッション1件 ③確度=低は書かない ④具体的改善文/削除対象行を伴うもののみ（漠然とした感想不可）⑤作業主目的を中断せずタスク完了後に追記。

各提案は `### [PROPOSAL] <skill> / <種別> / <日付>` 見出し＋ skill・種別(description改善/分割/統合/内容追記/参照修正/規約違反)・改善点・理由(書籍名禁止)・確度(高/中)・影響範囲・status を箇条書きで持つ。

**発火**: open が3件以上、またはユーザーが「スキル改善まわして」と指示した時、`authoring-plugins` の INTAKE を起点に消費する。Codex のコミットは Jujutsu (jj) を使用（git原則禁止）。

<!-- open な提案をここに追記。処理後はドレイン。Claude Code 側で気づいた提案は ~/.claude/CLAUDE.md の inbox に入る。 -->

---

# MCP 利用ガイド（この環境で有効なサーバ）

このリポジトリでは `config.toml` の設定に基づき、以下の MCP サーバが有効です。用途に応じて最適なサーバを選び、不要なときは呼び出さない方針とします。

## MCP とは
Model Context Protocol (MCP) は、LLM アプリケーションが外部ツールやデータソースと連携するためのオープンなプロトコルです。MCP サーバはツール群を提供し、クライアント（このエージェントなど）がそれらを呼び出します。

## 有効な MCP 一覧
- serena
- deepthinking
- next-devtools
- context7
- chrome-devtools

---

## serena（セマンティックなコード検索/編集）
**概要**
Serena は、シンボル単位の検索・編集など IDE 的な操作を MCP として提供するコーディング支援ツールキットです。大規模コードベースの理解・編集を効率化します。

**使う場面**
- コードベース内のシンボル探索、参照検索、限定的な編集
- 「どこを編集すべきか」を素早く特定したいとき
- 大きなリポジトリでの安全な局所変更

**注意点**
- 小さなファイルのみの作業や、新規作成中心のタスクでは効果が薄い場合あり

**参考**
- 概要/README: `https://raw.githubusercontent.com/oraios/serena/main/README.md`

---

## deepthinking（段階的な思考・比較・分岐の支援）
**概要**
DeepThinking は、順序立った思考プロセスを支援する MCP サーバです。複数の思考モード、セッション管理、可視化、テンプレートなどを提供します。

**使う場面**
- 複数案の比較、分岐検討、逆算、仮説検証が必要な設計検討
- 根拠を段階的に整理して結論を出したいとき
- 長い思考をセッションとして保持・再利用したいとき

**注意点**
- 単純な作業には過剰になりやすい

**参考**
- PyPI: `https://pypi.org/project/DeepThinking/`

---

## next-devtools（Next.js 16+ の実行時診断/メタ情報）
**概要**
Next.js 16+ の dev server が提供する MCP エンドポイントに接続し、ルート/エラー/ログ/メタ情報などの実行時情報を取得します。

**使う場面**
- Next.js アプリのランタイム診断（ビルド/実行時エラー、ログ）
- ルートやメタ情報の把握、Server Actions の調査
- Next.js 16 への移行や Cache Components の支援

**注意点**
- Next.js 16+ が必要
- ランタイムの情報を使うため、dev server が起動していることが前提

**参考**
- Next.js MCP ガイド: `https://nextjs.org/docs/app/guides/mcp`

---

## context7（ライブラリ/SDK の最新ドキュメント取得）
**概要**
Context7 は、ライブラリや SDK の最新ドキュメントとコード例を取得する MCP サーバです。`resolve-library-id` と `query-docs` を使って、目的のドキュメントを素早く引き当てます。

**使う場面**
- ライブラリやフレームワークの API 仕様を正確に参照したいとき
- バージョン差分を意識した手順やサンプルが必要なとき
- 公式ドキュメントに基づいた実装を求められるとき

**注意点**
- API キーやリモート/ローカル構成に注意
- クエリは MCP 側で形成され、センシティブ情報の送出を避ける設計（ただし入力には注意）

**参考**
- インストール/ツール一覧: `https://context7.com/docs/installation`
- セキュリティ/データ取り扱い: `https://context7.com/docs/resources/security`

---

## chrome-devtools（ブラウザ実行/性能/ネットワーク調査）
**概要**
Chrome DevTools MCP は、Chrome の DevTools を通してブラウザの実行状態を検査し、性能トレースやネットワーク解析などを行います。

**使う場面**
- 実ブラウザでの動作検証が必要なとき
- パフォーマンス測定（LCP/CLS など）やネットワーク調査
- DOM/Console/スクリーンショットなどの検証

**注意点**
- ブラウザの内容が MCP クライアントに公開されるため、機密情報のあるページには注意
- 使用状況の統計が収集される設定があるため、必要なら無効化オプションを検討

**参考**
- 公式ブログ: `https://developer.chrome.com/blog/chrome-devtools-mcp`
- README: `https://github.com/ChromeDevTools/chrome-devtools-mcp`

---

## 使い分けの指針（簡易）
- **コードの探索/編集**: serena
- **設計の比較や深い思考**: deepthinking
- **Next.js の実行時診断**: next-devtools
- **ライブラリの最新ドキュメント**: context7
- **ブラウザ挙動/性能解析**: chrome-devtools
