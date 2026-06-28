# エージェントガイド

このリポジトリでは `agents/` ディレクトリに定義されたエージェント（タチコマ）群を使用して、タスクを専門領域ごとに委譲・並列実行します。

---

## エージェント体制の概要

| 役割 | エージェント数 | モデル | 説明 |
|------|-------------|--------|------|
| **専門タチコマ** | 26体 | gpt-5.4 | ドメイン特化の実装ワーカー（スキルプリロード済み） |
| **汎用タチコマ** | 1体 | gpt-5.4 | 専門タチコマでカバーされないタスクのフォールバック |
| **Serena Expert** | 1体 | gpt-5.4 | `/serena` コマンドによるトークン効率的な開発 |

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
| 11 | タチコマ（Google Cloud） | `tachikoma-google-cloud.toml` | `cloudbuild.yaml`, `.gcloudignore`, `@google-cloud`, `firebase.json`, `firestore.rules` | Cloud Run, BigQuery, VPC, Memorystore, Firebase(Auth/Firestore/Functions), GCPセキュリティ, データエンジニアリング | 実装 |

### フロントエンド・デザイン

| # | エージェント名 | ファイル | 検出条件 | 専門領域 | モード/effort |
|---|--------------|---------|---------|---------|-------|
| 12 | タチコマ（Figma実装） | `tachikoma-figma-impl.toml` | Figma URL, `.figma`, Code Connect, トークン同期, Tailwind実装 | Figma MCP全13ツール, Code Connect, デザイントークン同期, Tailwind CSS, ビジュアル検証 | 実装 / high |
| 13 | タチコマ（デザインシステム） | `tachikoma-design-system.toml` | DS構築, ガバナンス, パターンライブラリ, Figma変数管理 | DS3層アーキテクチャ, パターンライブラリ, Figma変数/トークン管理, ガバナンス, 組織導入 | 実装 / high |
| 14 | タチコマ（UXデザイン） | `tachikoma-ux-design.toml` | UX戦略, デザイン思考, グラフィック, AIエクスペリエンス | UI/UX哲学, デザイン思考プロセス, グラフィック基礎, AI体験設計 | **コード非記述** / high |

### 設計・品質・セキュリティ

| # | エージェント名 | ファイル | 検出条件 | 専門領域 | モード/effort |
|---|--------------|---------|---------|---------|-------|
| 15 | タチコマ（アーキテクチャ） | `tachikoma-architecture.toml` | 設計/DDD/アーキテクチャ判断 | DDD戦略・戦術, CQRS, Event Sourcing, Sagaパターン, ADR, マルチテナントSaaS | **読取専用** / xhigh |
| 16 | タチコマ（セキュリティ） | `tachikoma-security.toml` | セキュリティ監査/脆弱性分析 | OWASP Top 10, サーバーレスセキュリティ, 動的認可(ABAC/ReBAC/Cedar), Keycloak, AI開発セキュリティ | **読取専用** / xhigh |
| 17 | タチコマ（コードレビュー） | `tachikoma-code-reviewer.toml` | コードレビュー/品質監査/PRレビュー | バグ・ロジックエラー・脆弱性・コード品質・プロジェクト規約の確認（信頼度フィルタで高優先度のみ報告） | **読取専用** / xhigh |
| 18 | タチコマ（データベース） | `tachikoma-database.toml` | `schema.prisma`, `.sql`, DB関連パッケージ | エンティティモデリング, 正規化, SQLアンチパターン, DBインターナル(B-tree/LSM/MVCC), インデックス設計 | 実装 / high |

### テスト

| # | エージェント名 | ファイル | 検出条件 | 専門領域 | モード/effort |
|---|--------------|---------|---------|---------|-------|
| 19 | タチコマ（テスト） | `tachikoma-test.toml` | `*test*`, `*spec*`, `*_test.go`, `test_*.py` | TDD, AAAパターン, Vitest/Jest/RTL, Go testing, pytest, モック戦略 | 実装 / high |
| 20 | タチコマ（E2Eテスト） | `tachikoma-e2e-test.toml` | Playwright, E2E, `playwright.config.*` | Playwright Test, POM, ビジュアルテスト, a11yテスト, CI/CD統合, Browser Agent CLI | 実装 / high |

### AI・オブザーバビリティ

| # | エージェント名 | ファイル | 検出条件 | 専門領域 | モード/effort |
|---|--------------|---------|---------|---------|-------|
| 21 | タチコマ（AI/ML） | `tachikoma-ai-ml.toml` | AI/RAG/MCP/LLM関連コード | Vercel AI SDK, LangChain.js, RAGシステム, MCP開発, promptfoo評価, LLMOps | 実装 / high |
| 22 | タチコマ（オブザーバビリティ） | `tachikoma-observability.toml` | `@opentelemetry/*`, `prometheus.yml` | 監視設計, OpenTelemetry計装, 構造化ログ, SLO/SLI, アラート設計 | 実装 / high |

### プロダクト・ドキュメント・研修

| # | エージェント名 | ファイル | 検出条件 | 専門領域 | モード/effort |
|---|--------------|---------|---------|---------|-------|
| 23 | タチコマ（プロダクトマネジメント） | `tachikoma-product-manager.toml` | PRD作成/ロードマップ/優先順位付け/A/Bテスト設計 | PRD, ロードマップ, 優先順位付け(RICE/ICE), A/Bテスト設計, 成長メトリクス, AIプロダクト成熟度評価 | **docs作成のみ** / xhigh |
| 24 | タチコマ（ドキュメント） | `tachikoma-document.toml` | 技術文書/記事/LaTeX | 文章基礎(7Cs), AI臭検出・除去, LaTeX, Zenn記事, コピーライティング | **コード非記述** / high |
| 25 | タチコマ（スライド） | `tachikoma-slide.toml` | HTMLスライドデッキ作成/ソース素材→スライド変換 | slides repo 3層分離モデル(Engine/Theme/Content), テーマカスタマイズ, ソース素材変換 | **コード非記述** / xhigh |
| 26 | タチコマ（研修・プレゼン） | `tachikoma-training-presenter.toml` | 研修設計/プレゼン改善/ワークショップ | ニーズ分析, インストラクショナルデザイン, 行動変容(CREATE), ストーリー構成, PUNCH原則 | **コード非記述**（自己進化型） / high |

### 汎用・特殊

| # | エージェント名 | ファイル | 検出条件 | 専門領域 | モード/effort |
|---|--------------|---------|---------|---------|-------|
| 27 | タチコマ（汎用） | `tachikoma.toml` | 上記以外すべて | 専門タチコマでカバーされない汎用タスク・複数ドメイン横断 | 実装 / high |
| 28 | Serena Expert | `serena-expert.toml` | `/serena` コマンド使用時 | トークン効率的な開発全般（Component/API/Test/System） | 実装 / high |

---

## ルーティング判断のポイント

- **デザイン3体 vs フロントエンド**: Figma→コード変換・Code Connect・トークン同期・Tailwind実装 → Figma実装(`tachikoma-figma-impl`)。DS構築・パターンライブラリ・ガバナンス・Figma変数管理 → デザインシステム(`tachikoma-design-system`)。UX戦略・デザイン思考・グラフィック・AI体験設計 → UXデザイン(`tachikoma-ux-design`)。shadcn/ui実装・Storybook・データビジュアライゼーション → フロントエンド(`tachikoma-frontend`)
- **タチコマ（テスト） vs 言語別タチコマ**: テスト設計・カバレッジ改善・TDD・テストリファクタリングが主題 → テスト。機能実装の一部としてテストも書く → 言語別タチコマ
- **複数の検出条件に該当** → より専門的な方を優先（例: Next.js + UI → Next.js をメイン、フロントエンドをサブ）
- **並列実行** → 異なる専門タチコマを同時起動可能（例: Next.js + E2Eテスト）。同一タチコマの複数起動も可能
- **読取専用エージェント**（アーキテクチャ・セキュリティ・コードレビュー）→ 設計ドキュメント・レポートのみ出力。実装コードは書かない。プロダクトマネジメント(`tachikoma-product-manager`)は PRD/docs のみ作成
- **スキルの呼び出し**: 各エージェントは developer_instructions 末尾の「活用スキル」に列挙されたスキル群を、プラグイン(devkit@sumik-marketplace)経由で description 自動ロードする（手動の skills.config 登録は不要）

## 共通仕様

すべてのタチコマは以下の共通仕様に従います:

- **言語**: 日本語で応答（技術用語を除く）
- **バージョン管理**: Git 使用
- **コミット**: Conventional Commits形式
- **品質**: SOLID原則・型安全性（any禁止）・テスト（AAAパターン）・セキュリティチェック（実装完了後に `software-security` スキルをロード）
- **報告**: 完了報告は【完了報告】フォーマットでCodex本体に送信
- **並列実行**: `docs/plan-xxx.md` の担当セクションを正式な仕様書として参照

---

## 🧠 継続的学習（capturing-learnings・常時オン）

作業中に得た学び・エラー・ユーザー訂正・機能要望を `.learnings/` に構造化記録し、継続的改善につなげる。**Codex は `[features] hooks = true` ＋ plugin hook の trust 承認で devkit 同梱の hook（`hooks-codex.json`）が有効化され、Claude Code 同様 UserPromptSubmit/PostToolUse で自動リマインドする**（未有効時は本セクションの記述が always-on の主機構となる）。エントリ書式・ID規則・解決フローの詳細は `capturing-learnings` スキル本体を参照。

### 検出トリガー（If X then Y）

| If X（トリガー） | then Y（行動） |
|----------------|--------------|
| ユーザーが訂正・誤りを指摘（「いや違う」「正しくは…」「それは古い」） | `.learnings/LEARNINGS.md` に `correction` で記録 |
| 知らなかった情報の提供／参照ドキュメントが古い／APIの挙動が想定と異なる | `.learnings/LEARNINGS.md` に `knowledge_gap` で記録 |
| 非自明なエラーを調査して解決（再発しうる） | `.learnings/ERRORS.md` に `[ERR-YYYYMMDD-XXX]` で記録 |
| 存在しない機能を要望された（「〜もできる?」「〜できたらいいのに」） | `.learnings/FEATURE_REQUESTS.md` に記録 |
| 反復タスクでより良い方法を発見 | `.learnings/LEARNINGS.md` に `best_practice` で記録 |
| 大きな作業を始める前 | `.learnings/` を振り返り関連する過去の学びを確認 |

### 昇格・ルーティング

| 学びの性質 | 行き先 |
|-----------|--------|
| 一過性・そのプロジェクト限定 | `.learnings/`（留置） |
| プロジェクト固有の事実・規約・落とし穴 | そのプロジェクトの `CLAUDE.md` / `AGENTS.md` |
| ユーザー横断・複数セッションに渡る事実 | グローバル `~/dotfiles/codex/AGENTS.md`（Codex は memory システムを持たないため AGENTS.md に集約） |
| **sumik-claude-plugin 自身のスキル改善** | 下記「📥 スキル改善提案 (inbox)」へ（`.learnings/` ではない） |
| 汎用で再利用価値が高い | `authoring-plugins` で新スキル抽出を検討 |

反復パターンの昇格条件: Recurrence-Count ≥ 3 ∧ 2タスク以上で観測 ∧ 30日以内。昇格文は「コーディング前/中に何をすべきか」の短い予防ルールで書く。

### plugin hook（devkit 同梱・推奨）

`config.toml` の `[features]` に `hooks = true` を設定すると（旧 `codex_hooks` は deprecated alias）、devkit が同梱する plugin hook（repo root の `hooks-codex.json`・`SessionStart`/`UserPromptSubmit`/`PreToolUse`/`PostToolUse`/`Stop`/`SubagentStop`/`PreCompact`）が有効化され、Claude Code と同一スクリプト（stdin JSON・`additionalContext` 出力）で learnings リマインド等が自動で効く。plugin 同梱 hook は「非管理 hook」のため、初回は Codex 起動時に trust 承認が必要（`.codex/hooks.json` への手動登録はもう不要）。Codex は `Notification`/`SessionEnd`/`TeammateIdle` を非対応のため、それらに紐づく通知・retrospective は Claude Code 専用。

---

## 📥 スキル改善提案 (inbox)

sumik-claude-plugin スキルの改善提案キュー（Codex 版）。捕捉(C)→消費(D=`authoring-plugins` の「🔄 改善提案INTAKE」)を繋ぐ。Claude Code 側の `~/.claude/CLAUDE.md` inbox と**対になる Codex 側 inbox** で、INTAKE は両方を走査する。**openのみ保持**し、消費後は削除（本ファイルを肥大させない）。フォーマット全仕様は `authoring-plugins/references/IMPROVEMENT-INTAKE.md §2`。

**捕捉ルール（発見時の振る舞い）**: sumik-claude-plugin スキルを読込/使用中に改善余地（description不正確・肥大・統合余地・知見追記漏れ・参照切れ・規約違反）を発見したら、**即編集せず**下記へ提案を1件追記する（軽微typoは即修正可）。①実際に読込/使用したスキルに限る（未読の推測提案禁止）②1スキル1セッション1件 ③確度=低は書かない ④具体的改善文/削除対象行を伴うもののみ（漠然とした感想不可）⑤作業主目的を中断せずタスク完了後に追記。

各提案は `### [PROPOSAL] <skill> / <種別> / <日付>` 見出し＋ skill・種別(description改善/分割/統合/内容追記/参照修正/規約違反)・改善点・理由(書籍名禁止)・確度(高/中)・影響範囲・status を箇条書きで持つ。

**発火**: open が3件以上、またはユーザーが「スキル改善まわして」と指示した時、`authoring-plugins` の INTAKE を起点に消費する。Codex のコミットも Git を使用（Conventional Commits 形式）。

<!-- open な提案をここに追記。処理後はドレイン。Claude Code 側で気づいた提案は ~/.claude/CLAUDE.md の inbox に入る。 -->

---

# MCP 利用ガイド（この環境で有効なサーバ）

この環境では、`devkit@sumik-marketplace`・`studio@sumik-marketplace` 同梱の `.mcp-codex.json` および別途導入したプラグインを通じて、以下の MCP サーバが有効です（末尾の `（プラグイン名）` は同梱元）。用途に応じて最適なサーバを選び、不要なときは呼び出さない方針とします。

## MCP とは
Model Context Protocol (MCP) は、LLM アプリケーションが外部ツールやデータソースと連携するためのオープンなプロトコルです。MCP サーバはツール群を提供し、クライアント（このエージェントなど）がそれらを呼び出します。

## 有効な MCP 一覧
- serena（devkit）
- fff（devkit）
- sequentialthinking（devkit）
- chrome-devtools（devkit）
- puppeteer（devkit）
- next-devtools
- context7
- drawio（studio）

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

## fff（高速ファイル検索）
**概要**
fff は Rust 製の常駐型ファイル検索エンジンです。warm cache とバックグラウンドのファイルシステム watcher により、ripgrep が数秒かかる大規模リポジトリでもミリ秒級で応答し、frecency（頻度・新しさ・git-dirty を加味）で結果を順位付けします。`devkit` プラグインがラッパー経由で同梱します。提供ツールは grep（内容検索・既定）/ find_files（ファイル名 fuzzy 検索）/ multi_grep（複数パターン OR 検索）の3つ。

**使う場面**
- コード内容のキーワード・識別子検索（最優先・最速）
- ファイル名で目的のファイルを探すとき（find_files）
- 命名規則違い（snake_case / PascalCase / camelCase）や複数識別子を一度に探すとき（multi_grep）

**使い方の要点**
- bare identifier 1つで検索する（例 `InProgressQuote`）。regex や複数トークンに跨るクエリは原則使わない（単一行マッチのため 0 件になりやすい）
- 制約はクエリにインライン前置（`*.rs query`・`src/ query`・`!tests/`）。multi_grep は `constraints` 引数に渡す
- grep は 2 回までで打ち切り、トップ結果を読む（grep 回数 ≠ 理解度）

**注意点**
- シンボル単位の意味的検索・参照検索・リネームは serena が適する（fff は「どこにあるか」を速く広く当てる用途）
- 起動時の作業ディレクトリをインデックスするため、対象プロジェクトのルートでクライアントを起動すること

**参考**
- README: `https://github.com/dmtrKovalenko/fff.nvim`
- 詳細スキル: `searching-files-with-fff`（devkit）

---

## sequentialthinking（段階的な思考・比較・分岐の支援）
**概要**
Sequential Thinking は、順序立った思考プロセスを支援する MCP サーバです。思考ステップを分割・修正・分岐しながら、複雑な問題を構造的に整理します。`devkit` プラグインが同梱します。

**使う場面**
- 複数案の比較、分岐検討、逆算、仮説検証が必要な設計検討
- 根拠を段階的に整理して結論を出したいとき
- 思考の途中で前提を見直し、ステップを巻き戻したいとき

**注意点**
- 単純な作業には過剰になりやすい

**参考**
- README: `https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking`

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

## puppeteer（ヘッドレスブラウザ自動操作）
**概要**
Puppeteer MCP は、ヘッドレス Chrome を通じてページ遷移・クリック・フォーム入力・スクリーンショット取得などのブラウザ操作を提供します。`devkit` プラグインが同梱します。

**使う場面**
- ページ遷移や DOM 操作を伴う自動化シナリオ
- スクリーンショット取得や簡易的な動作確認
- フォーム入力・要素選択などの定型ブラウザ操作

**注意点**
- 🔴 アプリの web 操作・ブラウザ自動化の第一選択は agent-browser CLI（`web:automating-browser` スキル）。Rust ネイティブ・CDP 直結で snapshot→ref・状態永続化・read/chat/batch/mcp をサポート。puppeteer はそれで代替できない場合のフォールバックに留める
- 詳細な性能トレースやネットワーク解析は chrome-devtools の方が適する
- ブラウザの内容が MCP クライアントに公開されるため、機密情報のあるページには注意

**参考**
- README: `https://github.com/modelcontextprotocol/servers/tree/main/src/puppeteer`

---

## drawio（ダイアグラム生成）
**概要**
drawio MCP は、XML・Mermaid・CSV などの記述から draw.io 形式の図を生成・編集するサーバです。`studio` プラグインが同梱します。

**使う場面**
- フローチャート・ER図・シーケンス図などのダイアグラム作成
- Mermaid 記法や CSV から draw.io 図への変換
- 設計ドキュメントへ添付する図の生成

**注意点**
- 図の生成・編集が主目的で、コード解析やブラウザ操作には用いない

**参考**
- README: `https://github.com/drawio/mcp`

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
- **設計の比較や深い思考**: sequentialthinking
- **Next.js の実行時診断**: next-devtools
- **ライブラリの最新ドキュメント**: context7
- **アプリのweb操作・ブラウザ自動化**: `web:automating-browser`（agent-browser CLI・🔴第一選択。スクレイピング/UI操作フロー/認証永続化/フォーム送信/データ抽出。未導入なら同スキルの `scripts/install.sh` で自動導入＝`agent-browser install` が Chrome for Testing を取得）
- **ブラウザ挙動/性能解析・Lighthouse**: chrome-devtools（診断補完）
- **上記で代替できない軽量ブラウザ操作/スクリーンショット**: puppeteer（フォールバック）
- **ダイアグラム生成**: drawio
