# TypeScript型安全性詳細

このファイルでは、TypeScript/JavaScriptにおける型安全性の詳細なガイドラインを説明します。

## 📋 目次

- [any型の絶対禁止](#any型の絶対禁止)
- [正しい型定義方法](#正しい型定義方法)
- [TypeScriptベストプラクティス](#typescriptベストプラクティス)
- [型ガードパターン](#型ガードパターン)
- [ジェネリクスの活用](#ジェネリクスの活用)
- [Utility Typesの活用](#utility-typesの活用)

## 🚫 any型の絶対禁止

### ❌ 絶対に使用してはいけないパターン

#### パターン1: any型の直接使用

```typescript
// ❌ 悪い例
function processData(data: any) {
  return data.value  // 型安全性が失われる
}

const result: any = fetchData()  // 型チェックが無効化される
```

**問題点**:
- TypeScriptの型チェックが完全に無効化される
- ランタイムエラーの原因になる
- IDEの補完が効かない
- リファクタリングが困難になる

#### パターン2: Function型の使用

```typescript
// ❌ 悪い例
const callback: Function = () => {}  // anyと同等
const handler: Function = (x) => x * 2
```

**問題点**:
- 引数と戻り値の型が不明
- 型安全性が失われる

**正しい方法**:
```typescript
// ✅ 良い例
type Callback = () => void
const callback: Callback = () => {}

type Handler = (x: number) => number
const handler: Handler = (x) => x * 2
```

#### パターン3: non-null assertion（!）の濫用

```typescript
// ❌ 悪い例
const value = data!.value!.nested!  // 危険
const element = document.getElementById('app')!  // nullの可能性を無視
```

**問題点**:
- nullやundefinedの可能性を無視
- ランタイムエラーの原因

**正しい方法**:
```typescript
// ✅ 良い例: オプショナルチェイニング
const value = data?.value?.nested ?? defaultValue

// ✅ 良い例: 型ガード
const element = document.getElementById('app')
if (element !== null) {
  element.style.color = 'red'
}
```

## ✅ 正しい型定義方法

### 1. 明示的なインターフェース定義

```typescript
// ✅ APIレスポンスの型定義
interface ApiResponse<T> {
  data: T
  status: number
  message: string
}

interface User {
  id: string
  name: string
  email: string
  createdAt: Date
}

interface Post {
  id: string
  title: string
  content: string
  authorId: string
}

// 使用例
async function fetchUser(id: string): Promise<ApiResponse<User>> {
  const response = await fetch(`/api/users/${id}`)
  return response.json()
}
```

### 2. unknown型の使用（型ガードとセット）

```typescript
// ✅ 不明な型はunknownを使用
function handleUnknownData(data: unknown): string {
  // 型ガードで安全に処理
  if (typeof data === 'object' && data !== null && 'value' in data) {
    const obj = data as { value: unknown }
    if (typeof obj.value === 'string') {
      return obj.value
    }
  }
  throw new Error('Invalid data structure')
}

// ✅ JSONパースの安全な処理
function parseJSON<T>(json: string, validator: (data: unknown) => data is T): T {
  const parsed: unknown = JSON.parse(json)
  if (validator(parsed)) {
    return parsed
  }
  throw new Error('Invalid JSON structure')
}

// バリデーター関数
function isUser(data: unknown): data is User {
  return typeof data === 'object' &&
         data !== null &&
         'id' in data && typeof (data as any).id === 'string' &&
         'name' in data && typeof (data as any).name === 'string' &&
         'email' in data && typeof (data as any).email === 'string'
}

// 使用例
const userData = parseJSON(jsonString, isUser)
```

### 3. ジェネリクスの活用

```typescript
// ✅ 型安全なfetch関数
async function fetchData<T>(
  url: string,
  validator: (data: unknown) => data is T
): Promise<T> {
  const response = await fetch(url)
  const data: unknown = await response.json()

  if (validator(data)) {
    return data
  }

  throw new Error(`Invalid response from ${url}`)
}

// 使用例
const user = await fetchData<User>('/api/user', isUser)
console.log(user.name)  // 型安全
```

## 📚 TypeScriptベストプラクティス

### 1. strict mode有効化（必須）

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,                     // すべてのstrict系フラグを有効化
    "noImplicitAny": true,             // 暗黙的なanyを禁止
    "strictNullChecks": true,          // null/undefinedの厳密チェック
    "strictFunctionTypes": true,       // 関数型の厳密チェック
    "strictBindCallApply": true,       // bind/call/applyの型チェック
    "strictPropertyInitialization": true, // プロパティ初期化チェック
    "noImplicitThis": true,            // 暗黙的なthisを禁止
    "alwaysStrict": true               // 'use strict'を自動挿入
  }
}
```

### 2. 明示的な関数型注釈

```typescript
// ✅ すべての関数に型注釈
function getUserById(id: string): User | null {
  // 実装
  return null
}

// ✅ async関数
async function fetchUserData(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`)
  return response.json()
}

// ✅ 高階関数
function createHandler(
  handler: (value: string) => void
): (event: Event) => void {
  return (event: Event) => {
    if (event.target instanceof HTMLInputElement) {
      handler(event.target.value)
    }
  }
}
```

### 3. オプショナルチェイニング（?.）とNullish Coalescing（??）

```typescript
// ✅ オプショナルチェイニング
const userName = user?.profile?.name

// ✅ Nullish Coalescing
const displayName = userName ?? 'Unknown'

// ✅ 組み合わせ
const email = user?.contact?.email ?? 'no-email@example.com'

// ❌ 悪い例（non-null assertion）
const userName = user!.profile!.name  // 危険
```

### 4. 型ガードの定義

```typescript
// ✅ 型ガード関数
function isString(value: unknown): value is string {
  return typeof value === 'string'
}

function isNumber(value: unknown): value is number {
  return typeof value === 'number'
}

function isUser(value: unknown): value is User {
  return typeof value === 'object' &&
         value !== null &&
         'id' in value &&
         'name' in value &&
         'email' in value
}

function isArray<T>(
  value: unknown,
  itemGuard: (item: unknown) => item is T
): value is T[] {
  return Array.isArray(value) && value.every(itemGuard)
}

// 使用例
if (isArray(data, isUser)) {
  data.forEach(user => {
    console.log(user.name)  // 型安全
  })
}
```

### 5. const assertion

```typescript
// ✅ const assertion でリテラル型を保持
const COLORS = ['red', 'green', 'blue'] as const
type Color = typeof COLORS[number]  // 'red' | 'green' | 'blue'

const config = {
  api: {
    baseUrl: 'https://api.example.com',
    timeout: 5000
  }
} as const

type Config = typeof config
// {
//   readonly api: {
//     readonly baseUrl: "https://api.example.com"
//     readonly timeout: 5000
//   }
// }

// ✅ enum の代替として
const Status = {
  PENDING: 'pending',
  COMPLETED: 'completed',
  FAILED: 'failed'
} as const

type StatusValue = typeof Status[keyof typeof Status]
// 'pending' | 'completed' | 'failed'
```

## 🛡️ 型ガードパターン

### パターン1: typeof型ガード

```typescript
function processValue(value: string | number): string {
  if (typeof value === 'string') {
    return value.toUpperCase()
  }
  return value.toString()
}
```

### パターン2: instanceof型ガード

```typescript
class ApiError extends Error {
  constructor(public statusCode: number, message: string) {
    super(message)
  }
}

function handleError(error: unknown): void {
  if (error instanceof ApiError) {
    console.error(`API Error ${error.statusCode}: ${error.message}`)
  } else if (error instanceof Error) {
    console.error(`Error: ${error.message}`)
  } else {
    console.error('Unknown error')
  }
}
```

### パターン3: in演算子型ガード

```typescript
type Dog = { name: string; bark: () => void }
type Cat = { name: string; meow: () => void }

function makeSound(animal: Dog | Cat): void {
  if ('bark' in animal) {
    animal.bark()  // Dogと推論
  } else {
    animal.meow()  // Catと推論
  }
}
```

### パターン4: カスタム型ガード

```typescript
interface Success<T> {
  success: true
  data: T
}

interface Failure {
  success: false
  error: string
}

type Result<T> = Success<T> | Failure

function isSuccess<T>(result: Result<T>): result is Success<T> {
  return result.success === true
}

function processResult<T>(result: Result<T>): T {
  if (isSuccess(result)) {
    return result.data  // Success<T>と推論
  }
  throw new Error(result.error)  // Failureと推論
}
```

## 🔧 ジェネリクスの活用

### パターン1: 基本的なジェネリクス

```typescript
// ✅ ジェネリック関数
function identity<T>(value: T): T {
  return value
}

const num = identity(42)        // number
const str = identity('hello')   // string
```

### パターン2: 制約付きジェネリクス

```typescript
interface HasId {
  id: string
}

function findById<T extends HasId>(items: T[], id: string): T | undefined {
  return items.find(item => item.id === id)
}

// 使用例
const users: User[] = [...]
const user = findById(users, '123')  // User | undefined
```

### パターン3: 複数の型パラメータ

```typescript
function map<T, U>(
  items: T[],
  mapper: (item: T) => U
): U[] {
  return items.map(mapper)
}

const numbers = [1, 2, 3]
const strings = map(numbers, n => n.toString())  // string[]
```

### パターン4: ジェネリック型

```typescript
interface ApiResponse<T> {
  data: T
  status: number
  timestamp: Date
}

type UserResponse = ApiResponse<User>
type PostsResponse = ApiResponse<Post[]>
```

## 🎨 Utility Typesの活用

TypeScript組み込みのUtility Typesを活用して、型安全性を向上させます。

### Partial<T> - すべてのプロパティをオプショナルに

```typescript
interface User {
  id: string
  name: string
  email: string
}

type PartialUser = Partial<User>
// {
//   id?: string
//   name?: string
//   email?: string
// }

function updateUser(id: string, updates: Partial<User>): User {
  // 一部のプロパティのみ更新
  return { ...existingUser, ...updates }
}
```

### Required<T> - すべてのプロパティを必須に

```typescript
interface Config {
  apiKey?: string
  timeout?: number
}

type RequiredConfig = Required<Config>
// {
//   apiKey: string
//   timeout: number
// }
```

### Readonly<T> - すべてのプロパティを読み取り専用に

```typescript
type ReadonlyUser = Readonly<User>
// {
//   readonly id: string
//   readonly name: string
//   readonly email: string
// }
```

### Pick<T, K> - 特定のプロパティのみ選択

```typescript
type UserCredentials = Pick<User, 'email' | 'password'>
// {
//   email: string
//   password: string
// }
```

### Omit<T, K> - 特定のプロパティを除外

```typescript
type UserWithoutPassword = Omit<User, 'password'>
// User型からpasswordを除いた型
```

### Record<K, T> - キーと値の型を指定

```typescript
type UserRoles = Record<string, 'admin' | 'user' | 'guest'>
// {
//   [key: string]: 'admin' | 'user' | 'guest'
// }

const roles: UserRoles = {
  'user-1': 'admin',
  'user-2': 'user'
}
```

### ReturnType<T> - 関数の戻り値の型を取得

```typescript
function createUser() {
  return {
    id: '123',
    name: 'John'
  }
}

type User = ReturnType<typeof createUser>
// {
//   id: string
//   name: string
// }
```

## 🔗 関連ファイル

- **[SKILL.md](./SKILL.md)** - 概要に戻る
- **[PYTHON.md](./PYTHON.md)** - Python型安全性
- **[ANTI-PATTERNS.md](./ANTI-PATTERNS.md)** - 避けるべきパターン
- **[REFERENCE.md](./REFERENCE.md)** - チェックリストとツール設定
