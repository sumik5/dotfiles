# セキュアヘッダーとその他の対策

[← セキュアコーディング に戻る](SKILL.md)

## 📖 目次

- [セキュアHTTPヘッダー](#セキュアhttpヘッダー)
- [ファイルアップロード対策](#ファイルアップロード対策)
- [レート制限](#レート制限)
- [セキュアなログ管理](#セキュアなログ管理)
- [依存関係のセキュリティ管理](#依存関係のセキュリティ管理)
- [エラーハンドリング](#エラーハンドリング)
- [CORS設定](#cors設定)

## セキュアHTTPヘッダー

### ✅ Helmetによる包括的なセキュリティヘッダー設定

```typescript
import helmet from 'helmet'
import express from 'express'

const app = express()

// Helmetの基本設定
app.use(helmet())

// カスタム設定
app.use(helmet({
  // Content Security Policy
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: [
        "'self'",
        // 信頼できるCDNのみ許可
        'https://cdn.jsdelivr.net',
        'https://unpkg.com'
      ],
      styleSrc: [
        "'self'",
        // インラインスタイルのハッシュ（必要な場合）
        "'sha256-xyz...'"
      ],
      imgSrc: ["'self'", 'data:', 'https:'],
      connectSrc: ["'self'", 'https://api.example.com'],
      fontSrc: ["'self'", 'https://fonts.gstatic.com'],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
      upgradeInsecureRequests: []
    }
  },

  // Strict-Transport-Security (HSTS)
  hsts: {
    maxAge: 31536000,  // 1年
    includeSubDomains: true,
    preload: true
  },

  // X-Frame-Options
  frameguard: {
    action: 'deny'  // または 'sameorigin'
  },

  // X-Content-Type-Options
  noSniff: true,

  // X-XSS-Protection（レガシー）
  xssFilter: true,

  // Referrer-Policy
  referrerPolicy: {
    policy: 'strict-origin-when-cross-origin'
  },

  // Permissions-Policy（旧Feature-Policy）
  permittedCrossDomainPolicies: {
    permittedPolicies: 'none'
  }
}))
```

### ✅ 個別ヘッダーの設定

```typescript
// Content-Security-Policy（より詳細な設定）
app.use((req, res, next) => {
  const nonce = crypto.randomBytes(16).toString('base64')
  res.locals.nonce = nonce

  res.setHeader(
    'Content-Security-Policy',
    `
      default-src 'self';
      script-src 'self' 'nonce-${nonce}' https://trusted-cdn.com;
      style-src 'self' 'unsafe-inline';
      img-src 'self' data: https:;
      font-src 'self' https://fonts.gstatic.com;
      connect-src 'self' https://api.example.com;
      frame-ancestors 'none';
      base-uri 'self';
      form-action 'self';
    `.replace(/\s{2,}/g, ' ').trim()
  )

  next()
})

// Strict-Transport-Security
app.use((req, res, next) => {
  res.setHeader(
    'Strict-Transport-Security',
    'max-age=31536000; includeSubDomains; preload'
  )
  next()
})

// X-Frame-Options
app.use((req, res, next) => {
  res.setHeader('X-Frame-Options', 'DENY')
  next()
})

// X-Content-Type-Options
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff')
  next()
})

// Referrer-Policy
app.use((req, res, next) => {
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin')
  next()
})

// Permissions-Policy
app.use((req, res, next) => {
  res.setHeader(
    'Permissions-Policy',
    'geolocation=(), microphone=(), camera=()'
  )
  next()
})
```

### ✅ Next.jsでのセキュリティヘッダー設定

```javascript
// next.config.js
module.exports = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY'
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff'
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin'
          },
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=31536000; includeSubDomains; preload'
          },
          {
            key: 'Content-Security-Policy',
            value: `
              default-src 'self';
              script-src 'self' 'unsafe-eval' 'unsafe-inline';
              style-src 'self' 'unsafe-inline';
              img-src 'self' data: https:;
              font-src 'self';
            `.replace(/\s{2,}/g, ' ').trim()
          }
        ]
      }
    ]
  }
}
```

## ファイルアップロード対策

### ✅ ファイルアップロードの検証

```typescript
import multer from 'multer'
import path from 'path'
import crypto from 'crypto'

// 許可するファイルタイプ
const ALLOWED_MIME_TYPES = [
  'image/jpeg',
  'image/png',
  'image/gif',
  'image/webp',
  'application/pdf'
]

// ファイルサイズ制限（5MB）
const MAX_FILE_SIZE = 5 * 1024 * 1024

// ファイルタイプ検証
function validateFileType(file: Express.Multer.File): boolean {
  // MIMEタイプチェック
  if (!ALLOWED_MIME_TYPES.includes(file.mimetype)) {
    return false
  }

  // 拡張子チェック
  const ext = path.extname(file.originalname).toLowerCase()
  const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.pdf']

  if (!allowedExtensions.includes(ext)) {
    return false
  }

  return true
}

// ファイル名サニタイゼーション
function sanitizeFilename(filename: string): string {
  // ランダムなファイル名を生成
  const ext = path.extname(filename)
  const randomName = crypto.randomBytes(16).toString('hex')

  return `${randomName}${ext}`
}

// Multer設定
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // アップロードディレクトリ（Webサーバーのドキュメントルート外）
    cb(null, '/var/uploads')
  },
  filename: (req, file, cb) => {
    const safeFilename = sanitizeFilename(file.originalname)
    cb(null, safeFilename)
  }
})

const upload = multer({
  storage,
  limits: {
    fileSize: MAX_FILE_SIZE,
    files: 5  // 最大ファイル数
  },
  fileFilter: (req, file, cb) => {
    if (validateFileType(file)) {
      cb(null, true)
    } else {
      cb(new Error('許可されていないファイルタイプです'))
    }
  }
})

// ファイルアップロードエンドポイント
app.post('/api/upload',
  authenticate,
  upload.single('file'),
  async (req, res) => {
    if (!req.file) {
      throw new BadRequestError('ファイルがアップロードされていません')
    }

    // ファイル情報を保存
    const fileRecord = await fileRepository.create({
      userId: req.user.id,
      filename: req.file.filename,
      originalName: req.file.originalname,
      mimeType: req.file.mimetype,
      size: req.file.size,
      path: req.file.path
    })

    res.json({
      id: fileRecord.id,
      filename: fileRecord.filename
    })
  }
)
```

### ✅ ファイルコンテンツの検証

```typescript
import fileType from 'file-type'
import fs from 'fs/promises'

// ファイルコンテンツの実際のタイプを検証
async function validateFileContent(filePath: string, expectedMimeType: string): Promise<boolean> {
  const buffer = await fs.readFile(filePath)
  const type = await fileType.fromBuffer(buffer)

  if (!type) {
    return false
  }

  return type.mime === expectedMimeType
}

// 画像のメタデータチェック
import sharp from 'sharp'

async function validateImageContent(filePath: string): Promise<boolean> {
  try {
    const metadata = await sharp(filePath).metadata()

    // 画像サイズ制限（例: 10000x10000まで）
    if (metadata.width > 10000 || metadata.height > 10000) {
      return false
    }

    return true
  } catch {
    return false
  }
}

// ファイルアップロード処理（コンテンツ検証付き）
app.post('/api/upload',
  authenticate,
  upload.single('file'),
  async (req, res) => {
    if (!req.file) {
      throw new BadRequestError('ファイルがアップロードされていません')
    }

    // ファイルコンテンツの検証
    const isValidContent = await validateFileContent(
      req.file.path,
      req.file.mimetype
    )

    if (!isValidContent) {
      // 不正なファイルを削除
      await fs.unlink(req.file.path)
      throw new BadRequestError('ファイルコンテンツが不正です')
    }

    // 画像の場合、追加検証
    if (req.file.mimetype.startsWith('image/')) {
      const isValidImage = await validateImageContent(req.file.path)

      if (!isValidImage) {
        await fs.unlink(req.file.path)
        throw new BadRequestError('画像ファイルが不正です')
      }
    }

    // ファイル情報を保存
    const fileRecord = await fileRepository.create({
      userId: req.user.id,
      filename: req.file.filename,
      originalName: req.file.originalname,
      mimeType: req.file.mimetype,
      size: req.file.size,
      path: req.file.path
    })

    res.json({
      id: fileRecord.id,
      filename: fileRecord.filename
    })
  }
)
```

### ✅ ファイルダウンロードの安全な実装

```typescript
// ファイルダウンロード
app.get('/api/files/:fileId',
  authenticate,
  async (req, res) => {
    const file = await fileRepository.findById(req.params.fileId)

    if (!file) {
      throw new NotFoundError('ファイルが見つかりません')
    }

    // 所有者チェック
    if (file.userId !== req.user.id && req.user.role !== 'admin') {
      throw new ForbiddenError('このファイルにアクセスする権限がありません')
    }

    // パストラバーサル対策
    const safePath = path.normalize(file.path).replace(/^(\.\.[\/\\])+/, '')

    // Content-Typeヘッダー設定
    res.setHeader('Content-Type', file.mimeType)

    // Content-Dispositionヘッダー（ダウンロード強制）
    res.setHeader(
      'Content-Disposition',
      `attachment; filename="${encodeURIComponent(file.originalName)}"`
    )

    // X-Content-Type-Options（MIMEスニッフィング防止）
    res.setHeader('X-Content-Type-Options', 'nosniff')

    // ファイル送信
    res.sendFile(safePath, { root: '/var/uploads' })
  }
)
```

## レート制限

### ✅ express-rate-limitによる実装

```typescript
import rateLimit from 'express-rate-limit'
import RedisStore from 'rate-limit-redis'
import { createClient } from 'redis'

// Redisクライアント
const redisClient = createClient({
  url: process.env.REDIS_URL
})
redisClient.connect()

// グローバルレート制限
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15分
  max: 100,  // 最大100リクエスト
  message: 'リクエストが多すぎます。しばらく待ってから再試行してください。',
  standardHeaders: true,
  legacyHeaders: false,
  store: new RedisStore({
    client: redisClient,
    prefix: 'rl:global:'
  })
})

// ログインエンドポイント用の厳しい制限
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15分
  max: 5,  // 最大5回
  skipSuccessfulRequests: true,  // 成功したリクエストはカウントしない
  message: 'ログイン試行回数が多すぎます。15分後に再試行してください。',
  store: new RedisStore({
    client: redisClient,
    prefix: 'rl:login:'
  })
})

// API全体に適用
app.use('/api/', globalLimiter)

// 特定のエンドポイントに適用
app.post('/api/auth/login', loginLimiter, loginHandler)

// パスワードリセット
const passwordResetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,  // 1時間
  max: 3,  // 最大3回
  message: 'パスワードリセットのリクエストが多すぎます。',
  store: new RedisStore({
    client: redisClient,
    prefix: 'rl:reset:'
  })
})

app.post('/api/auth/reset-password',
  passwordResetLimiter,
  resetPasswordHandler
)
```

### ✅ IPベース + ユーザーベースのレート制限

```typescript
import { Request } from 'express'

// カスタムキー生成（IP + ユーザーID）
function generateRateLimitKey(req: Request): string {
  const ip = req.ip
  const userId = req.user?.id || 'anonymous'

  return `${ip}:${userId}`
}

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  keyGenerator: generateRateLimitKey,
  store: new RedisStore({
    client: redisClient,
    prefix: 'rl:api:'
  })
})

app.use('/api/', apiLimiter)
```

### ✅ スロットリング（トークンバケット方式）

```typescript
class TokenBucket {
  private tokens: number
  private lastRefill: number

  constructor(
    private capacity: number,
    private refillRate: number  // トークン/秒
  ) {
    this.tokens = capacity
    this.lastRefill = Date.now()
  }

  async consume(count: number = 1): Promise<boolean> {
    this.refill()

    if (this.tokens >= count) {
      this.tokens -= count
      return true
    }

    return false
  }

  private refill() {
    const now = Date.now()
    const elapsed = (now - this.lastRefill) / 1000
    const tokensToAdd = elapsed * this.refillRate

    this.tokens = Math.min(this.capacity, this.tokens + tokensToAdd)
    this.lastRefill = now
  }
}

// 使用例
const buckets = new Map<string, TokenBucket>()

function throttle(capacity: number, refillRate: number) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const key = req.ip

    if (!buckets.has(key)) {
      buckets.set(key, new TokenBucket(capacity, refillRate))
    }

    const bucket = buckets.get(key)!

    if (await bucket.consume()) {
      next()
    } else {
      res.status(429).json({
        error: 'リクエストが多すぎます'
      })
    }
  }
}

// 秒間10リクエストまで
app.use('/api/expensive', throttle(10, 10))
```

## セキュアなログ管理

### ✅ Winstonによる構造化ログ

```typescript
import winston from 'winston'

// ログフォーマット
const logFormat = winston.format.combine(
  winston.format.timestamp(),
  winston.format.errors({ stack: true }),
  winston.format.json()
)

// ロガー作成
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: logFormat,
  defaultMeta: {
    service: 'myapp',
    environment: process.env.NODE_ENV
  },
  transports: [
    // エラーログファイル
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
      maxsize: 10 * 1024 * 1024,  // 10MB
      maxFiles: 5
    }),

    // 統合ログファイル
    new winston.transports.File({
      filename: 'logs/combined.log',
      maxsize: 10 * 1024 * 1024,
      maxFiles: 10
    }),

    // セキュリティイベント専用ログ
    new winston.transports.File({
      filename: 'logs/security.log',
      level: 'warn',
      maxsize: 10 * 1024 * 1024,
      maxFiles: 10
    })
  ]
})

// 開発環境ではコンソールにも出力
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple()
    )
  }))
}

export { logger }
```

### ✅ セキュリティイベントのログ記録

```typescript
// ログイン成功
logger.info('User login successful', {
  userId: user.id,
  email: user.email,
  ip: req.ip,
  userAgent: req.get('user-agent'),
  timestamp: new Date().toISOString()
})

// ログイン失敗
logger.warn('Failed login attempt', {
  email: email,
  ip: req.ip,
  userAgent: req.get('user-agent'),
  reason: 'invalid_credentials',
  timestamp: new Date().toISOString()
})

// アカウントロック
logger.warn('Account locked due to multiple failed login attempts', {
  userId: user.id,
  email: user.email,
  ip: req.ip,
  attempts: user.loginAttempts,
  timestamp: new Date().toISOString()
})

// 認可エラー
logger.warn('Unauthorized access attempt', {
  userId: req.user?.id,
  resource: req.path,
  method: req.method,
  ip: req.ip,
  timestamp: new Date().toISOString()
})

// セキュリティ設定変更
logger.info('Security settings changed', {
  userId: req.user.id,
  changes: {
    mfaEnabled: true
  },
  ip: req.ip,
  timestamp: new Date().toISOString()
})
```

### ❌ 機密情報のログ記録禁止

```typescript
// ❌ 絶対にやってはいけない
logger.info('User created', {
  user: {
    email: user.email,
    password: user.password  // 絶対禁止
  }
})

logger.error('Login failed', {
  credentials: {
    username: username,
    password: password  // 絶対禁止
  }
})

// ✅ 正しい実装
logger.info('User created', {
  userId: user.id,
  email: user.email
  // パスワードは記録しない
})

logger.warn('Login failed', {
  email: email,
  ip: req.ip
  // パスワードは記録しない
})
```

## 依存関係のセキュリティ管理

### ✅ npm auditの活用

```bash
# 脆弱性スキャン
npm audit

# 脆弱性の自動修正
npm audit fix

# 破壊的変更を含む修正
npm audit fix --force

# 詳細レポート
npm audit --json > audit-report.json
```

### ✅ Snykの使用

```bash
# Snykインストール
npm install -g snyk

# 認証
snyk auth

# 脆弱性スキャン
snyk test

# 継続的監視
snyk monitor

# 自動修正
snyk fix
```

### ✅ Dependabotの設定

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    reviewers:
      - "security-team"
    labels:
      - "dependencies"
      - "security"

  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

### ✅ package.jsonのセキュリティ設定

```json
{
  "scripts": {
    "audit": "npm audit",
    "audit:fix": "npm audit fix",
    "snyk:test": "snyk test",
    "snyk:monitor": "snyk monitor",
    "security:check": "npm run audit && npm run snyk:test"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
```

## エラーハンドリング

### ✅ セキュアなエラーハンドリング

```typescript
// カスタムエラークラス
class AppError extends Error {
  constructor(
    message: string,
    public statusCode: number = 500,
    public isOperational: boolean = true
  ) {
    super(message)
    Object.setPrototypeOf(this, AppError.prototype)
  }
}

class ValidationError extends AppError {
  constructor(message: string, public errors?: any[]) {
    super(message, 400)
  }
}

class UnauthorizedError extends AppError {
  constructor(message: string = '認証が必要です') {
    super(message, 401)
  }
}

class ForbiddenError extends AppError {
  constructor(message: string = '権限がありません') {
    super(message, 403)
  }
}

// エラーハンドリングミドルウェア
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  // エラーログ（詳細情報）
  logger.error('Error occurred', {
    error: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
    userId: req.user?.id
  })

  // クライアントには一般的なエラーメッセージのみ
  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      error: err.message,
      ...(err instanceof ValidationError && { errors: err.errors })
    })
  } else {
    // 予期しないエラー
    res.status(500).json({
      error: '内部サーバーエラーが発生しました'
      // スタックトレースは含めない
    })
  }
})
```

## CORS設定

### ✅ セキュアなCORS設定

```typescript
import cors from 'cors'

// 許可するオリジン
const ALLOWED_ORIGINS = [
  'https://example.com',
  'https://www.example.com',
  'https://app.example.com'
]

// 開発環境でlocalhostを許可
if (process.env.NODE_ENV === 'development') {
  ALLOWED_ORIGINS.push('http://localhost:3000')
}

// CORS設定
app.use(cors({
  origin: (origin, callback) => {
    // オリジンなし（同一オリジン）を許可
    if (!origin) {
      return callback(null, true)
    }

    // ホワイトリストチェック
    if (ALLOWED_ORIGINS.includes(origin)) {
      callback(null, true)
    } else {
      logger.warn('CORS blocked', { origin })
      callback(new Error('CORS policy violation'))
    }
  },
  credentials: true,  // Cookieを許可
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  exposedHeaders: ['X-Total-Count'],
  maxAge: 86400  // プリフライトリクエストのキャッシュ（24時間）
}))

// 特定のエンドポイントのみCORS許可
app.use('/api/public', cors({
  origin: '*',  // すべてのオリジンを許可
  methods: ['GET']
}))
```

---

[← 認証・認可と機密情報管理](AUTH-SECRETS.md) | [セキュアコーディング に戻る →](SKILL.md)
