# Next.js 16 完全ガイド

## 概要

Next.js 16は、App Router、Server Components、Cache Componentsを中心とした最新のReactフレームワークです。このガイドでは、Next.js 16固有の機能とベストプラクティスを説明します。

## App Router（アプリケーションルーター）

### 基本概念

App Routerは、`src/app/`ディレクトリ配下のフォルダ構造がURLパスに対応します。

**特殊ファイル：**
- `page.tsx`: ページコンポーネント（必須）
- `layout.tsx`: 共通レイアウト（ネスト可能）
- `loading.tsx`: ローディング状態（Suspense境界）
- `error.tsx`: エラーハンドリング（Error Boundary）
- `not-found.tsx`: 404ページ
- `route.ts`: API Route

### ページとルーティング

**例：基本的なページ**
```typescript
// src/app/dashboard/page.tsx
import { getDashboardData } from "@/lib/data";

// デフォルトでServer Component
export default async function DashboardPage() {
  // サーバーサイドで直接データフェッチ
  const data = await getDashboardData();

  return (
    <div>
      <h1>Dashboard</h1>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
```

**動的ルーティング：**
```typescript
// src/app/projects/[id]/page.tsx
import { getProjectById } from "@/lib/data";
import { notFound } from "next/navigation";

type Props = {
  params: Promise<{ id: string }>;
};

export default async function ProjectDetailPage({ params }: Props) {
  // Next.js 16: paramsは非同期
  const { id } = await params;
  const project = await getProjectById(id);

  if (!project) {
    notFound(); // not-found.tsxに遷移
  }

  return <div>{project.name}</div>;
}
```

**重要な変更（Next.js 16）：**
- `params`、`searchParams`は**Promise型**になりました
- 必ず`await`で解決してから使用してください

### レイアウト

**ルートレイアウト（必須）：**
```typescript
// src/app/layout.tsx
import type { ReactNode } from "react";
import "./globals.css";

export const metadata = {
  title: "My App",
  description: "Created with Next.js 16",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="ja">
      <body>
        <header>Header</header>
        <main>{children}</main>
        <footer>Footer</footer>
      </body>
    </html>
);
}
```

**ネストレイアウト：**
```typescript
// src/app/dashboard/layout.tsx
import type { ReactNode } from "react";
import { Sidebar } from "@/components/common/layout/Sidebar";

export default function DashboardLayout({ children }: { children: ReactNode }) {
  return (
    <div className="flex">
      <Sidebar />
      <div className="flex-1">{children}</div>
    </div>
  );
}
```

### ローディング状態

```typescript
// src/app/dashboard/loading.tsx
export default function Loading() {
  return <div>Loading...</div>;
}
```

**Suspense境界として自動的に機能します：**
```tsx
// Next.jsが自動生成する構造（イメージ）
<Suspense fallback={<Loading />}>
  <Page />
</Suspense>
```

### エラーハンドリング

```typescript
// src/app/dashboard/error.tsx
"use client"; // Error Boundaryは必ずClient Component

import { useEffect } from "react";

type Props = {
  error: Error & { digest?: string };
  reset: () => void;
};

export default function Error({ error, reset }: Props) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

## Server Components（サーバーコンポーネント）

### 基本原則

**デフォルトはServer Component：**
- `app/`配下のすべてのコンポーネントはServer Component
- サーバーサイドでのみ実行される
- クライアントにJavaScriptを送信しない（軽量）
- データベースやAPIに直接アクセス可能

**Client Componentが必要な場合：**
- インタラクティブ性（onClick、onChange等）
- Reactフック（useState、useEffect等）
- ブラウザAPI（window、localStorage等）
- イベントリスナー

### Server Componentの例

```typescript
// src/app/users/page.tsx
import { prisma } from "@/lib/prisma";

// Server Componentはデータベースに直接アクセス
export default async function UsersPage() {
  const users = await prisma.user.findMany({
    select: { id: true, name: true, email: true },
  });

  return (
    <ul>
      {users.map((user) => (
        <li key={user.id}>
          {user.name} - {user.email}
        </li>
      ))}
    </ul>
  );
}
```

### Client Componentへの切り替え

```typescript
// src/components/common/form/SearchForm.tsx
"use client"; // 最上部に記述

import { useState } from "react";

export function SearchForm() {
  const [query, setQuery] = useState("");

  return (
    <input
      type="text"
      value={query}
      onChange={(e) => setQuery(e.target.value)}
    />
  );
}
```

### Server ComponentとClient Componentの組み合わせ

```typescript
// src/app/products/page.tsx（Server Component）
import { getProducts } from "@/lib/data";
import { SearchForm } from "@/components/common/form/SearchForm"; // Client Component

export default async function ProductsPage() {
  const products = await getProducts();

  return (
    <div>
      <SearchForm /> {/* Client Component */}
      <ProductList products={products} /> {/* Server Componentでも可 */}
    </div>
  );
}
```

## Cache Components（キャッシュコンポーネント）

Next.js 16の新機能。Server Componentの出力をキャッシュして、パフォーマンスを向上させます。

**詳細は`using-next-devtools`スキルを参照してください。**

### "use cache"ディレクティブ

```typescript
// src/components/common/ProductList.tsx
"use cache"; // キャッシュ有効化

import { getProducts } from "@/lib/data";

export async function ProductList() {
  const products = await getProducts();

  return (
    <ul>
      {products.map((product) => (
        <li key={product.id}>{product.name}</li>
      ))}
    </ul>
  );
}
```

### キャッシュ戦略

**cacheLife（キャッシュ有効期限）:**
```typescript
"use cache";

import { cacheLife } from "next/cache";

export async function ProductList() {
  cacheLife("seconds"); // 1秒間キャッシュ
  // または: cacheLife("minutes"), cacheLife("hours"), cacheLife("days")

  const products = await getProducts();
  return <ul>...</ul>;
}
```

**cacheTag（キャッシュタグでの無効化）:**
```typescript
"use cache";

import { cacheTag } from "next/cache";

export async function ProductList() {
  cacheTag("products"); // タグ付け

  const products = await getProducts();
  return <ul>...</ul>;
}

// 別の場所でキャッシュ無効化
import { revalidateTag } from "next/cache";

export async function createProduct(data: ProductData) {
  await prisma.product.create({ data });
  revalidateTag("products"); // "products"タグのキャッシュを無効化
}
```

## Server Actions（サーバーアクション）

### 基本構文

```typescript
// src/actions/auth/login.ts
"use server";

import { z } from "zod";
import { redirect } from "next/navigation";

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

export async function login(formData: FormData) {
  // バリデーション
  const result = loginSchema.safeParse({
    email: formData.get("email"),
    password: formData.get("password"),
  });

  if (!result.success) {
    return { success: false, error: "Invalid input" };
  }

  // 認証処理
  const user = await authenticateUser(result.data);

  if (!user) {
    return { success: false, error: "Invalid credentials" };
  }

  // ログイン成功、リダイレクト
  redirect("/dashboard");
}
```

### フォームでの使用

```typescript
// src/components/common/auth/LoginForm.tsx
import { login } from "@/actions/auth/login";

export function LoginForm() {
  return (
    <form action={login}>
      <input type="email" name="email" required />
      <input type="password" name="password" required />
      <button type="submit">Login</button>
    </form>
  );
}
```

### React 19のuseActionStateフック（推奨）

```typescript
// src/components/common/auth/LoginForm.tsx
"use client";

import { useActionState } from "react";
import { login } from "@/actions/auth/login";

export function LoginForm() {
  const [state, formAction, isPending] = useActionState(login, null);

  return (
    <form action={formAction}>
      {state?.error && <p className="text-red-500">{state.error}</p>}
      <input type="email" name="email" required />
      <input type="password" name="password" required />
      <button type="submit" disabled={isPending}>
        {isPending ? "Loading..." : "Login"}
      </button>
    </form>
  );
}
```

## API Routes

### 基本構文

```typescript
// src/app/api/projects/route.ts
import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

// GET /api/projects
export async function GET(request: NextRequest) {
  const projects = await prisma.project.findMany();
  return NextResponse.json(projects);
}

// POST /api/projects
export async function POST(request: NextRequest) {
  const body = await request.json();
  const project = await prisma.project.create({ data: body });
  return NextResponse.json(project, { status: 201 });
}
```

### 動的ルート

```typescript
// src/app/api/projects/[id]/route.ts
import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

type Params = { params: Promise<{ id: string }> };

// GET /api/projects/:id
export async function GET(_request: NextRequest, { params }: Params) {
  const { id } = await params;
  const project = await prisma.project.findUnique({ where: { id } });

  if (!project) {
    return NextResponse.json({ error: "Not found" }, { status: 404 });
  }

  return NextResponse.json(project);
}

// PUT /api/projects/:id
export async function PUT(request: NextRequest, { params }: Params) {
  const { id } = await params;
  const body = await request.json();
  const project = await prisma.project.update({
    where: { id },
    data: body,
  });

  return NextResponse.json(project);
}

// DELETE /api/projects/:id
export async function DELETE(_request: NextRequest, { params }: Params) {
  const { id } = await params;
  await prisma.project.delete({ where: { id } });
  return NextResponse.json({ success: true });
}
```

## Metadata（メタデータ）

### 静的メタデータ

```typescript
// src/app/page.tsx
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Home - My App",
  description: "Welcome to my app",
};

export default function HomePage() {
  return <h1>Home</h1>;
}
```

### 動的メタデータ

```typescript
// src/app/projects/[id]/page.tsx
import type { Metadata } from "next";
import { getProjectById } from "@/lib/data";

type Props = {
  params: Promise<{ id: string }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id } = await params;
  const project = await getProjectById(id);

  return {
    title: `${project?.name} - Projects`,
    description: project?.description,
  };
}

export default async function ProjectDetailPage({ params }: Props) {
  // ...
}
```

## データフェッチング

### fetch()の拡張

Next.js 16では、`fetch()`がキャッシング機能を持ちます。

```typescript
// デフォルト: キャッシュ有効
const data = await fetch("https://api.example.com/data");

// キャッシュ無効
const data = await fetch("https://api.example.com/data", {
  cache: "no-store",
});

// 再検証付きキャッシュ
const data = await fetch("https://api.example.com/data", {
  next: { revalidate: 3600 }, // 1時間ごとに再検証
});
```

### Prismaでのデータフェッチ

```typescript
// src/app/users/page.tsx
import { prisma } from "@/lib/prisma";

export default async function UsersPage() {
  const users = await prisma.user.findMany({
    select: {
      id: true,
      name: true,
      email: true,
    },
  });

  return <UserList users={users} />;
}
```

## 設定ファイル（next.config.js）

### 基本設定例

```javascript
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output: "standalone", // Docker本番環境用

  // ログ設定
  logging: {
    fetches: {
      fullUrl: false, // fetch()のURLをログに出力しない
    },
  },

  // リダイレクト設定
  async redirects() {
    return [
      {
        source: "/old-path",
        destination: "/new-path",
        permanent: true, // 301リダイレクト
      },
    ];
  },

  // リライト設定（プロキシ）
  async rewrites() {
    return [
      {
        source: "/api/:path*",
        destination: "https://external-api.com/:path*",
      },
    ];
  },
};

export default nextConfig;
```

### 環境変数

```javascript
// next.config.js
const nextConfig = {
  env: {
    CUSTOM_KEY: process.env.CUSTOM_KEY,
  },
};
```

**推奨: 環境変数はlibで管理**
```typescript
// src/lib/env.ts
import { z } from "zod";

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  NEXTAUTH_SECRET: z.string().min(32),
});

export const env = envSchema.parse(process.env);
```

## ベストプラクティス

### 1. Server-First設計

**❌ 悪い例:**
```typescript
"use client";

import { useEffect, useState } from "react";

export default function UsersPage() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    fetch("/api/users")
      .then((res) => res.json())
      .then(setUsers);
  }, []);

  return <UserList users={users} />;
}
```

**✅ 良い例:**
```typescript
// Server Componentで直接フェッチ
import { prisma } from "@/lib/prisma";

export default async function UsersPage() {
  const users = await prisma.user.findMany();
  return <UserList users={users} />;
}
```

### 2. エラーハンドリングの徹底

**Server Action内でのエラー処理:**
```typescript
"use server";

export async function createProject(data: ProjectData) {
  try {
    const project = await prisma.project.create({ data });
    revalidatePath("/projects");
    return { success: true, data: project };
  } catch (error) {
    console.error("Failed to create project:", error);
    return { success: false, error: "Failed to create project" };
  }
}
```

### 3. 型安全性の確保

**Zodスキーマでバリデーション:**
```typescript
import { z } from "zod";

const projectSchema = z.object({
  name: z.string().min(1),
  description: z.string().optional(),
});

export async function createProject(formData: FormData) {
  const result = projectSchema.safeParse({
    name: formData.get("name"),
    description: formData.get("description"),
  });

  if (!result.success) {
    return { error: result.error.flatten() };
  }

  // 型安全なデータを使用
  const project = await prisma.project.create({ data: result.data });
  return { success: true, data: project };
}
```

## トラブルシューティング

### ビルドエラー

**症状**: `Dynamic server usage: Page couldn't be rendered statically`

**原因**: Server Componentで動的APIを使用している

**解決策**: ページに`export const dynamic = "force-dynamic";`を追加

```typescript
// src/app/dashboard/page.tsx
export const dynamic = "force-dynamic";

export default async function DashboardPage() {
  // ...
}
```

### キャッシュ問題

**症状**: データが更新されない

**解決策**: `revalidatePath()`または`revalidateTag()`でキャッシュ無効化

```typescript
import { revalidatePath } from "next/cache";

export async function updateProject(id: string, data: ProjectData) {
  await prisma.project.update({ where: { id }, data });
  revalidatePath("/projects"); // キャッシュ無効化
}
```

## 参考資料

- **Next.js 16公式ドキュメント**: https://nextjs.org/docs
- **App Routerガイド**: https://nextjs.org/docs/app
- **Server Actionsガイド**: https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations

---

**関連ドキュメント:**
- [REACT-GUIDE.md](./REACT-GUIDE.md) - React 19新機能
- [EXAMPLES.md](./EXAMPLES.md) - 実装例
- [PROJECT-STRUCTURE.md](./PROJECT-STRUCTURE.md) - プロジェクト構造
