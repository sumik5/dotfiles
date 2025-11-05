# React 19 新機能ガイド

## 概要

React 19は、Actions、useActionState、ref as prop等の新機能を導入しました。このガイドでは、React 19の主要な新機能とNext.js 16との統合方法を説明します。

## React 19の主要な新機能

### 1. Actions（アクション）

**フォーム送信とデータ更新を簡潔に記述できる新しいパターン。**

#### 基本的な使用方法

```typescript
// Server Action（Next.js 16）
"use server";

export async function createPost(formData: FormData) {
  const title = formData.get("title") as string;
  const content = formData.get("content") as string;

  await db.post.create({ data: { title, content } });
  redirect("/posts");
}
```

```typescript
// フォームで使用
import { createPost } from "@/actions/posts/create";

export function CreatePostForm() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">Create</button>
    </form>
  );
}
```

### 2. useActionState（旧useFormState）

**Actionの状態管理を行うフック。ローディング状態、エラー、結果を管理できます。**

#### 基本構文

```typescript
"use client";

import { useActionState } from "react";
import { createPost } from "@/actions/posts/create";

export function CreatePostForm() {
  const [state, formAction, isPending] = useActionState(createPost, null);

  return (
    <form action={formAction}>
      {state?.error && <p className="text-red-500">{state.error}</p>}

      <input name="title" required />
      <textarea name="content" required />

      <button type="submit" disabled={isPending}>
        {isPending ? "Creating..." : "Create Post"}
      </button>
    </form>
  );
}
```

#### 型安全な使用

```typescript
// src/actions/posts/create.ts
"use server";

import { z } from "zod";

const postSchema = z.object({
  title: z.string().min(1),
  content: z.string().min(1),
});

type ActionState = {
  error?: string;
  success?: boolean;
};

export async function createPost(
  prevState: ActionState | null,
  formData: FormData
): Promise<ActionState> {
  const result = postSchema.safeParse({
    title: formData.get("title"),
    content: formData.get("content"),
  });

  if (!result.success) {
    return { error: "Invalid input" };
  }

  try {
    await db.post.create({ data: result.data });
    return { success: true };
  } catch (error) {
    return { error: "Failed to create post" };
  }
}
```

### 3. useOptimistic（楽観的UI更新）

**サーバーレスポンスを待たずにUIを即座に更新し、UXを向上させます。**

```typescript
"use client";

import { useOptimistic } from "react";
import { updateLikeCount } from "@/actions/posts/like";

type Post = {
  id: string;
  likes: number;
};

export function LikeButton({ post }: { post: Post }) {
  const [optimisticPost, addOptimisticLike] = useOptimistic(
    post,
    (state, newLikes: number) => ({ ...state, likes: newLikes })
  );

  const handleLike = async () => {
    // 楽観的更新（即座にUIを更新）
    addOptimisticLike(optimisticPost.likes + 1);

    // サーバーサイド更新
    await updateLikeCount(post.id);
  };

  return (
    <button onClick={handleLike}>
      👍 {optimisticPost.likes}
    </button>
  );
}
```

### 4. ref as Prop（ref属性の直接利用）

**forwardRefが不要になり、refを通常のpropsとして使用できます。**

#### 従来の方法（React 18以前）

```typescript
import { forwardRef } from "react";

const Input = forwardRef<HTMLInputElement, { placeholder: string }>(
  ({ placeholder }, ref) => {
    return <input ref={ref} placeholder={placeholder} />;
  }
);
```

#### 新しい方法（React 19）

```typescript
// forwardRef不要
export function Input({ ref, placeholder }: {
  ref?: React.Ref<HTMLInputElement>;
  placeholder: string;
}) {
  return <input ref={ref} placeholder={placeholder} />;
}
```

### 5. use()フック（非同期データの読み込み）

**PromiseやContextを直接読み込めます。**

```typescript
import { use } from "react";

type User = { id: string; name: string };

async function fetchUser(id: string): Promise<User> {
  const res = await fetch(`/api/users/${id}`);
  return res.json();
}

export function UserProfile({ userId }: { userId: string }) {
  // Promiseを直接読み込む
  const user = use(fetchUser(userId));

  return <div>{user.name}</div>;
}
```

**Suspenseと組み合わせる:**
```typescript
import { Suspense } from "react";

export default function Page() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <UserProfile userId="123" />
    </Suspense>
  );
}
```

## React Compiler（推奨）

React 19では、React Compilerがメモ化を自動化します。

### ESLintプラグイン（必須）

```javascript
// eslint.config.mjs
import reactCompilerPlugin from "eslint-plugin-react-compiler";

export default [
  {
    plugins: {
      "react-compiler": reactCompilerPlugin,
    },
    rules: {
      "react-compiler/react-compiler": "error", // 必須
    },
  },
];
```

### メモ化の自動化

**従来の方法（React 18以前）:**
```typescript
import { useMemo, useCallback } from "react";

function ExpensiveComponent({ data }) {
  const processedData = useMemo(() => {
    return data.map(item => item * 2);
  }, [data]);

  const handleClick = useCallback(() => {
    console.log("Clicked");
  }, []);

  return <div onClick={handleClick}>{processedData}</div>;
}
```

**新しい方法（React 19 + Compiler）:**
```typescript
// useMemo、useCallbackは不要（Compilerが自動最適化）
function ExpensiveComponent({ data }) {
  const processedData = data.map(item => item * 2);

  const handleClick = () => {
    console.log("Clicked");
  };

  return <div onClick={handleClick}>{processedData}</div>;
}
```

## フォーム処理のベストプラクティス

### 1. バリデーション統合

**React Hook Form + Zod + useActionState:**
```typescript
"use client";

import { useActionState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { createPost } from "@/actions/posts/create";

const formSchema = z.object({
  title: z.string().min(1, "Title is required"),
  content: z.string().min(10, "Content must be at least 10 characters"),
});

type FormData = z.infer<typeof formSchema>;

export function CreatePostForm() {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormData>({
    resolver: zodResolver(formSchema),
  });

  const [state, formAction, isPending] = useActionState(createPost, null);

  const onSubmit = handleSubmit((data) => {
    const formData = new FormData();
    formData.append("title", data.title);
    formData.append("content", data.content);
    formAction(formData);
  });

  return (
    <form onSubmit={onSubmit}>
      {state?.error && <p className="text-red-500">{state.error}</p>}

      <div>
        <input {...register("title")} />
        {errors.title && <p className="text-red-500">{errors.title.message}</p>}
      </div>

      <div>
        <textarea {...register("content")} />
        {errors.content && <p className="text-red-500">{errors.content.message}</p>}
      </div>

      <button type="submit" disabled={isPending}>
        {isPending ? "Creating..." : "Create Post"}
      </button>
    </form>
  );
}
```

### 2. プログレッシブエンハンスメント

**JavaScriptなしでも動作するフォーム:**
```typescript
// Server Action（JavaScriptなしでも動作）
"use server";

import { redirect } from "next/navigation";

export async function createPost(formData: FormData) {
  const title = formData.get("title") as string;
  const content = formData.get("content") as string;

  await db.post.create({ data: { title, content } });
  redirect("/posts");
}
```

```typescript
// フォーム（JavaScriptなしでも送信可能）
import { createPost } from "@/actions/posts/create";

export function CreatePostForm() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">Create</button>
    </form>
  );
}
```

## エラーハンドリング

### Error Boundaryでのエラー処理

```typescript
// src/app/error.tsx
"use client";

import { useEffect } from "react";

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
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

### Server Actionでのエラー処理

```typescript
"use server";

export async function createPost(formData: FormData) {
  try {
    const title = formData.get("title") as string;
    const content = formData.get("content") as string;

    await db.post.create({ data: { title, content } });
    return { success: true };
  } catch (error) {
    console.error("Failed to create post:", error);
    return { success: false, error: "Failed to create post" };
  }
}
```

## ベストプラクティス

### 1. Server-First設計

**可能な限りServer Componentを使用：**
```typescript
// ✅ 良い例
export default async function PostsPage() {
  const posts = await db.post.findMany();
  return <PostList posts={posts} />;
}

// ❌ 悪い例（不要なClient Component）
"use client";

import { useEffect, useState } from "react";

export default function PostsPage() {
  const [posts, setPosts] = useState([]);

  useEffect(() => {
    fetch("/api/posts").then(res => res.json()).then(setPosts);
  }, []);

  return <PostList posts={posts} />;
}
```

### 2. 型安全性の確保

**Zodスキーマでバリデーション:**
```typescript
import { z } from "zod";

const postSchema = z.object({
  title: z.string().min(1),
  content: z.string().min(10),
});

export async function createPost(formData: FormData) {
  const result = postSchema.safeParse({
    title: formData.get("title"),
    content: formData.get("content"),
  });

  if (!result.success) {
    return { error: result.error.flatten() };
  }

  // 型安全なデータ
  const { title, content } = result.data;
}
```

### 3. エラーハンドリングの徹底

**すべてのActionsでエラー処理:**
```typescript
export async function createPost(formData: FormData) {
  try {
    // 処理
  } catch (error) {
    console.error("Error:", error);
    return { error: "An error occurred" };
  }
}
```

## マイグレーションガイド（React 18 → React 19）

### useFormState → useActionState

```typescript
// React 18
import { useFormState } from "react-dom";

const [state, formAction] = useFormState(action, initialState);

// React 19
import { useActionState } from "react";

const [state, formAction, isPending] = useActionState(action, initialState);
```

### forwardRef → ref as prop

```typescript
// React 18
import { forwardRef } from "react";

const Input = forwardRef((props, ref) => {
  return <input ref={ref} {...props} />;
});

// React 19
export function Input({ ref, ...props }) {
  return <input ref={ref} {...props} />;
}
```

## 参考資料

- **React 19公式ブログ**: https://react.dev/blog/2024/04/25/react-19
- **React 19リリースノート**: https://react.dev/blog/2024/12/05/react-19
- **useActionState**: https://react.dev/reference/react/useActionState

---

**関連ドキュメント:**
- [NEXTJS-GUIDE.md](./NEXTJS-GUIDE.md) - Next.js 16機能
- [EXAMPLES.md](./EXAMPLES.md) - 実装例
