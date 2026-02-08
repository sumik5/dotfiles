# スキルトリガーガイド

スキルは状況に応じて自動的に参照する。平坦な一覧ではなく、トリガー条件に基づいて適切なスキルを選択すること。

---

## 🔴 常時適用（全実装で必須）

以下のスキルはコード実装時に常に参照する:

| スキル | トリガー | 概要 |
|--------|---------|------|
| `applying-solid-principles` | すべてのコード実装・レビュー時 | SOLID原則とクリーンコード |
| `enforcing-type-safety` | TypeScript/Python実装時 | any/Any禁止、型ガード |
| `testing` | 機能実装・バグ修正時 | TDD、Vitest/RTL/Playwright |
| `securing-code` | 🔴 **実装完了後に必ず実行** | CodeGuardセキュリティチェック |

---

## 🟡 自動検出（ファイル・プロジェクト構成で発動）

プロジェクト内の特定ファイルを検出した場合、対応するスキルを自動参照する:

| 検出条件 | スキル | 概要 |
|---------|--------|------|
| `package.json` に `next` | `developing-nextjs` | Next.js 16 / React 19 開発 |
| `package.json` に `next` | `using-next-devtools` | Next.js DevTools MCP活用 |
| `package.json` に `react` | `react-best-practices` | React性能最適化（Vercel） |
| `components.json` 存在 | `using-shadcn` | shadcn/ui コンポーネント管理 |
| `.stories.tsx` / `.stories.ts` | `storybook-guidelines` | Storybook story作成 |
| `go.mod` 存在 | `developing-go` | Go開発ガイド |
| `pyproject.toml` / `requirements.txt` | `developing-python` | Python開発ガイド |
| `.tf` ファイル存在 | `developing-terraform` | Terraform IaC開発 |
| `Dockerfile` / `docker-compose.yml` | `managing-docker` | Docker開発環境 |
| `Dockerfile` 作成・編集時 | `writing-dockerfiles` | Dockerfile最適化 |
| `.tex` ファイル | `writing-latex` | LaTeX文書作成（日本語対応） |

---

## 🟢 言語別スキルグループ

特定言語で作業する際、関連スキルをセットで参照する:

### Go
| スキル | 役割 |
|--------|------|
| `developing-go` | 言語基礎・プロジェクト構造 |
| `writing-clean-go` | コード品質・リファクタリング |
| `applying-go-design-patterns` | デザインパターン・アーキテクチャ |
| `mastering-go-internals` | 内部構造・性能最適化（上級） |

### TypeScript
| スキル | 役割 |
|--------|------|
| `mastering-typescript` | 言語機能・型システム全体 |
| `writing-effective-typescript` | ベストプラクティス・判断基準 |
| `enforcing-type-safety` | 型安全性の強制ルール |

### Python
| スキル | 役割 |
|--------|------|
| `developing-python` | プロジェクト環境・ツール設定 |
| `writing-effective-python` | Pythonic なコード・125のベストプラクティス |

### React / Next.js
| スキル | 役割 |
|--------|------|
| `developing-nextjs` | Next.js フレームワーク全体 |
| `mastering-react-internals` | React内部構造・高度なパターン |
| `react-best-practices` | Vercel推奨の性能最適化 |
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
| UI/UXデザイン判断 | `design-guidelines` | 設計原則（理論） |
| UIコンポーネント実装 | `designing-frontend` | フロントエンドコード生成 |
| Figma URL・デザイン実装依頼 | `implement-design` | Figma→コード変換 |

### API・アーキテクチャ
| トリガー | スキル | 概要 |
|---------|--------|------|
| REST API設計 | `designing-web-apis` | API設計ベストプラクティス |
| レガシーシステム刷新 | `modernizing-architecture` | 社会技術的アーキテクチャ |
| マルチテナントSaaS | `building-multi-tenant-saas` | SaaSアーキテクチャ |
| 認可・アクセス制御設計 | `implementing-dynamic-authorization` | ABAC/ReBAC/Cedar |
| 分散システム可観測性 | `implementing-opentelemetry` | OpenTelemetry実装 |

### ブラウザ自動化
| トリガー | スキル | 概要 |
|---------|--------|------|
| 簡単なブラウザ操作 | `playwright` | 軽量ブラウザ自動化（Playwright MCP） |
| 複雑なブラウザ操作（状態管理・ネットワーク傍受等） | `agent-browser` | 高機能ブラウザ自動化 |
| E2Eテスト設計・実装 | `mastering-playwright-testing` | Playwright Test E2E |

### ドキュメント・品質
| トリガー | スキル | 概要 |
|---------|--------|------|
| 技術文書作成 | `writing-technical-docs` | 7つのC原則 |
| コードレビュー依頼 | `coderabbit` | CodeRabbit AI レビュー |
| Web検索・情報収集 | `searching-web` | gemini CLI 検索 |

### ツール・効率化
| トリガー | スキル | 概要 |
|---------|--------|------|
| `/serena` コマンド使用 | `using-serena` | Serena MCP構造化開発 |
| タチコマとして動作 | `implementing-as-tachikoma` | タチコマ Agent運用 |
| 新しいスキル作成 | `authoring-skills` | スキル作成ガイド |
| Markdownからスキル変換 | `converting-markdown-to-skill` | Markdown→Skill変換 |
