# 開発ツール設定ガイド

## mise（ツールバージョン管理）

### 概要

miseは、Node.js、pnpm、pre-commit等のツールバージョンを統一管理するツールです（asdf、rtxの代替）。

### インストール

```bash
# macOS
brew install mise

# Linux
curl https://mise.run | sh

# Windows
# https://mise.jdx.dev/getting-started.html#installation を参照
```

### 設定ファイル

**.mise.toml（プロジェクトルート）:**
```toml
# mise configuration
# https://mise.jdx.dev/configuration.html

[tools]
node = "24.5.0"
pnpm = "10.14.0"
pre-commit = "latest"

# 環境変数
[env]
_.file = ".env"

# タスク定義
[tasks.install]
description = "依存関係のインストール"
run = ["pnpm install"]

[tasks.dev]
description = "Next.js開発サーバーの起動"
run = "pnpm dev"

[tasks.build]
description = "Next.jsアプリケーションのビルド"
run = "pnpm build"

[tasks.test]
description = "Vitestでテストを実行"
run = "pnpm test"

[tasks."test:coverage"]
description = "テストカバレッジレポートの生成"
run = "pnpm coverage"

[tasks.lint]
description = "ESLintの実行"
run = "pnpm lint"

[tasks.format]
description = "Prettierでコードをフォーマット"
run = "pnpm fmt"

[tasks."check-app"]
description = "すべてのチェックを実行（lint, format, test）"
run = [
  "SKIP_ENV_VALIDATION=true pnpm build || true",
  "pnpm lint",
  "pnpm fmt",
  "pnpm test"
]

# Docker tasks
[tasks."docker:up"]
description = "Dockerコンテナの起動（PostgreSQL + Keycloak）"
run = "docker-compose up -d"

[tasks."docker:down"]
description = "Dockerコンテナの停止"
run = "docker-compose down"

[tasks."docker:logs"]
description = "Dockerコンテナのログを表示"
run = "docker-compose logs -f"

[tasks."docker:clean"]
description = "コンテナの停止とボリュームの削除"
run = "docker-compose down -v"

[tasks.clean]
description = "プロジェクトのクリーンアップ"
run = [
  "docker-compose down -v",
  "rm -rf node_modules",
  "rm -rf .next"
]
```

### 使用方法

```bash
# プロジェクト初期化（ツールをインストール）
mise install

# タスク実行
mise run dev          # 開発サーバー起動
mise run test         # テスト実行
mise run build        # ビルド
mise run docker:up    # Docker起動
```

## TypeScript設定

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "esnext",
    "lib": ["dom", "dom.iterable", "esnext"],
    "types": ["node", "react", "react-dom"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "react-jsx",
    "incremental": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,

    "plugins": [
      {
        "name": "next"
      }
    ],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx",
    ".next/types/**/*.ts"
  ],
  "exclude": ["node_modules"]
}
```

### 重要な設定項目

| 設定 | 説明 |
|------|------|
| `strict: true` | 厳格な型チェック有効（必須） |
| `noUnusedLocals: true` | 未使用変数エラー |
| `noUncheckedIndexedAccess: true` | 配列・オブジェクトアクセス時の安全性向上 |
| `exactOptionalPropertyTypes: true` | オプションプロパティの厳格化 |
| `paths` | パスエイリアス設定（`@/`でsrcディレクトリ参照） |

## ESLint設定（Flat Config）

### eslint.config.mjs

```javascript
import js from "@eslint/js";
import nextPlugin from "@next/eslint-plugin-next";
import prettierConfig from "eslint-config-prettier";
import eslintPluginImportX from "eslint-plugin-import-x";
import reactCompilerPlugin from "eslint-plugin-react-compiler";
import reactHooksPlugin from "eslint-plugin-react-hooks";
import regexPlugin from "eslint-plugin-regexp";
import security from "eslint-plugin-security";
import globals from "globals";
import tseslint from "typescript-eslint";

const config = tseslint.config(
  {
    ignores: [
      ".next",
      "node_modules",
      "src/components/ui/*",
      "public/mockServiceWorker.js",
      "coverage",
      "wt-*/**",
    ],
  },
  js.configs.recommended,
  ...tseslint.configs.strictTypeChecked,
  ...tseslint.configs.stylisticTypeChecked,
  eslintPluginImportX.flatConfigs.recommended,
  eslintPluginImportX.flatConfigs.typescript,
  regexPlugin.configs["flat/recommended"],
  security.configs.recommended,

  // Next.js / React
  nextPlugin.configs.recommended,
  {
    name: "react-hooks/recommended",
    plugins: {
      "react-hooks": reactHooksPlugin,
    },
    rules: reactHooksPlugin.configs.recommended.rules,
  },
  {
    name: "react-compiler",
    plugins: {
      "react-compiler": reactCompilerPlugin,
    },
    rules: {
      "react-compiler/react-compiler": "error", // 必須
    },
  },

  {
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
        ecmaFeatures: {
          jsx: true,
        },
      },
      globals: {
        ...globals.browser,
        ...globals.node,
      },
    },
    rules: {
      "@typescript-eslint/no-unused-vars": [
        "error",
        { argsIgnorePattern: "^_", varsIgnorePattern: "^_" },
      ],

      "@typescript-eslint/consistent-type-imports": [
        "warn",
        { prefer: "type-imports", fixStyle: "separate-type-imports" },
      ],

      "@typescript-eslint/no-misused-promises": [
        "error",
        { checksVoidReturn: { attributes: false } },
      ],

      // 型安全性の強化（any型の使用禁止）
      "@typescript-eslint/no-explicit-any": "error",
      "@typescript-eslint/no-unsafe-assignment": "error",
      "@typescript-eslint/no-unsafe-member-access": "error",
      "@typescript-eslint/no-unsafe-call": "error",
      "@typescript-eslint/no-unsafe-return": "error",
      "@typescript-eslint/no-unsafe-argument": "error",

      "react-compiler/react-compiler": "error",
    },
  },

  prettierConfig,
);

export default config;
```

### 重要なルール

| ルール | 説明 |
|--------|------|
| `react-compiler/react-compiler: "error"` | React Compiler最適化（必須） |
| `@typescript-eslint/no-explicit-any: "error"` | any型禁止（`enforcing-type-safety`スキル参照） |
| `@typescript-eslint/consistent-type-imports` | 型インポート分離 |

## Prettier設定

### .prettierrc

```json
{
  "semi": true,
  "singleQuote": false,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100
}
```

### package.jsonスクリプト

```json
{
  "scripts": {
    "fmt": "prettier --write .",
    "fmt:check": "prettier --check ."
  }
}
```

## pre-commit（Git Hooks）

### セットアップ

```bash
# mise経由でインストール
mise use pre-commit@latest

# pre-commitフック有効化
pre-commit install
```

### .pre-commit-config.yaml

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: local
    hooks:
      - id: eslint
        name: eslint
        entry: pnpm lint
        language: system
        files: \.(ts|tsx|js|jsx)$

      - id: prettier
        name: prettier
        entry: pnpm fmt
        language: system
        files: \.(ts|tsx|js|jsx|json|md)$
```

## package.json スクリプト

```json
{
  "scripts": {
    "dev": "next dev -p 3001",
    "build": "next build",
    "start": "next start",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "coverage": "vitest --coverage",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "fmt": "prettier --write .",
    "fmt:check": "prettier --check .",
    "type-check": "tsc --noEmit",
    "check-app": "pnpm type-check && pnpm lint && pnpm test"
  }
}
```

## 環境変数管理

### .env.example（テンプレート）

```bash
# Next.js
NEXT_PUBLIC_BASE_URL=http://localhost:3001
NODE_ENV=development

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# NextAuth
NEXTAUTH_URL=http://localhost:3001
NEXTAUTH_SECRET=your-secret-here

# Logging
LOG_FORMAT=text        # text | json | cloud-logging
LOG_LEVEL=debug        # debug | info | warn | error

# Mock Server（開発環境のみ）
ENABLE_MOCK_SERVER=true
```

### 型安全な環境変数管理

```typescript
// src/lib/env.ts
import { z } from "zod";

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  NEXTAUTH_SECRET: z.string().min(32),
  NODE_ENV: z.enum(["development", "production", "test"]),
  LOG_LEVEL: z.enum(["debug", "info", "warn", "error"]).default("info"),
});

export const env = envSchema.parse(process.env);
```

## VS Code設定

### .vscode/settings.json

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.tsdk": "node_modules/typescript/lib",
  "eslint.experimental.useFlatConfig": true
}
```

### 推奨拡張機能

```json
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "bradlc.vscode-tailwindcss",
    "prisma.prisma",
    "vitest.explorer"
  ]
}
```

## 参考資料

- **mise公式**: https://mise.jdx.dev
- **TypeScript公式**: https://www.typescriptlang.org
- **ESLint公式**: https://eslint.org
- **Prettier公式**: https://prettier.io

---

**関連ドキュメント:**
- [PROJECT-STRUCTURE.md](./PROJECT-STRUCTURE.md) - プロジェクト構造
- **`enforcing-type-safety`スキル**: 型安全性の原則
