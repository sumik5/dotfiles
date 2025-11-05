# Vitest + MSW テストガイド

## 概要

このプロジェクトでは、Vitestをテストランナー、MSW（Mock Service Worker）をAPIモックツールとして使用します。

## セットアップ

### インストール

```bash
pnpm add -D vitest @vitejs/plugin-react vite-tsconfig-paths jsdom
pnpm add -D @testing-library/react @testing-library/jest-dom @testing-library/user-event
pnpm add -D msw@2.11.6
```

### Vitest設定

```typescript
// vitest.config.mts
/// <reference types="vitest" />
import { defineConfig } from "vitest/config";
import { configDefaults } from "vitest/config";
import react from "@vitejs/plugin-react";
import tsconfigPaths from "vite-tsconfig-paths";
import { resolve } from "path";

export default defineConfig({
  plugins: [react(), tsconfigPaths()] as any,
  test: {
    environment: "jsdom",
    globals: true,
    setupFiles: ["./src/test/setup.ts"],
    include: ["src/**/*.{test,spec}.{ts,tsx}"],
    exclude: [
      ...configDefaults.exclude,
      "src/components/ui/**/*.test.{ts,tsx}", // shadcn自動生成ファイル除外
    ],
    coverage: {
      provider: "istanbul",
      reporter: ["text", "json", "html", "json-summary"],
      include: ["src/**/*.{ts,tsx}"],
      exclude: [
        "src/**/*.d.ts",
        "src/**/*.test.{ts,tsx}",
        "src/test/**/*",
        "src/components/ui/**/*",
        "src/types/**",
        "src/mocks/**",
      ],
    },
    testTimeout: 10000,
    hookTimeout: 10000,
    teardownTimeout: 10000,
    fileParallelism: false,
    pool: "forks",
    poolOptions: {
      forks: {
        singleFork: true, // メモリ不足対策
        maxWorkers: 1,
        minWorkers: 1,
        isolate: false,
      },
    },
  },
  resolve: {
    alias: {
      "@": resolve(__dirname, "./src"),
    },
  },
});
```

### テストセットアップ

```typescript
// src/test/setup.ts
import "@testing-library/jest-dom";
import { cleanup } from "@testing-library/react";
import { afterEach } from "vitest";

// 各テスト後にクリーンアップ
afterEach(() => {
  cleanup();
});
```

## MSW（Mock Service Worker）

### セットアップ

```bash
# MSWワーカー初期化
npx msw init public/ --save
```

### ハンドラー定義

```typescript
// src/mocks/handlers/users.ts
import { http, HttpResponse } from "msw";

export const usersHandlers = [
  // GET /api/users
  http.get("/api/users", () => {
    return HttpResponse.json([
      { id: "1", name: "John Doe", email: "john@example.com" },
      { id: "2", name: "Jane Doe", email: "jane@example.com" },
    ]);
  }),

  // POST /api/users
  http.post("/api/users", async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json(
      { id: "3", ...body },
      { status: 201 }
    );
  }),

  // GET /api/users/:id
  http.get("/api/users/:id", ({ params }) => {
    const { id } = params;
    return HttpResponse.json({
      id,
      name: "John Doe",
      email: "john@example.com",
    });
  }),
];
```

### ハンドラー統合

```typescript
// src/mocks/handlers/index.ts
import { usersHandlers } from "./users";
import { projectsHandlers } from "./projects";

export const handlers = [
  ...usersHandlers,
  ...projectsHandlers,
];
```

### ブラウザMSW設定

```typescript
// src/mocks/browser.ts
import { setupWorker } from "msw/browser";
import { handlers } from "./handlers";

export const worker = setupWorker(...handlers);
```

### テストでのMSW使用

```typescript
// src/test/setup.ts
import { afterAll, afterEach, beforeAll } from "vitest";
import { setupServer } from "msw/node";
import { handlers } from "@/mocks/handlers";

const server = setupServer(...handlers);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## テスト戦略

### ユニットテスト

**ユーティリティ関数のテスト:**
```typescript
// src/lib/utils.test.ts
import { describe, it, expect } from "vitest";
import { cn } from "./utils";

describe("cn", () => {
  it("should merge class names", () => {
    const result = cn("px-4", "py-2");
    expect(result).toBe("px-4 py-2");
  });

  it("should handle conditional classes", () => {
    const result = cn("px-4", false && "hidden", "py-2");
    expect(result).toBe("px-4 py-2");
  });
});
```

### コンポーネントテスト

**Buttonコンポーネントのテスト:**
```typescript
// src/components/ui/button.test.tsx
import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Button } from "./button";

describe("Button", () => {
  it("should render correctly", () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole("button")).toHaveTextContent("Click me");
  });

  it("should call onClick when clicked", async () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);

    const user = userEvent.setup();
    await user.click(screen.getByRole("button"));

    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it("should be disabled", () => {
    render(<Button disabled>Click me</Button>);
    expect(screen.getByRole("button")).toBeDisabled();
  });
});
```

### Server Actionのテスト

```typescript
// src/actions/users/create.test.ts
import { describe, it, expect, vi } from "vitest";
import { createUser } from "./create";

// Prismaをモック
vi.mock("@/lib/prisma", () => ({
  prisma: {
    user: {
      create: vi.fn().mockResolvedValue({
        id: "1",
        email: "test@example.com",
        name: "Test User",
      }),
    },
  },
}));

describe("createUser", () => {
  it("should create a user", async () => {
    const formData = new FormData();
    formData.append("email", "test@example.com");
    formData.append("name", "Test User");

    const result = await createUser(formData);

    expect(result.success).toBe(true);
    expect(result.data?.email).toBe("test@example.com");
  });

  it("should return error for invalid email", async () => {
    const formData = new FormData();
    formData.append("email", "invalid-email");
    formData.append("name", "Test User");

    const result = await createUser(formData);

    expect(result.success).toBe(false);
    expect(result.error).toBeDefined();
  });
});
```

### ページコンポーネントのテスト（MSW使用）

```typescript
// src/app/users/page.test.tsx
import { describe, it, expect } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import UsersPage from "./page";

describe("UsersPage", () => {
  it("should render users list", async () => {
    render(await UsersPage());

    await waitFor(() => {
      expect(screen.getByText("John Doe")).toBeInTheDocument();
      expect(screen.getByText("Jane Doe")).toBeInTheDocument();
    });
  });
});
```

## テスト実行

### 基本的なコマンド

```bash
# すべてのテストを実行
pnpm test

# UIモード（推奨）
pnpm test:ui

# カバレッジレポート生成
pnpm coverage

# ウォッチモード
pnpm test:watch
```

### package.json設定

```json
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "coverage": "vitest --coverage",
    "test:watch": "vitest --watch"
  }
}
```

## カバレッジ目標

**目標: 100%カバレッジ（`testing`スキル参照）**

```bash
# カバレッジレポート生成
pnpm coverage

# カバレッジレポート表示（ブラウザ）
open coverage/index.html
```

## ベストプラクティス

### 1. AAAパターン（Arrange-Act-Assert）

```typescript
it("should create a user", async () => {
  // Arrange（準備）
  const formData = new FormData();
  formData.append("email", "test@example.com");

  // Act（実行）
  const result = await createUser(formData);

  // Assert（検証）
  expect(result.success).toBe(true);
});
```

### 2. テストの独立性

**各テストは独立して実行可能:**
```typescript
beforeEach(() => {
  // テストごとに初期化
  localStorage.clear();
});

afterEach(() => {
  // テストごとにクリーンアップ
  cleanup();
});
```

### 3. 意味のあるテスト名

```typescript
// ✅ 良い例
it("should return error when email is invalid", () => {});

// ❌ 悪い例
it("test1", () => {});
```

## トラブルシューティング

### メモリ不足エラー

**vitest.config.mtsで以下を設定:**
```typescript
{
  fileParallelism: false,
  pool: "forks",
  poolOptions: {
    forks: {
      singleFork: true,
      maxWorkers: 1,
    },
  },
}
```

### MSWが動作しない

```bash
# MSWワーカー再初期化
npx msw init public/ --save

# 開発サーバー再起動
```

## 参考資料

- **Vitest公式**: https://vitest.dev
- **MSW公式**: https://mswjs.io
- **Testing Library**: https://testing-library.com

---

**関連ドキュメント:**
- [EXAMPLES.md](./EXAMPLES.md) - テスト実装例
- **`testing`スキル**: TDD、カバレッジ100%目標
