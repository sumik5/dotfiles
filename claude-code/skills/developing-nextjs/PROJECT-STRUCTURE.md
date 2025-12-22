# Next.js 16 Project Structure

## 推奨プロジェクト構造

```
project-root/
├── prisma/                    # Prisma ORM設定
│   ├── schema.prisma          # データベーススキーマ定義
│   └── migrations/            # マイグレーション履歴
├── public/                    # 静的アセット
│   ├── mockServiceWorker.js   # MSWワーカー（開発環境のみ）
│   └── images/                # 画像ファイル
├── src/
│   ├── actions/               # Server Actions（サーバーサイドロジック）
│   │   └── [domain]/          # ドメイン別（例: project/, auth/）
│   │       └── action.ts
│   ├── app/                   # Next.js App Router
│   │   ├── api/               # API Routes
│   │   │   └── [endpoint]/
│   │   │       └── route.ts
│   │   ├── [feature]/         # 機能別ページ
│   │   │   ├── page.tsx       # ページコンポーネント
│   │   │   ├── layout.tsx     # レイアウトコンポーネント
│   │   │   ├── loading.tsx    # ローディング状態
│   │   │   ├── error.tsx      # エラーハンドリング
│   │   │   └── not-found.tsx  # 404ページ
│   │   ├── layout.tsx         # ルートレイアウト
│   │   ├── page.tsx           # ホームページ
│   │   └── globals.css        # グローバルCSS（Tailwind含む）
│   ├── components/            # Reactコンポーネント
│   │   ├── ui/                # shadcn/ui基本コンポーネント（自動生成）
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   └── ...
│   │   ├── common/            # 共通コンポーネント（再利用可能）
│   │   │   ├── auth/          # 認証関連
│   │   │   ├── base/          # 基本レイアウト（Header, Footer等）
│   │   │   ├── form/          # フォーム部品
│   │   │   └── layout/        # レイアウト部品
│   │   └── pages/             # ページ専用コンポーネント（再利用しない）
│   │       └── [feature]/
│   │           └── Component.tsx
│   ├── hooks/                 # カスタムフック
│   │   └── useFeature.ts
│   ├── lib/                   # ユーティリティとライブラリ設定
│   │   ├── auth.ts            # 認証ヘルパー
│   │   ├── logger.ts          # ロギングシステム
│   │   ├── prisma.ts          # Prismaクライアント
│   │   ├── env.ts             # 環境変数管理（型安全）
│   │   └── utils.ts           # ユーティリティ関数
│   ├── mocks/                 # MSWモックハンドラー
│   │   ├── handlers/          # APIモックハンドラー
│   │   └── browser.ts         # ブラウザMSW設定
│   ├── types/                 # TypeScript型定義
│   │   ├── api/               # API型
│   │   ├── forms/             # フォーム型
│   │   └── models/            # データモデル型
│   ├── test/                  # テストユーティリティ
│   │   └── setup.ts           # Vitestセットアップ
│   └── instrumentation.ts     # Next.js起動時初期化（Prismaマイグレーション等）
├── .mise.toml                 # miseツール設定（推奨）
├── components.json            # shadcn/ui設定
├── docker-compose.yml         # Docker Compose（開発環境）
├── Dockerfile                 # マルチステージビルド
├── eslint.config.mjs          # ESLint設定（Flat Config）
├── next.config.js             # Next.js設定
├── package.json               # npm依存関係
├── tsconfig.json              # TypeScript設定
├── tailwind.config.js         # Tailwind CSS設定
├── vitest.config.mts          # Vitestテスト設定
└── .env.example               # 環境変数テンプレート
```

## フォルダ構成の原則

### 1. App Router（`src/app/`）

**ルールと命名規則：**
- **ページファイル**: `page.tsx`（必須、デフォルトでServer Component）
- **レイアウト**: `layout.tsx`（共通レイアウト、ネスト可能）
- **ローディング**: `loading.tsx`（Suspense境界）
- **エラーハンドリング**: `error.tsx`（Error Boundary）
- **Not Found**: `not-found.tsx`（404ページ）

**例：ダッシュボード機能**
```
src/app/dashboard/
├── page.tsx              # /dashboard
├── layout.tsx            # ダッシュボード共通レイアウト
├── loading.tsx           # ローディング状態
├── stats/
│   └── page.tsx          # /dashboard/stats
└── settings/
    └── page.tsx          # /dashboard/settings
```

**動的ルーティング:**
```
src/app/projects/
├── page.tsx              # /projects（一覧）
└── [id]/
    ├── page.tsx          # /projects/123
    └── edit/
        └── page.tsx      # /projects/123/edit
```

### 2. Server Actions（`src/actions/`）

**ドメイン駆動設計に基づく構成：**
```
src/actions/
├── project/              # プロジェクト関連アクション
│   ├── setup.ts          # export async function setupProject()
│   ├── update.ts         # export async function updateProject()
│   └── types.ts          # アクション固有の型定義
├── auth/                 # 認証関連アクション
│   └── login.ts
└── user/                 # ユーザー関連アクション
    └── profile.ts
```

**重要な規則：**
- **`"use server"`ディレクティブ**: ファイル先頭に必須
- **非同期関数**: すべてのアクションは`async`
- **型安全な入力**: Zodスキーマでバリデーション
- **エラーハンドリング**: `try-catch`で適切にエラー処理

### 3. コンポーネント（`src/components/`）

**3層構造：**

#### 3.1 UI基本コンポーネント（`src/components/ui/`）
- **shadcn/ui自動生成ファイル**
- **直接編集禁止**（再生成時に上書きされる）
- **例**: button.tsx, card.tsx, dialog.tsx

#### 3.2 共通コンポーネント（`src/components/common/`）
- **複数ページで再利用可能**
- **サブカテゴリ別に分類**:
  - `auth/`: 認証関連（LoginForm, SignupFormなど）
  - `base/`: 基本レイアウト（Header, Footer, Navigationなど）
  - `form/`: フォーム部品（FormInput, FormSelect、カスタムバリデーション等）
  - `layout/`: レイアウト部品（Sidebar, ContentWrapper等）

**例:**
```
src/components/common/
├── auth/
│   ├── LoginForm.tsx
│   └── ProtectedRoute.tsx
├── base/
│   ├── Header.tsx
│   ├── Footer.tsx
│   └── Navigation.tsx
└── form/
    ├── FormInput.tsx
    ├── FormSelect.tsx
    └── FormDatePicker.tsx
```

#### 3.3 ページ専用コンポーネント（`src/components/pages/`）
- **特定ページでのみ使用**
- **再利用を想定しない**
- **ページと同じ構造で配置**

**例:**
```
src/components/pages/
├── dashboard/
│   ├── Dashboard.tsx          # ダッシュボードメインコンポーネント
│   ├── StatsCard.tsx          # ダッシュボード専用カード
│   └── ActivityLog.tsx        # アクティビティログ表示
└── projects/
    ├── ProjectList.tsx        # プロジェクト一覧専用
    └── ProjectDetail.tsx      # プロジェクト詳細専用
```

**対応するページとの関係:**
```
src/app/dashboard/page.tsx → src/components/pages/dashboard/Dashboard.tsx
src/app/projects/page.tsx  → src/components/pages/projects/ProjectList.tsx
```

### 4. ライブラリ（`src/lib/`）

**ユーティリティと設定ファイル：**
- **auth.ts**: 認証ヘルパー（requireAuth, getSession等）
- **logger.ts**: 統一ロギングシステム（環境別切り替え）
- **prisma.ts**: Prismaクライアント（シングルトン）
- **env.ts**: 環境変数管理（Zodで型安全バリデーション）
- **utils.ts**: 汎用ユーティリティ（日付フォーマット、文字列操作等）

**例：env.tsでの環境変数管理**
```typescript
// src/lib/env.ts
import { z } from "zod";

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  NEXTAUTH_SECRET: z.string().min(32),
  NODE_ENV: z.enum(["development", "production", "test"]),
});

export const env = envSchema.parse(process.env);
```

### 5. 型定義（`src/types/`）

**カテゴリ別に分類：**
- **api/**: API型（リクエスト・レスポンス）
- **forms/**: フォーム型（React Hook Form + Zod）
- **models/**: データモデル型（Prismaと連携）

**例:**
```
src/types/
├── api/
│   ├── user.d.ts          # export type UserResponse = { ... }
│   └── project.d.ts
├── forms/
│   ├── login.d.ts         # export type LoginFormData = { ... }
│   └── signup.d.ts
└── models/
    └── prisma.d.ts        # Prisma型の拡張
```

### 6. テスト（`src/test/`、`src/**/*.test.tsx`）

**テストファイル配置：**
- **ユニットテスト**: 対象ファイルと同じディレクトリに配置
- **セットアップファイル**: `src/test/setup.ts`

**例:**
```
src/lib/
├── logger.ts
└── logger.test.ts         # ユニットテスト

src/components/ui/
├── Button.tsx
└── Button.test.tsx        # コンポーネントテスト
```

## 命名規則

### ファイル名

| 種類 | 形式 | 例 |
|------|------|-----|
| ページ（Next.js） | `page.tsx` | `src/app/dashboard/page.tsx` |
| レイアウト | `layout.tsx` | `src/app/layout.tsx` |
| コンポーネント | `PascalCase.tsx` | `UserCard.tsx`, `LoginForm.tsx` |
| ユーティリティ | `camelCase.ts` | `logger.ts`, `auth.ts` |
| テストファイル | `対象.test.tsx` | `Button.test.tsx`, `logger.test.ts` |
| 型定義 | `camelCase.d.ts` | `next-auth.d.ts`, `user.d.ts` |

### 変数・関数

```typescript
// 変数: camelCase
const userName = "John";
const isActive = true;

// 定数（特に環境変数）: UPPER_SNAKE_CASE
const API_BASE_URL = "https://api.example.com";
const MAX_RETRY_COUNT = 3;

// 関数: camelCase（動詞から始める）
function getUserById(id: string) {}
async function fetchProjectData() {}

// コンポーネント: PascalCase
function UserProfile() {}
function DashboardLayout() {}

// カスタムフック: "use"プレフィックス
function useAuth() {}
function useProjectInfo() {}

// 型・インターフェース: PascalCase
type User = {};
interface ProjectConfig {}
```

## Git管理とデプロイ

### 無視すべきファイル（.gitignore）

```gitignore
# Next.js
.next/
out/

# 依存関係
node_modules/

# 環境変数（本番用のみ）
.env.local
.env.production

# テスト・カバレッジ
coverage/

# ログ
*.log

# OS固有
.DS_Store

# IDEやエディタ
.vscode/
.idea/

# Git worktree
wt-*/
```

### 環境変数管理

- **`.env.example`**: テンプレート（コミット可能）
- **`.env`**: 開発環境用（Git無視）
- **`.env.production`**: 本番環境用（Git無視、デプロイ時に設定）

## ベストプラクティス

### 1. ディレクトリ構造の一貫性

- **同じ種類のファイルは同じ場所に配置**
- **深すぎるネストは避ける**（最大3-4階層）
- **関連ファイルはまとめる**（例：ComponentとComponentTestは同じディレクトリ）

### 2. コロケーション原則

**関連するファイルを近くに配置：**
```
src/actions/project/
├── setup.ts           # Server Action
├── setup.test.ts      # テスト
└── types.ts           # 型定義
```

### 3. 拡張性を考慮した設計

**新機能追加時に構造を壊さない：**
- 新しいドメインは`src/actions/[domain]/`に追加
- 新しいページは`src/app/[feature]/`に追加
- 共通コンポーネントは`src/components/common/`に追加

### 4. ドキュメント化

**各主要ディレクトリにREADME.mdを配置（推奨）：**
```
src/actions/README.md
src/components/README.md
src/lib/README.md
```

## 参考資料

- **Next.js公式**: App Routerディレクトリ構造 - https://nextjs.org/docs/app/getting-started/project-structure
- **React公式**: コンポーネント設計 - https://react.dev
- **Prisma公式**: プロジェクト構造 - https://www.prisma.io/docs/orm/more/development-environment/project-structure

---

**関連ドキュメント:**
- [NEXTJS-GUIDE.md](./NEXTJS-GUIDE.md) - Next.js機能詳細
- [REACT-GUIDE.md](./REACT-GUIDE.md) - React 19新機能
- [TOOLING.md](./TOOLING.md) - 開発ツール設定
