# 実装例集

## 概要

このドキュメントでは、Next.js 16 + React 19の実装例を紹介します。すべての例は実際のプロダクションコードから抽出されています。

## Server Componentの実装例

### ページコンポーネント（データフェッチ込み）

```typescript
// src/app/dashboard/page.tsx
import { getDashboardStats, getRecentActivityLogs } from "@/lib/data";
import Dashboard from "@/components/pages/dashboard/Dashboard";

// デフォルトでServer Component
// 動的レンダリングを強制
export const dynamic = "force-dynamic";

export default async function DashboardPage() {
  // サーバーサイドで直接データフェッチ
  const numToFetch = 10;
  const newsList = await getRecentActivityLogs(numToFetch);
  const stats = await getDashboardStats();

  return <Dashboard stats={stats} newsList={newsList} />;
}
```

### 動的ルーティング

```typescript
// src/app/projects/[id]/page.tsx
import type { Metadata } from "next";
import { getProjectById } from "@/lib/data";
import { notFound } from "next/navigation";
import ProjectDetail from "@/components/pages/projects/ProjectDetail";

type Props = {
  params: Promise<{ id: string }>;
};

// 動的メタデータ生成
export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id } = await params;
  const project = await getProjectById(id);

  if (!project) {
    return {
      title: "Project Not Found",
    };
  }

  return {
    title: `${project.name} - Projects`,
    description: project.description || "Project details",
  };
}

export default async function ProjectDetailPage({ params }: Props) {
  const { id } = await params;
  const project = await getProjectById(id);

  if (!project) {
    notFound(); // not-found.tsxに遷移
  }

  return <ProjectDetail project={project} />;
}
```

## Server Actionsの実装例

### 基本的なServer Action

```typescript
// src/actions/project/setup.ts
"use server";

import { z } from "zod";
import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

// 入力スキーマ定義
const setupProjectInputSchema = z.object({
  projectId: z.string().min(1),
  id: z.string(),
  subDomain: z.string().min(1),
});

type SetupProjectInput = z.infer<typeof setupProjectInputSchema>;

// 戻り値の型定義
type ActionResult<T> = {
  success: boolean;
  data?: T;
  error?: string;
  details?: string;
};

type SetupProjectResult = {
  buildId: string;
};

export async function setupProject(
  input: SetupProjectInput
): Promise<ActionResult<SetupProjectResult>> {
  try {
    // バリデーション
    const validationResult = setupProjectInputSchema.safeParse(input);
    if (!validationResult.success) {
      return {
        success: false,
        error: "リクエストの形式が正しくありません",
        details: validationResult.error.issues
          .map((err) => err.message)
          .join(", "),
      };
    }

    const { projectId, id, subDomain } = validationResult.data;

    // データベース操作
    await prisma.deployInfo.update({
      where: { id },
      data: {
        subDomain,
        projectId,
        status: "準備中",
        timestamp: new Date(),
      },
    });

    // キャッシュ再検証
    revalidatePath("/dashboard");
    revalidatePath("/projects");

    return {
      success: true,
      data: { buildId: "mock-build-id" },
    };
  } catch (error) {
    console.error("[setupProject] Error:", error);

    const errorMessage =
      error instanceof Error ? error.message : "不明なエラーが発生しました";

    return {
      success: false,
      error: "プロジェクトの作成に失敗しました",
      details: errorMessage,
    };
  }
}
```

### FormDataを受け取るServer Action

```typescript
// src/actions/users/create.ts
"use server";

import { z } from "zod";
import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";

const userSchema = z.object({
  email: z.string().email("Invalid email"),
  name: z.string().min(1, "Name is required"),
});

type ActionState = {
  error?: string;
  success?: boolean;
};

export async function createUser(
  prevState: ActionState | null,
  formData: FormData
): Promise<ActionState> {
  const result = userSchema.safeParse({
    email: formData.get("email"),
    name: formData.get("name"),
  });

  if (!result.success) {
    return { error: result.error.errors[0]?.message || "Validation failed" };
  }

  try {
    await prisma.user.create({
      data: result.data,
    });

    revalidatePath("/users");
    return { success: true };
  } catch (error) {
    console.error("Failed to create user:", error);
    return { error: "Failed to create user" };
  }
}
```

## Client Componentの実装例

### useActionStateを使用したフォーム

```typescript
// src/components/common/form/CreateUserForm.tsx
"use client";

import { useActionState } from "react";
import { createUser } from "@/actions/users/create";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

export function CreateUserForm() {
  const [state, formAction, isPending] = useActionState(createUser, null);

  return (
    <form action={formAction} className="space-y-4">
      {state?.error && (
        <p className="text-red-500 text-sm">{state.error}</p>
      )}

      {state?.success && (
        <p className="text-green-500 text-sm">User created successfully!</p>
      )}

      <div>
        <label htmlFor="name" className="block text-sm font-medium">
          Name
        </label>
        <Input id="name" name="name" required />
      </div>

      <div>
        <label htmlFor="email" className="block text-sm font-medium">
          Email
        </label>
        <Input id="email" name="email" type="email" required />
      </div>

      <Button type="submit" disabled={isPending}>
        {isPending ? "Creating..." : "Create User"}
      </Button>
    </form>
  );
}
```

### React Hook Form + Zodバリデーション

```typescript
// src/components/common/form/CreatePostForm.tsx
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";

const formSchema = z.object({
  title: z.string().min(1, "Title is required"),
  content: z.string().min(10, "Content must be at least 10 characters"),
});

type FormData = z.infer<typeof formSchema>;

export function CreatePostForm() {
  const form = useForm<FormData>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      title: "",
      content: "",
    },
  });

  async function onSubmit(values: FormData) {
    try {
      const response = await fetch("/api/posts", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(values),
      });

      if (!response.ok) {
        throw new Error("Failed to create post");
      }

      form.reset();
    } catch (error) {
      console.error("Error:", error);
    }
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="title"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Title</FormLabel>
              <FormControl>
                <Input {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="content"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Content</FormLabel>
              <FormControl>
                <Textarea {...field} rows={5} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <Button type="submit">Create Post</Button>
      </form>
    </Form>
  );
}
```

## API Routeの実装例

### 基本的なAPI Route

```typescript
// src/app/api/projects/route.ts
import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { z } from "zod";

// GET /api/projects
export async function GET(request: NextRequest) {
  try {
    const projects = await prisma.project.findMany({
      select: {
        id: true,
        name: true,
        description: true,
        createdAt: true,
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    return NextResponse.json(projects);
  } catch (error) {
    console.error("Failed to fetch projects:", error);
    return NextResponse.json(
      { error: "Failed to fetch projects" },
      { status: 500 }
    );
  }
}

// POST /api/projects
const createProjectSchema = z.object({
  name: z.string().min(1),
  description: z.string().optional(),
});

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const result = createProjectSchema.safeParse(body);

    if (!result.success) {
      return NextResponse.json(
        { error: "Invalid input", details: result.error.flatten() },
        { status: 400 }
      );
    }

    const project = await prisma.project.create({
      data: result.data,
    });

    return NextResponse.json(project, { status: 201 });
  } catch (error) {
    console.error("Failed to create project:", error);
    return NextResponse.json(
      { error: "Failed to create project" },
      { status: 500 }
    );
  }
}
```

### 動的API Route

```typescript
// src/app/api/projects/[id]/route.ts
import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

type Params = { params: Promise<{ id: string }> };

// GET /api/projects/:id
export async function GET(_request: NextRequest, { params }: Params) {
  try {
    const { id } = await params;
    const project = await prisma.project.findUnique({
      where: { id },
    });

    if (!project) {
      return NextResponse.json(
        { error: "Project not found" },
        { status: 404 }
      );
    }

    return NextResponse.json(project);
  } catch (error) {
    console.error("Failed to fetch project:", error);
    return NextResponse.json(
      { error: "Failed to fetch project" },
      { status: 500 }
    );
  }
}

// DELETE /api/projects/:id
export async function DELETE(_request: NextRequest, { params }: Params) {
  try {
    const { id } = await params;
    await prisma.project.delete({ where: { id } });

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("Failed to delete project:", error);
    return NextResponse.json(
      { error: "Failed to delete project" },
      { status: 500 }
    );
  }
}
```

## レイアウトの実装例

### ルートレイアウト

```typescript
// src/app/layout.tsx
import type { ReactNode } from "react";
import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "My App",
  description: "Created with Next.js 16",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="ja">
      <body>
        <div className="min-h-screen flex flex-col">
          <header className="border-b">
            <nav className="container mx-auto px-4 py-4">
              <h1 className="text-2xl font-bold">My App</h1>
            </nav>
          </header>

          <main className="flex-1 container mx-auto px-4 py-8">
            {children}
          </main>

          <footer className="border-t py-4 text-center text-sm text-gray-600">
            © 2025 My App
          </footer>
        </div>
      </body>
    </html>
  );
}
```

### ネストレイアウト

```typescript
// src/app/dashboard/layout.tsx
import type { ReactNode } from "react";
import { Sidebar } from "@/components/common/layout/Sidebar";

export default function DashboardLayout({ children }: { children: ReactNode }) {
  return (
    <div className="flex gap-6">
      <aside className="w-64">
        <Sidebar />
      </aside>

      <div className="flex-1">
        {children}
      </div>
    </div>
  );
}
```

## エラーハンドリングの実装例

### Error Boundary

```typescript
// src/app/error.tsx
"use client";

import { useEffect } from "react";
import { Button } from "@/components/ui/button";

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
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h2 className="text-2xl font-bold mb-4">Something went wrong!</h2>
      <p className="text-gray-600 mb-4">{error.message}</p>
      <Button onClick={reset}>Try again</Button>
    </div>
  );
}
```

### Not Found

```typescript
// src/app/not-found.tsx
import Link from "next/link";
import { Button } from "@/components/ui/button";

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h2 className="text-2xl font-bold mb-4">404 - Page Not Found</h2>
      <p className="text-gray-600 mb-4">
        Could not find the requested resource
      </p>
      <Link href="/">
        <Button>Return Home</Button>
      </Link>
    </div>
  );
}
```

## 参考資料

- **Next.js公式ドキュメント**: https://nextjs.org/docs
- **React公式ドキュメント**: https://react.dev
- **Prisma公式ドキュメント**: https://www.prisma.io/docs

---

**関連ドキュメント:**
- [NEXTJS-GUIDE.md](./NEXTJS-GUIDE.md) - Next.js 16機能詳細
- [REACT-GUIDE.md](./REACT-GUIDE.md) - React 19新機能
- [DATABASE.md](./DATABASE.md) - Prisma ORM使用方法
