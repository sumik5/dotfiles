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

---

## 🟡 自動検出（ファイル・プロジェクト構成で発動）

プロジェクト内の特定ファイルを検出した場合、対応するスキルを自動参照する:

| 検出条件 | スキル | 概要 |
|---------|--------|------|
| `package.json` に `next` | `developing-nextjs` | Next.js 16 / React 19開発 |
| `package.json` に `next` | `using-next-devtools` | Next.js DevTools MCP活用 |
| `package.json` に `next` + stripe/auth系 | `building-nextjs-saas` | Next.js SaaSアプリケーション構築 |
| `package.json` に `react`（next無し） | `developing-nextjs` | React Internals/Performance統合済み |
| `package.json` に express/nestjs/fastify/koa/hapi | `developing-fullstack-javascript` | NestJS/Express フルスタックJS |
| `package.json` に `@playwright/test` | `automating-browser` | Playwright ブラウザ自動化・E2Eテスト |
| `package.json` に `@opentelemetry/*` | `implementing-opentelemetry` | OpenTelemetry 分散トレーシング |
| `tsconfig.json` 存在 | `mastering-typescript` | TypeScript型システム・パターン |
| `components.json` 存在 | `designing-frontend` | フロントエンドUI/UXコンポーネント |
| `.stories.tsx` / `.stories.ts` 存在 | `designing-frontend` | フロントエンドUI/UXコンポーネント |
| `playwright.config.*` 存在 | `automating-browser` | Playwright ブラウザ自動化・E2Eテスト |
| `go.mod` 存在 | `developing-go` | Go開発ガイド |
| `go.mod` に `hashicorp/terraform` | `developing-terraform` | Terraform IaC開発 |
| `pyproject.toml` / `requirements.txt` 存在 | `developing-python` | Python開発ガイド |
| Python依存に `google-adk` | `building-adk-agents` | Google ADK AIエージェント開発 |
| Python依存に `opentelemetry-*` | `implementing-opentelemetry` | OpenTelemetry 分散トレーシング |
| `.tf` ファイル存在 | `developing-terraform` | Terraform IaC開発 |
| `Dockerfile` / `docker-compose.*` 存在 | `managing-docker` | Docker開発環境・コンテナ管理 |
| `.tex` ファイル存在 | `writing-latex` | LaTeX文書作成（日本語対応） |
| `*.cedar` ファイル存在 | `implementing-dynamic-authorization` | Cedar/ABAC/ReBAC 動的認可 |

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
| `developing-nextjs` | Next.js + React Internals + Performance（統合済み） |
| `using-next-devtools` | Next.js DevTools MCP |

### フルスタック JavaScript
| スキル | 役割 |
|--------|------|
| `developing-fullstack-javascript` | NestJS/Express バックエンド + React フロントエンド |

---

## 🔵 オンデマンド（状況・ユーザー要求で発動）

### 実装前（必須）
| トリガー | スキル | 概要 |
|---------|--------|------|
| 新機能実装前 | `researching-libraries` | 既存ライブラリ調査（車輪の再発明禁止） |

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
| 分散システム可観測性 | `implementing-opentelemetry` | OpenTelemetry実装 |

### ブラウザ自動化
| トリガー | スキル | 概要 |
|---------|--------|------|
| ブラウザ操作・E2Eテスト | `automating-browser` | Playwright MCP・Agent・E2Eテスト（統合済み） |

### ドキュメント・品質
| トリガー | スキル | 概要 |
|---------|--------|------|
| 技術文書作成 | `writing-technical-docs` | 7つのC原則 |
| コードレビュー依頼 | `reviewing-with-coderabbit` | CodeRabbit AI レビュー |
| Web検索・情報収集 | `searching-web` | gemini CLI 検索 |

### ツール・効率化
| トリガー | スキル | 概要 |
|---------|--------|------|
| `/serena` コマンド使用 | `using-serena` | Serena MCP構造化開発 |
| タチコマとして動作 | `implementing-as-tachikoma` | タチコマ Agent運用 |
| 新しいスキル作成 | `authoring-skills` | スキル作成ガイド |
