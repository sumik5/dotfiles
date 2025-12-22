# Tailwind CSS v4 + shadcn/ui スタイリングガイド

## 概要

このプロジェクトでは、Tailwind CSS v4とshadcn/uiを使用してスタイリングを行います。

## Tailwind CSS v4

### セットアップ

**インストール:**
```bash
pnpm add -D tailwindcss@4.1.15 postcss autoprefixer
pnpm dlx tailwindcss init -p
```

**tailwind.config.js:**
```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
```

**globals.css:**
```css
/* src/app/globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### 基本的な使用方法

```tsx
<div className="flex items-center justify-between p-4 bg-gray-100">
  <h1 className="text-2xl font-bold">Title</h1>
  <button className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
    Click Me
  </button>
</div>
```

### レスポンシブデザイン

```tsx
<div className="w-full md:w-1/2 lg:w-1/3">
  {/* モバイル: 100%, タブレット: 50%, デスクトップ: 33% */}
</div>
```

## shadcn/ui

### 初期設定

```bash
pnpm dlx shadcn@latest init
```

**components.json（自動生成）:**
```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "default",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.js",
    "css": "src/app/globals.css",
    "baseColor": "slate",
    "cssVariables": true
  },
  "aliases": {
    "utils": "@/lib/utils",
    "components": "@/components"
  }
}
```

### コンポーネントの追加

```bash
# 個別追加
pnpm dlx shadcn@latest add button
pnpm dlx shadcn@latest add card
pnpm dlx shadcn@latest add dialog

# 複数同時追加
pnpm dlx shadcn@latest add button card dialog form input
```

### 基本的な使用例

#### Button

```tsx
import { Button } from "@/components/ui/button";

export function Example() {
  return (
    <div className="flex gap-2">
      <Button>Default</Button>
      <Button variant="destructive">Destructive</Button>
      <Button variant="outline">Outline</Button>
      <Button variant="ghost">Ghost</Button>
    </div>
  );
}
```

#### Card

```tsx
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export function Example() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Card Title</CardTitle>
        <CardDescription>Card Description</CardDescription>
      </CardHeader>
      <CardContent>
        <p>Card Content</p>
      </CardContent>
      <CardFooter>
        <Button>Action</Button>
      </CardFooter>
    </Card>
  );
}
```

#### Dialog

```tsx
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";

export function Example() {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button>Open</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Are you sure?</DialogTitle>
          <DialogDescription>
            This action cannot be undone.
          </DialogDescription>
        </DialogHeader>
      </DialogContent>
    </Dialog>
  );
}
```

### フォーム統合（React Hook Form + Zod）

```tsx
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";

const formSchema = z.object({
  username: z.string().min(2).max(50),
});

export function ProfileForm() {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      username: "",
    },
  });

  function onSubmit(values: z.infer<typeof formSchema>) {
    console.log(values);
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
        <FormField
          control={form.control}
          name="username"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Username</FormLabel>
              <FormControl>
                <Input placeholder="shadcn" {...field} />
              </FormControl>
              <FormDescription>
                This is your public display name.
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit">Submit</Button>
      </form>
    </Form>
  );
}
```

## カスタムコンポーネント作成

### cn()ユーティリティ

```typescript
// src/lib/utils.ts
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

**使用例:**
```tsx
import { cn } from "@/lib/utils";

export function CustomButton({ className, ...props }) {
  return (
    <button
      className={cn(
        "px-4 py-2 bg-blue-500 text-white rounded",
        className
      )}
      {...props}
    />
  );
}
```

## ダークモード対応

### next-themesのセットアップ

```bash
pnpm add next-themes
```

**ThemeProvider:**
```tsx
// src/components/common/base/ThemeProvider.tsx
"use client";

import { ThemeProvider as NextThemesProvider } from "next-themes";
import type { ReactNode } from "react";

export function ThemeProvider({ children }: { children: ReactNode }) {
  return (
    <NextThemesProvider attribute="class" defaultTheme="system">
      {children}
    </NextThemesProvider>
  );
}
```

**ルートレイアウトに追加:**
```tsx
// src/app/layout.tsx
import { ThemeProvider } from "@/components/common/base/ThemeProvider";

export default function RootLayout({ children }) {
  return (
    <html lang="ja" suppressHydrationWarning>
      <body>
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  );
}
```

**テーマ切り替えボタン:**
```tsx
"use client";

import { useTheme } from "next-themes";
import { Button } from "@/components/ui/button";

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();

  return (
    <Button
      variant="ghost"
      onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
    >
      {theme === "dark" ? "🌞" : "🌙"}
    </Button>
  );
}
```

## ベストプラクティス

### 1. コンポーネントの再利用性

**❌ 悪い例:**
```tsx
<div className="flex items-center justify-between p-4 bg-gray-100 rounded shadow">
  <h2 className="text-xl font-bold">Title</h2>
  <button className="px-4 py-2 bg-blue-500 text-white rounded">Action</button>
</div>
```

**✅ 良い例:**
```tsx
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

<Card>
  <CardHeader>
    <CardTitle>Title</CardTitle>
  </CardHeader>
  <CardContent>
    <Button>Action</Button>
  </CardContent>
</Card>
```

### 2. 一貫性のあるスタイリング

**カラーパレット、スペーシング、フォントサイズを統一:**
```tsx
// Tailwind設定で定義
theme: {
  extend: {
    colors: {
      primary: "#3b82f6",
      secondary: "#6366f1",
    },
    spacing: {
      18: "4.5rem",
    },
  },
}
```

### 3. アクセシビリティ

**適切なARIA属性とキーボードナビゲーション:**
```tsx
<button
  aria-label="Close dialog"
  onClick={onClose}
  className="p-2 hover:bg-gray-100 rounded"
>
  <XIcon />
</button>
```

## 参考資料

- **Tailwind CSS v4公式**: https://tailwindcss.com
- **shadcn/ui公式**: https://ui.shadcn.com
- **next-themes**: https://github.com/pacocoursey/next-themes

---

**関連ドキュメント:**
- [EXAMPLES.md](./EXAMPLES.md) - 実装例
- [PROJECT-STRUCTURE.md](./PROJECT-STRUCTURE.md) - プロジェクト構造
