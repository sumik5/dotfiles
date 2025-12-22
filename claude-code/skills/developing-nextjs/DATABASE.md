# Prisma ORM データベースガイド

## 概要

Prisma ORMは、型安全でモダンなデータベースアクセスを提供します。PostgreSQL、MySQL、SQLite等に対応しています。

## セットアップ

### インストール

```bash
pnpm add -D prisma
pnpm add @prisma/client
```

### 初期化

```bash
pnpm dlx prisma init
```

**生成されるファイル:**
- `prisma/schema.prisma`: データベーススキーマ定義
- `.env`: 環境変数（DATABASE_URL）

## スキーマ定義

### 基本的なスキーマ

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  posts Post[]
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  authorId String
  author   User   @relation(fields: [authorId], references: [id], onDelete: Cascade)
}
```

### データ型

| Prisma型 | PostgreSQL | 説明 |
|---------|-----------|------|
| String | TEXT | 文字列 |
| Int | INTEGER | 整数 |
| BigInt | BIGINT | 大きな整数 |
| Float | DOUBLE PRECISION | 浮動小数点 |
| Boolean | BOOLEAN | 真偽値 |
| DateTime | TIMESTAMP | 日時 |
| Json | JSONB | JSON |
| Bytes | BYTEA | バイナリ |

### リレーション

**1対多:**
```prisma
model User {
  id    String @id @default(cuid())
  posts Post[]
}

model Post {
  id       String @id @default(cuid())
  authorId String
  author   User   @relation(fields: [authorId], references: [id])
}
```

**多対多:**
```prisma
model Post {
  id   String @id @default(cuid())
  tags Tag[]
}

model Tag {
  id    String @id @default(cuid())
  posts Post[]
}
```

## マイグレーション

### 開発環境

```bash
# マイグレーション作成
pnpm prisma migrate dev --name add_user_table

# Prismaクライアント再生成（自動実行される）
pnpm prisma generate
```

### 本番環境

```bash
# マイグレーション適用
pnpm prisma migrate deploy

# データベースリセット（開発環境のみ）
pnpm prisma migrate reset
```

## Prismaクライアント

### セットアップ（シングルトン）

```typescript
// src/lib/prisma.ts
import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["query", "error", "warn"] : ["error"],
  });

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
```

### 基本的なCRUD操作

#### Create（作成）

```typescript
import { prisma } from "@/lib/prisma";

const user = await prisma.user.create({
  data: {
    email: "user@example.com",
    name: "John Doe",
  },
});
```

#### Read（読み取り）

```typescript
// 単一取得
const user = await prisma.user.findUnique({
  where: { id: "123" },
});

// 複数取得
const users = await prisma.user.findMany({
  where: {
    email: {
      contains: "@example.com",
    },
  },
  orderBy: {
    createdAt: "desc",
  },
  take: 10,
});

// リレーション込み取得
const user = await prisma.user.findUnique({
  where: { id: "123" },
  include: {
    posts: true,
  },
});
```

#### Update（更新）

```typescript
const user = await prisma.user.update({
  where: { id: "123" },
  data: {
    name: "Jane Doe",
  },
});
```

#### Delete（削除）

```typescript
const user = await prisma.user.delete({
  where: { id: "123" },
});

// 条件付き削除
const deletedUsers = await prisma.user.deleteMany({
  where: {
    createdAt: {
      lt: new Date("2023-01-01"),
    },
  },
});
```

## 高度なクエリ

### フィルタリング

```typescript
const users = await prisma.user.findMany({
  where: {
    AND: [
      { email: { contains: "@example.com" } },
      { createdAt: { gte: new Date("2024-01-01") } },
    ],
  },
});
```

### ソート

```typescript
const users = await prisma.user.findMany({
  orderBy: [
    { createdAt: "desc" },
    { name: "asc" },
  ],
});
```

### ページネーション

```typescript
const page = 1;
const pageSize = 10;

const users = await prisma.user.findMany({
  skip: (page - 1) * pageSize,
  take: pageSize,
});

const total = await prisma.user.count();
```

### 集計

```typescript
const stats = await prisma.post.aggregate({
  _count: true,
  _avg: {
    views: true,
  },
  _sum: {
    likes: true,
  },
});
```

## トランザクション

### インタラクティブトランザクション

```typescript
const result = await prisma.$transaction(async (tx) => {
  // ユーザー作成
  const user = await tx.user.create({
    data: { email: "user@example.com" },
  });

  // 投稿作成
  const post = await tx.post.create({
    data: {
      title: "First Post",
      authorId: user.id,
    },
  });

  return { user, post };
});
```

### バッチトランザクション

```typescript
const [user, post] = await prisma.$transaction([
  prisma.user.create({ data: { email: "user@example.com" } }),
  prisma.post.create({ data: { title: "First Post", authorId: "123" } }),
]);
```

## Next.js統合

### Server Componentでの使用

```typescript
// src/app/users/page.tsx
import { prisma } from "@/lib/prisma";

export default async function UsersPage() {
  const users = await prisma.user.findMany();

  return (
    <ul>
      {users.map((user) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

### Server Actionでの使用

```typescript
// src/actions/users/create.ts
"use server";

import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";

export async function createUser(formData: FormData) {
  const email = formData.get("email") as string;
  const name = formData.get("name") as string;

  await prisma.user.create({
    data: { email, name },
  });

  revalidatePath("/users");
}
```

## 型安全性

### Prismaの型推論

```typescript
import type { User, Post } from "@prisma/client";

// User型が自動生成される
const user: User = {
  id: "123",
  email: "user@example.com",
  name: "John Doe",
  createdAt: new Date(),
  updatedAt: new Date(),
};
```

### 部分的な型定義

```typescript
import type { Prisma } from "@prisma/client";

// 特定フィールドのみの型
type UserWithPosts = Prisma.UserGetPayload<{
  include: { posts: true };
}>;

// 選択フィールドのみの型
type UserBasic = Prisma.UserGetPayload<{
  select: { id: true; email: true };
}>;
```

## ベストプラクティス

### 1. Prismaクライアントの再利用

**❌ 悪い例:**
```typescript
import { PrismaClient } from "@prisma/client";

export async function getUser(id: string) {
  const prisma = new PrismaClient(); // 毎回新しいインスタンス
  const user = await prisma.user.findUnique({ where: { id } });
  await prisma.$disconnect();
  return user;
}
```

**✅ 良い例:**
```typescript
import { prisma } from "@/lib/prisma"; // シングルトン

export async function getUser(id: string) {
  return prisma.user.findUnique({ where: { id } });
}
```

### 2. 適切なリレーション取得

**不要なデータは取得しない:**
```typescript
// ✅ 良い例: 必要なフィールドのみ
const user = await prisma.user.findUnique({
  where: { id },
  select: {
    id: true,
    name: true,
    posts: {
      select: {
        id: true,
        title: true,
      },
    },
  },
});

// ❌ 悪い例: すべてのフィールドを取得
const user = await prisma.user.findUnique({
  where: { id },
  include: { posts: true },
});
```

### 3. エラーハンドリング

```typescript
try {
  const user = await prisma.user.create({
    data: { email, name },
  });
  return { success: true, data: user };
} catch (error) {
  if (error.code === "P2002") {
    return { success: false, error: "Email already exists" };
  }
  throw error;
}
```

## トラブルシューティング

### マイグレーションエラー

```bash
# マイグレーションリセット（開発環境のみ）
pnpm prisma migrate reset

# マイグレーション強制適用
pnpm prisma migrate deploy --force
```

### 型生成エラー

```bash
# Prismaクライアント再生成
pnpm prisma generate
```

## 参考資料

- **Prisma公式ドキュメント**: https://www.prisma.io/docs
- **Prisma Studio**: https://www.prisma.io/studio
- **Next.js + Prisma**: https://www.prisma.io/nextjs

---

**関連ドキュメント:**
- [NEXTJS-GUIDE.md](./NEXTJS-GUIDE.md) - Next.js機能
- [EXAMPLES.md](./EXAMPLES.md) - 実装例
