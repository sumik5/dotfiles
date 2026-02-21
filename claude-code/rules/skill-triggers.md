# スキルトリガーガイド

スキルは状況に応じて自動的に参照する。平坦な一覧ではなく、トリガー条件に基づいて適切なスキルを選択すること。

---

## 🔴 常時適用（全実装で必須）

以下のスキルはコード実装時に常に参照する:

| スキル | トリガー | 概要 |
|--------|---------|------|
| `writing-clean-code` | すべてのコード実装・レビュー時 | SOLID原則含むクリーンコード実践 |
| `enforcing-type-safety` | TypeScript/Python実装時 | any/Any禁止、型ガード |
| `testing-code` | 機能実装・バグ修正時 | TDD、テスト設計、Vitest/RTL/Playwright |
| `securing-code` | 🔴 **実装完了後に必ず実行** | CodeGuardセキュリティチェック |
| `removing-ai-smell` | すべてのテキスト出力時 | AI臭除去（コメント・文章の自然化） |
| `applying-semantic-versioning` | すべてのバージョン判断時 | SemVer 2.0.0仕様準拠のバージョン判定 |
| `writing-conventional-commits` | コミットメッセージ作成時 | Conventional Commits 1.0.0準拠フォーマット |

---

## 🟡 自動検出（ファイル・プロジェクト構成で発動）

プロジェクト内の特定ファイルを検出した場合、対応するスキルを自動参照する:

| 検出条件 | スキル | 概要 |
|---------|--------|------|
| `package.json` に `next` | `developing-nextjs` | Next.js 16 / React 19開発 |
| `package.json` に `next` | `using-next-devtools` | Next.js DevTools MCP活用 |
| `package.json` に `next` | `developing-react` | React Internals・パフォーマンス・アニメーション・RTL |
| `package.json` に `next` + stripe/auth系 | `building-nextjs-saas` | Next.js SaaSアプリケーション構築 |
| `package.json` に `react`（next無し） | `developing-react` | React 19.x 開発（Internals・パフォーマンス・アニメーション・RTL） |
| `package.json` に express/nestjs/fastify/koa/hapi | `developing-fullstack-javascript` | NestJS/Express フルスタックJS |
| `package.json` に `@playwright/test` | `testing-e2e-with-playwright` | Playwright E2Eテスト設計・実装 |
| `package.json` に `@opentelemetry/*` | `implementing-opentelemetry` | OpenTelemetry 分散トレーシング |
| `package.json` に `ai` (Vercel AI SDK) | `integrating-ai-web-apps` | Vercel AI SDK + LangChain.js WebアプリAI統合 |
| `package.json` に `@langchain/*` | `integrating-ai-web-apps` | Vercel AI SDK + LangChain.js WebアプリAI統合 |
| `tsconfig.json` 存在 | `mastering-typescript` | TypeScript型システム・パターン |
| `components.json` 存在 | `designing-frontend` | フロントエンドUI/UXコンポーネント |
| `.stories.tsx` / `.stories.ts` 存在 | `designing-frontend` | フロントエンドUI/UXコンポーネント |
| `playwright.config.*` 存在 | `testing-e2e-with-playwright` | Playwright E2Eテスト設計・実装 |
| `go.mod` 存在 | `developing-go` | Go開発ガイド |
| `go.mod` に `hashicorp/terraform` | `developing-terraform` | Terraform IaC開発 |
| `pyproject.toml` / `requirements.txt` 存在 | `developing-python` | Python開発ガイド |
| `.sh` ファイル存在 | `developing-bash` | Bash シェルスクリプティング・自動化 |
| Python依存に `google-adk` | `building-adk-agents` | Google ADK AIエージェント開発 |
| Python依存に `opentelemetry-*` | `implementing-opentelemetry` | OpenTelemetry 分散トレーシング |
| `.tf` ファイル存在 | `developing-terraform` | Terraform IaC開発 |
| `Dockerfile` / `docker-compose.*` 存在 | `managing-docker` | Docker開発環境・コンテナ管理 |
| `cloudbuild.yaml` / `.gcloudignore` 存在 | `developing-google-cloud` | Google Cloud 開発（Cloud Run + セキュリティ + サービス選定 + アプリアーキテクチャ） |
| `.tex` ファイル存在 | `writing-latex` | LaTeX文書作成（日本語対応） |
| `.tex` ファイル存在 | WRITING_SKILLS グループ | writing-technical-docs, writing-academic-papers, searching-web も有効化 |
| `components.json` / `.stories.*` / `tailwind.config.*` 存在 | DESIGN_SKILLS グループ | applying-design-guidelines, applying-behavior-design, implementing-design |
| `schema.prisma` / `.sql` / DB系パッケージ | DATABASE_SKILLS グループ | avoiding-sql-antipatterns, understanding-database-internals, designing-relational-databases |
| `@opentelemetry/*` / `prometheus.yml` | OBSERVABILITY_SKILLS グループ | designing-monitoring |
| `@modelcontextprotocol/sdk` / `fastmcp` | MCP_DEV_SKILLS グループ | developing-mcp |
| `*.cedar` ファイル存在 | `implementing-dynamic-authorization` | Cedar/ABAC/ReBAC 動的認可 |
| `cdk.json` / `samconfig.toml` / `serverless.yml` / `template.yaml` 存在 | `developing-aws` | AWS開発（システム設計・サーバーレス・CDK・EKS・SRE・コスト最適化・セキュリティ・Bedrock・DB・データエンジニアリング・SageMaker・CI/CD・SysOps） |
| `package.json` に `@aws-sdk/*` / `aws-cdk` | `developing-aws` | AWS開発 |
| Python依存に `boto3` / `aws-cdk-lib` | `developing-aws` | AWS開発 |
| `buildspec.yml` 存在 | `developing-aws` | AWS開発 |

---

## 🟢 言語別スキルグループ

特定言語で作業する際、関連スキルをセットで参照する:

### Go
| スキル | 役割 |
|--------|------|
| `developing-go` | 言語基礎・デザインパターン・内部構造（統合済み） |

### TypeScript
| スキル | 役割 |
|--------|------|
| `mastering-typescript` | 言語機能・型システム・ベストプラクティス（統合済み） |
| `enforcing-type-safety` | 型安全性の強制ルール |

### Python
| スキル | 役割 |
|--------|------|
| `developing-python` | プロジェクト環境・Pythonicコード（統合済み） |

### React / Next.js
| スキル | 役割 |
|--------|------|
| `developing-react` | React 19.x（Internals・パフォーマンス・アニメーション・RTL） |
| `developing-nextjs` | Next.js 16.x（App Router・Server Components）。React固有は developing-react |
| `using-next-devtools` | Next.js DevTools MCP |

### フルスタック JavaScript
| スキル | 役割 |
|--------|------|
| `developing-fullstack-javascript` | NestJS/Express バックエンド + React フロントエンド |

---

## 🔵 スキルグループ（自動検出連携）

`detect-project-skills.sh` がファイル構成から検出するスキルグループ。個別スキルに加え、関連スキルをまとめて推奨する:

### ✏️ Writing Skills (.tex 検出時)
| スキル | 役割 |
|--------|------|
| `writing-latex` | LaTeX文書作成 |
| `writing-technical-docs` | 技術ドキュメント（7Cs原則） |
| `writing-academic-papers` | アカデミックライティング（エッセイ・論文・Harvard参照） |
| `searching-web` | Web検索（gemini CLI） |

### 🎨 Design Skills (フロントエンド/デザイン検出時)
| スキル | 役割 |
|--------|------|
| `applying-design-guidelines` | UI/UX設計原則（理論） |
| `applying-behavior-design` | 行動変容デザイン |
| `implementing-design` | Figmaデザイン→コード |

### 🗄️ Database Skills (DB関連検出時)
| スキル | 役割 |
|--------|------|
| `avoiding-sql-antipatterns` | SQLアンチパターン回避 |
| `understanding-database-internals` | DB内部構造・分散システム |
| `designing-relational-databases` | リレーショナルDB設計・PostgreSQL実装 |

### 📊 Observability Skills (監視・可観測性検出時)
| スキル | 役割 |
|--------|------|
| `designing-monitoring` | 監視・オブザーバビリティ設計 |

### 🔌 MCP Dev Skills (MCP開発検出時)
| スキル | 役割 |
|--------|------|
| `developing-mcp` | MCP開発ガイド |

---

## 🔵 オンデマンド（状況・ユーザー要求で発動）

### 実装前（必須）
| トリガー | スキル | 概要 |
|---------|--------|------|
| 新機能実装前 | `researching-libraries` | 既存ライブラリ調査（車輪の再発明禁止） |
| アプリケーションログ設計・構造化ログ実装 | `implementing-logging` | ログ設計原則・構造化ログ・収集パイプライン・分析・セキュリティ・AI分析 |

### デザイン・フロントエンド
| トリガー | スキル | 概要 |
|---------|--------|------|
| UI/UXデザイン判断 | `applying-design-guidelines` | 設計原則（理論） |
| UIコンポーネント実装 | `designing-frontend` | フロントエンドコード生成 |
| Figma URL・デザイン実装依頼 | `implementing-design` | Figma→コード変換 |

### API・アーキテクチャ
| トリガー | スキル | 概要 |
|---------|--------|------|
| REST API設計 | `designing-web-apis` | API設計ベストプラクティス |
| レガシーシステム刷新・トレードオフ分析 | `modernizing-architecture` | 社会技術的アーキテクチャ・トレードオフ分析手法 |
| マイクロサービス設計・粒度判断 | `architecting-microservices` | CQRS/Saga/粒度決定/データ所有権/ワークフロー |
| ドメイン境界設計・データ分解 | `applying-domain-driven-design` | DDD戦略/戦術パターン・データ分解・データメッシュ |
| マルチテナントSaaS | `building-multi-tenant-saas` | SaaSアーキテクチャ |
| 認可・アクセス制御設計 | `implementing-dynamic-authorization` | ABAC/ReBAC/Cedar |
| LLMアプリ本番運用・LLMOpsパイプライン構築 | `practicing-llmops` | LLMOps運用フレームワーク（データ・モデル適応・API・評価・セキュリティ・スケーリング） |

### セキュリティ
| トリガー | スキル | 概要 |
|---------|--------|------|
| サーバーレスアプリのセキュリティ設計・脆弱性調査 | `securing-serverless` | AWS Lambda・Cloud Run・Azure Functionsの攻撃・防御パターン（IAM・ストレージ・コード注入・権限昇格） |

### インフラ・DevOps
| トリガー | スキル | 概要 |
|---------|--------|------|
| インフラ設計・IaC・CI/CDパイプライン構築 | `practicing-devops` | DevOps進化ステージ・IaCツール選定・オーケストレーション比較 |
| Feature Toggle戦略・CD導入・デプロイとリリース分離 | `practicing-continuous-deployment` | Feature Toggles・Expand/Contract・垂直スライシング・カナリアリリース |

### 監視・オブザーバビリティ
| トリガー | スキル | 概要 |
|---------|--------|------|
| 監視システム設計・SLO設計・アラート設計 | `designing-monitoring` | 監視デザインパターン・オブザーバビリティ・SLO・サンプリング・成熟度モデル |
| 分散システム可観測性・OTel計装 | `implementing-opentelemetry` | OpenTelemetry SDK/API実装 |
| アプリケーションログ設計・構造化ログ実装 | `implementing-logging` | ログ設計原則・構造化ログ・収集パイプライン・分析・セキュリティログ・AI/MLログ分析 |

### ブラウザ自動化
| トリガー | スキル | 概要 |
|---------|--------|------|
| ブラウザ操作自動化（スクレイピング等） | `automating-browser` | Browser Agent CLIによるブラウザ操作（セマンティックロケーター・状態永続化） |
| E2Eテスト設計・実装 | `testing-e2e-with-playwright` | Playwright Testによる包括的E2Eテスト（ロケーター・フィクスチャ・モッキング・CI/CD・アクセシビリティ等） |

### ドキュメント・品質
| トリガー | スキル | 概要 |
|---------|--------|------|
| 技術文書作成 | `writing-technical-docs` | 7つのC原則 |
| アカデミック文書作成 | `writing-academic-papers` | エッセイ・論文・dissertation・Harvard参照 |
| コードレビュー依頼 | `reviewing-with-coderabbit` | CodeRabbit AI レビュー |
| Web検索・情報収集 | `searching-web` | gemini CLI 検索 |

### CLAUDE.md管理（生きたドキュメント運用）
| トリガー | スキル | 概要 |
|---------|--------|------|
| Claudeが同じミスを繰り返した時 | `managing-claude-md` | If X then Y形式で罠を追記 |
| ユーザーがClaudeの行動を訂正した時 | `managing-claude-md` | 訂正内容を長期記憶に記録 |
| プロジェクト固有の暗黙知を発見した時 | `managing-claude-md` | CLAUDE.mdへの追記提案 |
| 同じ説明をセッション内で2回以上した時 | `managing-claude-md` | チャット→長期記憶への移動 |
| CLAUDE.md改善・リファクタリング時 | `managing-claude-md` | 8原則に基づく改善（300行以下、段階的開示等） |

### ツール・効率化
| トリガー | スキル | 概要 |
|---------|--------|------|
| 複数ファイル・複数関心事の並列開発 | `orchestrating-teams` | Agent Team編成・タチコマ並列起動・進捗管理 |
| `/serena` コマンド使用 | `using-serena` | Serena MCP構造化開発 |
| タチコマとして動作 | `implementing-as-tachikoma` | タチコマ Agent運用 |
| 新しいスキル作成 | `authoring-skills` | スキル作成ガイド |
