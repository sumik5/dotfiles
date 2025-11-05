# 入力検証とインジェクション対策

[← セキュアコーディング に戻る](SKILL.md)

## 📖 目次

- [入力検証の基本原則](#入力検証の基本原則)
- [入力検証の実装](#入力検証の実装)
- [サニタイゼーション](#サニタイゼーション)
- [SQLインジェクション対策](#sqlインジェクション対策)
- [XSS対策](#xss対策)
- [CSRF対策](#csrf対策)
- [コマンドインジェクション対策](#コマンドインジェクション対策)
- [その他のインジェクション対策](#その他のインジェクション対策)

## 入力検証の基本原則

### 重要な原則
1. **すべての外部入力は信頼できない**
   - ユーザー入力
   - URLパラメータ
   - HTTPヘッダー
   - Cookie
   - ファイルアップロード
   - 外部API応答

2. **サーバーサイドでの検証は必須**
   - クライアントサイドの検証は補助的
   - サーバーサイドでの検証を省略してはいけない

3. **ホワイトリスト方式を優先**
   - ブラックリスト（禁止リスト）は脆弱
   - ホワイトリスト（許可リスト）を使用

## 入力検証の実装

### ✅ Zodによる型安全な入力検証

```typescript
import { z } from 'zod'

// 基本的なスキーマ定義
const UserSchema = z.object({
  // メールアドレス検証
  email: z.string().email('有効なメールアドレスを入力してください'),

  // 年齢検証（範囲指定）
  age: z.number().min(0).max(150),

  // ユーザー名検証（正規表現）
  username: z.string()
    .min(3, 'ユーザー名は3文字以上必要です')
    .max(20, 'ユーザー名は20文字以内です')
    .regex(/^[a-zA-Z0-9_]+$/, 'ユーザー名は英数字とアンダースコアのみ使用できます'),

  // パスワード検証（複雑度要件）
  password: z.string()
    .min(8, 'パスワードは8文字以上必要です')
    .regex(/[A-Z]/, '大文字を含む必要があります')
    .regex(/[a-z]/, '小文字を含む必要があります')
    .regex(/[0-9]/, '数字を含む必要があります')
    .regex(/[^A-Za-z0-9]/, '記号を含む必要があります'),

  // URLの検証
  website: z.string().url().optional(),

  // 日付の検証
  birthdate: z.date().max(new Date(), '未来の日付は指定できません'),

  // 列挙型の検証
  role: z.enum(['user', 'admin', 'moderator'])
})

// ネストされたオブジェクトの検証
const PostSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1).max(10000),
  tags: z.array(z.string()).min(1).max(5),
  author: UserSchema,
  metadata: z.object({
    viewCount: z.number().min(0),
    lastUpdated: z.date()
  }).optional()
})

// 使用例
function createUser(input: unknown) {
  try {
    // 入力検証
    const validated = UserSchema.parse(input)

    // 検証済みデータで処理
    return userRepository.create(validated)
  } catch (error) {
    if (error instanceof z.ZodError) {
      // 検証エラーのハンドリング
      const errors = error.errors.map(err => ({
        field: err.path.join('.'),
        message: err.message
      }))
      throw new ValidationError('入力データが不正です', errors)
    }
    throw error
  }
}

// 部分的な更新の検証
const PartialUserSchema = UserSchema.partial()

function updateUser(userId: string, input: unknown) {
  const validated = PartialUserSchema.parse(input)
  return userRepository.update(userId, validated)
}
```

### ✅ カスタムバリデーション

```typescript
// カスタムバリデーション関数
const EmailDomainSchema = z.string().email().refine(
  (email) => {
    const allowedDomains = ['example.com', 'company.com']
    const domain = email.split('@')[1]
    return allowedDomains.includes(domain)
  },
  { message: '許可されていないドメインです' }
)

// 複数フィールドの相互検証
const DateRangeSchema = z.object({
  startDate: z.date(),
  endDate: z.date()
}).refine(
  (data) => data.endDate > data.startDate,
  {
    message: '終了日は開始日より後である必要があります',
    path: ['endDate']
  }
)

// パスワード確認
const PasswordConfirmSchema = z.object({
  password: z.string().min(8),
  confirmPassword: z.string()
}).refine(
  (data) => data.password === data.confirmPassword,
  {
    message: 'パスワードが一致しません',
    path: ['confirmPassword']
  }
)
```

### ✅ Express.jsでの実装例

```typescript
import express from 'express'
import { z } from 'zod'

// バリデーションミドルウェア
function validateBody<T extends z.ZodType>(schema: T) {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      req.body = schema.parse(req.body)
      next()
    } catch (error) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          error: '入力データが不正です',
          details: error.errors
        })
      } else {
        next(error)
      }
    }
  }
}

// クエリパラメータの検証
function validateQuery<T extends z.ZodType>(schema: T) {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      req.query = schema.parse(req.query)
      next()
    } catch (error) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          error: 'クエリパラメータが不正です',
          details: error.errors
        })
      } else {
        next(error)
      }
    }
  }
}

// 使用例
app.post('/api/users',
  validateBody(UserSchema),
  async (req, res) => {
    const user = await createUser(req.body)
    res.json(user)
  }
)

const PaginationSchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(20)
})

app.get('/api/users',
  validateQuery(PaginationSchema),
  async (req, res) => {
    const users = await userRepository.findMany(req.query)
    res.json(users)
  }
)
```

## サニタイゼーション

### ✅ 文字列のサニタイゼーション

```typescript
// HTML特殊文字のエスケープ
function escapeHtml(unsafe: string): string {
  return unsafe
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;')
}

// 空白文字の正規化
function normalizeWhitespace(str: string): string {
  return str.trim().replace(/\s+/g, ' ')
}

// ファイル名のサニタイゼーション
function sanitizeFilename(filename: string): string {
  return filename
    .replace(/[^a-zA-Z0-9.-]/g, '_')  // 英数字とドット、ハイフン以外をアンダースコアに
    .replace(/\.+/g, '.')  // 連続したドットを1つに
    .replace(/^\./, '')  // 先頭のドットを削除
    .substring(0, 255)  // 最大長制限
}

// URLのサニタイゼーション
function sanitizeUrl(url: string): string {
  try {
    const parsed = new URL(url)

    // JavaScriptプロトコルを禁止
    if (parsed.protocol === 'javascript:') {
      throw new Error('JavaScript URLは許可されていません')
    }

    // HTTPSのみ許可（必要に応じて）
    if (parsed.protocol !== 'https:') {
      throw new Error('HTTPSのみ許可されています')
    }

    return parsed.toString()
  } catch {
    throw new Error('無効なURLです')
  }
}
```

### ✅ DOMPurifyによるHTMLサニタイゼーション

```typescript
import DOMPurify from 'dompurify'
import { JSDOM } from 'jsdom'

// サーバーサイド用のDOMPurify設定
const window = new JSDOM('').window
const purify = DOMPurify(window as unknown as Window)

// 基本的な使用
function sanitizeHtml(dirty: string): string {
  return purify.sanitize(dirty)
}

// カスタム設定
function sanitizeHtmlStrict(dirty: string): string {
  return purify.sanitize(dirty, {
    ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'a'],
    ALLOWED_ATTR: ['href'],
    ALLOW_DATA_ATTR: false
  })
}

// リンクのみ許可
function sanitizeLinks(dirty: string): string {
  return purify.sanitize(dirty, {
    ALLOWED_TAGS: ['a'],
    ALLOWED_ATTR: ['href', 'title'],
    ALLOWED_URI_REGEXP: /^https?:\/\//  // HTTPSまたはHTTPのみ
  })
}
```

## SQLインジェクション対策

### ✅ プリペアドステートメント（最重要）

```typescript
// ❌ 文字列連結（SQLインジェクション脆弱性）
async function getUserByIdUnsafe(userId: string) {
  const query = `SELECT * FROM users WHERE id = '${userId}'`
  return db.query(query)  // 危険！
}

// ✅ プリペアドステートメント（安全）
async function getUserById(userId: string) {
  const query = 'SELECT * FROM users WHERE id = $1'
  return db.query(query, [userId])  // 安全
}

// ✅ ORMの使用（Prisma例）
async function getUserById(userId: string) {
  return prisma.user.findUnique({
    where: { id: userId }
  })
}

// ✅ Query Builder（Knex例）
async function getUserById(userId: string) {
  return knex('users')
    .where('id', userId)
    .first()
}
```

### ✅ 複雑なクエリの安全な構築

```typescript
// 動的WHERE句の構築
async function searchUsers(filters: {
  name?: string
  email?: string
  role?: string
  minAge?: number
}) {
  const conditions: string[] = []
  const values: any[] = []
  let paramIndex = 1

  if (filters.name) {
    conditions.push(`name ILIKE $${paramIndex}`)
    values.push(`%${filters.name}%`)
    paramIndex++
  }

  if (filters.email) {
    conditions.push(`email = $${paramIndex}`)
    values.push(filters.email)
    paramIndex++
  }

  if (filters.role) {
    conditions.push(`role = $${paramIndex}`)
    values.push(filters.role)
    paramIndex++
  }

  if (filters.minAge !== undefined) {
    conditions.push(`age >= $${paramIndex}`)
    values.push(filters.minAge)
    paramIndex++
  }

  const whereClause = conditions.length > 0
    ? `WHERE ${conditions.join(' AND ')}`
    : ''

  const query = `
    SELECT id, name, email, role, age
    FROM users
    ${whereClause}
    ORDER BY created_at DESC
  `

  return db.query(query, values)
}

// ORMでの実装（より安全）
async function searchUsersORM(filters: {
  name?: string
  email?: string
  role?: string
  minAge?: number
}) {
  return prisma.user.findMany({
    where: {
      name: filters.name ? { contains: filters.name, mode: 'insensitive' } : undefined,
      email: filters.email,
      role: filters.role,
      age: filters.minAge !== undefined ? { gte: filters.minAge } : undefined
    },
    orderBy: { createdAt: 'desc' }
  })
}
```

### ❌ よくある間違い

```typescript
// ❌ LIKE句での文字列連結
const query = `SELECT * FROM users WHERE name LIKE '%${searchTerm}%'`

// ✅ 正しい実装
const query = 'SELECT * FROM users WHERE name LIKE $1'
const params = [`%${searchTerm}%`]

// ❌ IN句での文字列連結
const ids = [1, 2, 3]
const query = `SELECT * FROM users WHERE id IN (${ids.join(',')})`

// ✅ 正しい実装
const query = `SELECT * FROM users WHERE id = ANY($1::int[])`
const params = [ids]
```

## XSS対策

### ✅ コンテンツエスケープ

```typescript
// React（自動エスケープ）
function UserProfile({ user }: { user: User }) {
  return (
    <div>
      {/* 自動的にエスケープされる */}
      <h1>{user.name}</h1>
      <p>{user.bio}</p>
    </div>
  )
}

// ❌ dangerouslySetInnerHTMLの不適切な使用
function UnsafeComponent({ content }: { content: string }) {
  return <div dangerouslySetInnerHTML={{ __html: content }} />  // 危険
}

// ✅ DOMPurifyでサニタイズしてから使用
import DOMPurify from 'dompurify'

function SafeComponent({ content }: { content: string }) {
  const sanitized = DOMPurify.sanitize(content)
  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />
}
```

### ✅ Content Security Policy（CSP）

```typescript
import helmet from 'helmet'

app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: [
      "'self'",
      // 信頼できるCDNのみ許可
      'https://cdn.jsdelivr.net'
    ],
    styleSrc: [
      "'self'",
      // インラインスタイルのハッシュ（必要な場合のみ）
      "'sha256-xyz...'"
    ],
    imgSrc: ["'self'", 'data:', 'https:'],
    connectSrc: ["'self'", 'https://api.example.com'],
    fontSrc: ["'self'"],
    objectSrc: ["'none'"],
    upgradeInsecureRequests: []
  }
}))
```

## CSRF対策

### ✅ CSRFトークンの実装

```typescript
import csrf from 'csurf'
import cookieParser from 'cookie-parser'

// CSRFミドルウェアの設定
app.use(cookieParser())
const csrfProtection = csrf({ cookie: true })

// フォーム表示
app.get('/form', csrfProtection, (req, res) => {
  res.render('form', { csrfToken: req.csrfToken() })
})

// フォーム送信
app.post('/submit', csrfProtection, (req, res) => {
  // CSRFトークンが自動検証される
  res.send('データが送信されました')
})

// APIエンドポイント（JSON）
app.post('/api/data', csrfProtection, (req, res) => {
  res.json({ success: true })
})
```

### ✅ SameSite Cookie属性

```typescript
app.use(session({
  secret: process.env.SESSION_SECRET!,
  cookie: {
    httpOnly: true,
    secure: true,  // HTTPS必須
    sameSite: 'strict',  // CSRF対策
    maxAge: 24 * 60 * 60 * 1000  // 24時間
  }
}))
```

### ✅ Originヘッダー検証

```typescript
function validateOrigin(req: Request, res: Response, next: NextFunction) {
  const origin = req.get('origin')
  const allowedOrigins = [
    'https://example.com',
    'https://www.example.com'
  ]

  if (origin && !allowedOrigins.includes(origin)) {
    return res.status(403).json({ error: '不正なOrigin' })
  }

  next()
}

app.post('/api/sensitive', validateOrigin, csrfProtection, handler)
```

## コマンドインジェクション対策

### ✅ 安全なコマンド実行

```typescript
import { exec } from 'child_process'
import { promisify } from 'util'

const execAsync = promisify(exec)

// ❌ ユーザー入力をそのままコマンドに使用
async function unsafeCommand(filename: string) {
  const { stdout } = await execAsync(`cat ${filename}`)  // 危険
  return stdout
}

// ✅ ホワイトリスト方式
const ALLOWED_COMMANDS = ['ls', 'pwd', 'whoami'] as const
type AllowedCommand = typeof ALLOWED_COMMANDS[number]

async function safeCommand(command: AllowedCommand) {
  if (!ALLOWED_COMMANDS.includes(command)) {
    throw new Error('許可されていないコマンドです')
  }

  const { stdout } = await execAsync(command)
  return stdout
}

// ✅ ライブラリを使用（コマンド実行を避ける）
import fs from 'fs/promises'

async function readFileSafe(filename: string) {
  // ファイル名の検証
  if (!/^[a-zA-Z0-9._-]+$/.test(filename)) {
    throw new Error('無効なファイル名です')
  }

  // パストラバーサル対策
  if (filename.includes('..')) {
    throw new Error('無効なファイルパスです')
  }

  return fs.readFile(filename, 'utf8')
}
```

## その他のインジェクション対策

### ✅ LDAPインジェクション対策

```typescript
// LDAP特殊文字のエスケープ
function escapeLDAP(input: string): string {
  return input
    .replace(/\\/g, '\\5c')
    .replace(/\*/g, '\\2a')
    .replace(/\(/g, '\\28')
    .replace(/\)/g, '\\29')
    .replace(/\0/g, '\\00')
}

function searchLDAP(username: string) {
  const escapedUsername = escapeLDAP(username)
  const filter = `(uid=${escapedUsername})`
  // LDAPクエリ実行
}
```

### ✅ XMLインジェクション対策

```typescript
import { parseString } from 'xml2js'

// XML Entityの無効化
const parserOptions = {
  explicitArray: false,
  ignoreAttrs: true,
  // XXE攻撃対策
  xmlns: false,
  explicitCharkey: false
}

function parseXMLSafe(xmlString: string): Promise<any> {
  return new Promise((resolve, reject) => {
    parseString(xmlString, parserOptions, (err, result) => {
      if (err) reject(err)
      else resolve(result)
    })
  })
}
```

---

[← セキュアコーディング に戻る](SKILL.md) | [次へ: 認証・認可と機密情報管理 →](AUTH-SECRETS.md)
