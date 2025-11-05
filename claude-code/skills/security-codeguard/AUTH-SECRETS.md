# 認証・認可と機密情報管理

[← セキュアコーディング に戻る](SKILL.md)

## 📖 目次

- [認証の実装](#認証の実装)
- [認可とアクセス制御](#認可とアクセス制御)
- [パスワード管理](#パスワード管理)
- [機密情報管理](#機密情報管理)
- [セッション管理](#セッション管理)
- [JWT（JSON Web Token）](#jwtjson-web-token)
- [多要素認証（MFA）](#多要素認証mfa)
- [OAuth 2.0 / OpenID Connect](#oauth-20--openid-connect)

## 認証の実装

### ✅ セキュアな認証フロー

```typescript
import bcrypt from 'bcrypt'
import { z } from 'zod'

// ログインスキーマ
const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1)
})

// ログイン処理
async function login(credentials: unknown) {
  // 入力検証
  const { email, password } = LoginSchema.parse(credentials)

  // ユーザー検索
  const user = await userRepository.findByEmail(email)

  // ユーザーが存在しない場合
  if (!user) {
    // タイミング攻撃対策: 成功時と同じ時間を消費
    await bcrypt.hash('dummy', 10)
    throw new AuthenticationError('メールアドレスまたはパスワードが正しくありません')
  }

  // アカウントロック確認
  if (user.loginAttempts >= 5) {
    const lockoutExpiry = new Date(user.lastLoginAttempt.getTime() + 30 * 60 * 1000)
    if (new Date() < lockoutExpiry) {
      throw new AccountLockedError('アカウントがロックされています')
    }
    // ロック期間終了後、ログイン試行回数をリセット
    await userRepository.resetLoginAttempts(user.id)
  }

  // パスワード検証
  const isValid = await bcrypt.compare(password, user.password)

  if (!isValid) {
    // ログイン失敗回数を増やす
    await userRepository.incrementLoginAttempts(user.id)

    // セキュリティログ
    logger.warn('Failed login attempt', {
      userId: user.id,
      email: email,
      ip: req.ip,
      userAgent: req.get('user-agent')
    })

    throw new AuthenticationError('メールアドレスまたはパスワードが正しくありません')
  }

  // ログイン成功
  await userRepository.resetLoginAttempts(user.id)

  // セキュリティログ
  logger.info('Successful login', {
    userId: user.id,
    ip: req.ip
  })

  // セッションまたはトークン生成
  const token = await generateToken(user)

  return {
    user: {
      id: user.id,
      email: user.email,
      role: user.role
    },
    token
  }
}
```

### ✅ アカウントロック機能

```typescript
interface User {
  id: string
  email: string
  password: string
  loginAttempts: number
  lastLoginAttempt: Date
  accountLockedUntil?: Date
}

class UserRepository {
  async incrementLoginAttempts(userId: string): Promise<void> {
    const user = await this.findById(userId)

    const attempts = user.loginAttempts + 1
    const lockedUntil = attempts >= 5
      ? new Date(Date.now() + 30 * 60 * 1000)  // 30分ロック
      : undefined

    await this.update(userId, {
      loginAttempts: attempts,
      lastLoginAttempt: new Date(),
      accountLockedUntil: lockedUntil
    })
  }

  async resetLoginAttempts(userId: string): Promise<void> {
    await this.update(userId, {
      loginAttempts: 0,
      accountLockedUntil: null
    })
  }

  async isAccountLocked(userId: string): Promise<boolean> {
    const user = await this.findById(userId)

    if (!user.accountLockedUntil) {
      return false
    }

    return new Date() < user.accountLockedUntil
  }
}
```

## 認可とアクセス制御

### ✅ ロールベースアクセス制御（RBAC）

```typescript
// 権限定義
enum Permission {
  // ユーザー管理
  READ_USERS = 'read:users',
  CREATE_USERS = 'create:users',
  UPDATE_USERS = 'update:users',
  DELETE_USERS = 'delete:users',

  // 投稿管理
  READ_POSTS = 'read:posts',
  CREATE_POSTS = 'create:posts',
  UPDATE_OWN_POSTS = 'update:own:posts',
  UPDATE_ANY_POSTS = 'update:any:posts',
  DELETE_OWN_POSTS = 'delete:own:posts',
  DELETE_ANY_POSTS = 'delete:any:posts',

  // システム管理
  MANAGE_SETTINGS = 'manage:settings',
  VIEW_AUDIT_LOGS = 'view:audit_logs'
}

// ロール定義
const ROLES = {
  user: [
    Permission.READ_USERS,
    Permission.READ_POSTS,
    Permission.CREATE_POSTS,
    Permission.UPDATE_OWN_POSTS,
    Permission.DELETE_OWN_POSTS
  ],
  moderator: [
    Permission.READ_USERS,
    Permission.READ_POSTS,
    Permission.CREATE_POSTS,
    Permission.UPDATE_ANY_POSTS,
    Permission.DELETE_ANY_POSTS
  ],
  admin: Object.values(Permission)
}

// 権限チェック関数
function hasPermission(user: User, permission: Permission): boolean {
  const userPermissions = ROLES[user.role]
  return userPermissions.includes(permission)
}

// ミドルウェア
function requirePermission(...permissions: Permission[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = req.user

    if (!user) {
      throw new UnauthorizedError('認証が必要です')
    }

    const hasRequiredPermission = permissions.some(permission =>
      hasPermission(user, permission)
    )

    if (!hasRequiredPermission) {
      throw new ForbiddenError('権限がありません')
    }

    next()
  }
}

// 使用例
app.delete('/api/users/:id',
  authenticate,
  requirePermission(Permission.DELETE_USERS),
  deleteUserHandler
)

app.put('/api/posts/:id',
  authenticate,
  requirePermission(
    Permission.UPDATE_OWN_POSTS,
    Permission.UPDATE_ANY_POSTS
  ),
  updatePostHandler
)
```

### ✅ リソースベースアクセス制御

```typescript
// 所有者チェック
async function canUpdatePost(user: User, postId: string): Promise<boolean> {
  // 管理者は常に許可
  if (user.role === 'admin') {
    return true
  }

  // 投稿を取得
  const post = await postRepository.findById(postId)

  // 所有者チェック
  return post.authorId === user.id
}

// リソースベースミドルウェア
function requireResourceOwnership(
  resourceGetter: (req: Request) => Promise<{ ownerId: string }>
) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const user = req.user

    if (!user) {
      throw new UnauthorizedError('認証が必要です')
    }

    // 管理者は常に許可
    if (user.role === 'admin') {
      return next()
    }

    const resource = await resourceGetter(req)

    if (resource.ownerId !== user.id) {
      throw new ForbiddenError('このリソースにアクセスする権限がありません')
    }

    next()
  }
}

// 使用例
app.put('/api/posts/:id',
  authenticate,
  requireResourceOwnership(async (req) => {
    const post = await postRepository.findById(req.params.id)
    return { ownerId: post.authorId }
  }),
  updatePostHandler
)
```

## パスワード管理

### ✅ セキュアなパスワードハッシュ化

```typescript
import bcrypt from 'bcrypt'

// パスワードハッシュ化
async function hashPassword(plainPassword: string): Promise<string> {
  const saltRounds = 10  // 推奨値: 10-12
  return bcrypt.hash(plainPassword, saltRounds)
}

// パスワード検証
async function verifyPassword(
  plainPassword: string,
  hashedPassword: string
): Promise<boolean> {
  return bcrypt.compare(plainPassword, hashedPassword)
}

// ユーザー作成
async function createUser(data: UserCreateData) {
  // パスワード検証
  validatePassword(data.password)

  // パスワードハッシュ化
  const hashedPassword = await hashPassword(data.password)

  return userRepository.create({
    ...data,
    password: hashedPassword
  })
}
```

### ✅ パスワード複雑度要件

```typescript
import { z } from 'zod'

// パスワードスキーマ
const PasswordSchema = z.string()
  .min(8, 'パスワードは8文字以上必要です')
  .max(128, 'パスワードは128文字以内です')
  .regex(/[A-Z]/, '大文字を1文字以上含む必要があります')
  .regex(/[a-z]/, '小文字を1文字以上含む必要があります')
  .regex(/[0-9]/, '数字を1文字以上含む必要があります')
  .regex(/[^A-Za-z0-9]/, '記号を1文字以上含む必要があります')
  .refine(
    (password) => !COMMON_PASSWORDS.includes(password.toLowerCase()),
    { message: 'よく使われるパスワードは使用できません' }
  )

// よく使われるパスワードのリスト
const COMMON_PASSWORDS = [
  'password',
  '12345678',
  'password123',
  'admin',
  'letmein',
  // ... (実際はもっと多くのパスワードをリストアップ)
]

// パスワード検証関数
function validatePassword(password: string): void {
  PasswordSchema.parse(password)
}
```

### ✅ パスワードリセット

```typescript
import crypto from 'crypto'

// リセットトークン生成
function generateResetToken(): string {
  return crypto.randomBytes(32).toString('hex')
}

// パスワードリセットリクエスト
async function requestPasswordReset(email: string) {
  const user = await userRepository.findByEmail(email)

  if (!user) {
    // セキュリティ: ユーザーが存在しない場合でも成功レスポンス
    logger.warn('Password reset requested for non-existent email', { email })
    return { success: true }
  }

  // リセットトークン生成
  const resetToken = generateResetToken()
  const resetTokenExpiry = new Date(Date.now() + 1 * 60 * 60 * 1000)  // 1時間有効

  // トークンをハッシュ化して保存
  const hashedToken = crypto
    .createHash('sha256')
    .update(resetToken)
    .digest('hex')

  await userRepository.update(user.id, {
    resetToken: hashedToken,
    resetTokenExpiry
  })

  // メール送信
  await sendPasswordResetEmail(user.email, resetToken)

  return { success: true }
}

// パスワードリセット実行
async function resetPassword(token: string, newPassword: string) {
  // トークンをハッシュ化
  const hashedToken = crypto
    .createHash('sha256')
    .update(token)
    .digest('hex')

  // ユーザー検索
  const user = await userRepository.findByResetToken(hashedToken)

  if (!user) {
    throw new InvalidTokenError('無効なリセットトークンです')
  }

  // トークン有効期限チェック
  if (new Date() > user.resetTokenExpiry) {
    throw new ExpiredTokenError('リセットトークンの有効期限が切れています')
  }

  // パスワード検証
  validatePassword(newPassword)

  // パスワード更新
  const hashedPassword = await hashPassword(newPassword)

  await userRepository.update(user.id, {
    password: hashedPassword,
    resetToken: null,
    resetTokenExpiry: null
  })

  // セキュリティログ
  logger.info('Password reset completed', { userId: user.id })

  return { success: true }
}
```

## 機密情報管理

### ✅ 環境変数による管理

```typescript
// ❌ ハードコーディング（絶対禁止）
const dbPassword = "secret123"  // 危険
const apiKey = "key456"  // 危険
const jwtSecret = "mysecret"  // 危険

// ✅ 環境変数から取得
const dbPassword = process.env.DB_PASSWORD!
const apiKey = process.env.API_KEY!
const jwtSecret = process.env.JWT_SECRET!

// 環境変数の検証
function validateEnv() {
  const requiredEnvVars = [
    'DB_PASSWORD',
    'API_KEY',
    'JWT_SECRET',
    'ENCRYPTION_KEY'
  ]

  const missingVars = requiredEnvVars.filter(
    varName => !process.env[varName]
  )

  if (missingVars.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missingVars.join(', ')}`
    )
  }
}

// アプリケーション起動時に検証
validateEnv()
```

### ✅ .envファイルの管理

```bash
# .env（開発環境用）
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp_dev
DB_USER=developer
DB_PASSWORD=dev_password_123

JWT_SECRET=dev_jwt_secret_key_change_in_production
API_KEY=dev_api_key_12345

# HTTPS設定（本番環境のみ）
HTTPS_ENABLED=false

# ログレベル
LOG_LEVEL=debug
```

```gitignore
# .gitignore（必須）
.env
.env.local
.env.*.local
*.pem
*.key
*.crt
secrets/
```

```bash
# .env.example（バージョン管理対象）
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=your_db_user
DB_PASSWORD=your_db_password

JWT_SECRET=your_jwt_secret_min_32_chars
API_KEY=your_api_key

HTTPS_ENABLED=true

LOG_LEVEL=info
```

### ✅ シークレット管理サービスの使用

```typescript
// AWS Secrets Manager
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager'

const client = new SecretsManagerClient({ region: 'ap-northeast-1' })

async function getSecret(secretName: string): Promise<string> {
  const command = new GetSecretValueCommand({ SecretId: secretName })
  const response = await client.send(command)

  if (!response.SecretString) {
    throw new Error('Secret not found')
  }

  return response.SecretString
}

// 使用例
const dbCredentials = JSON.parse(await getSecret('prod/database/credentials'))

// HashiCorp Vault
import vault from 'node-vault'

const vaultClient = vault({
  apiVersion: 'v1',
  endpoint: process.env.VAULT_ADDR,
  token: process.env.VAULT_TOKEN
})

async function getVaultSecret(path: string): Promise<any> {
  const result = await vaultClient.read(path)
  return result.data
}
```

## セッション管理

### ✅ セキュアなセッション設定

```typescript
import session from 'express-session'
import RedisStore from 'connect-redis'
import { createClient } from 'redis'

// Redisクライアント作成
const redisClient = createClient({
  url: process.env.REDIS_URL
})
redisClient.connect()

// セッション設定
app.use(session({
  store: new RedisStore({ client: redisClient }),
  secret: process.env.SESSION_SECRET!,
  resave: false,
  saveUninitialized: false,
  name: 'sessionId',  // デフォルトの'connect.sid'を変更
  cookie: {
    secure: true,  // HTTPS必須
    httpOnly: true,  // JavaScriptからアクセス不可
    maxAge: 24 * 60 * 60 * 1000,  // 24時間
    sameSite: 'strict'  // CSRF対策
  }
}))
```

### ✅ セッション固定攻撃対策

```typescript
// ログイン成功時にセッションIDを再生成
async function login(req: Request, credentials: LoginCredentials) {
  const user = await authenticate(credentials)

  // 古いセッションを破棄
  req.session.destroy((err) => {
    if (err) {
      logger.error('Failed to destroy session', err)
    }
  })

  // 新しいセッション作成
  req.session.regenerate((err) => {
    if (err) {
      throw new SessionError('Failed to create session')
    }

    // ユーザー情報をセッションに保存
    req.session.userId = user.id
    req.session.role = user.role

    req.session.save()
  })

  return user
}
```

## JWT（JSON Web Token）

### ✅ JWTの生成と検証

```typescript
import jwt from 'jsonwebtoken'

interface TokenPayload {
  userId: string
  email: string
  role: string
}

// トークン生成
function generateToken(user: User): string {
  const payload: TokenPayload = {
    userId: user.id,
    email: user.email,
    role: user.role
  }

  return jwt.sign(
    payload,
    process.env.JWT_SECRET!,
    {
      expiresIn: '1h',  // 1時間で期限切れ
      issuer: 'myapp',
      audience: 'myapp-users'
    }
  )
}

// リフレッシュトークン生成
function generateRefreshToken(user: User): string {
  return jwt.sign(
    { userId: user.id },
    process.env.JWT_REFRESH_SECRET!,
    {
      expiresIn: '7d'  // 7日間有効
    }
  )
}

// トークン検証
function verifyToken(token: string): TokenPayload {
  try {
    return jwt.verify(
      token,
      process.env.JWT_SECRET!,
      {
        issuer: 'myapp',
        audience: 'myapp-users'
      }
    ) as TokenPayload
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      throw new TokenExpiredError('トークンの有効期限が切れています')
    }
    if (error instanceof jwt.JsonWebTokenError) {
      throw new InvalidTokenError('無効なトークンです')
    }
    throw error
  }
}

// 認証ミドルウェア
function authenticate(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new UnauthorizedError('認証トークンが必要です')
  }

  const token = authHeader.substring(7)

  try {
    const payload = verifyToken(token)
    req.user = payload
    next()
  } catch (error) {
    throw new UnauthorizedError('無効な認証トークンです')
  }
}
```

### ✅ トークンリフレッシュ

```typescript
// リフレッシュトークンの保存（Redis）
async function saveRefreshToken(userId: string, refreshToken: string) {
  const key = `refresh_token:${userId}`
  await redisClient.set(key, refreshToken, {
    EX: 7 * 24 * 60 * 60  // 7日間
  })
}

// トークンリフレッシュエンドポイント
app.post('/api/auth/refresh', async (req, res) => {
  const { refreshToken } = req.body

  try {
    // リフレッシュトークン検証
    const payload = jwt.verify(
      refreshToken,
      process.env.JWT_REFRESH_SECRET!
    ) as { userId: string }

    // Redisから保存されたトークンを取得
    const savedToken = await redisClient.get(`refresh_token:${payload.userId}`)

    if (savedToken !== refreshToken) {
      throw new InvalidTokenError('無効なリフレッシュトークンです')
    }

    // ユーザー情報取得
    const user = await userRepository.findById(payload.userId)

    // 新しいアクセストークン生成
    const newAccessToken = generateToken(user)

    res.json({ accessToken: newAccessToken })
  } catch (error) {
    throw new UnauthorizedError('リフレッシュトークンが無効です')
  }
})
```

## 多要素認証（MFA）

### ✅ TOTP（Time-based One-Time Password）

```typescript
import speakeasy from 'speakeasy'
import QRCode from 'qrcode'

// MFAシークレット生成
async function generateMFASecret(user: User) {
  const secret = speakeasy.generateSecret({
    name: `MyApp (${user.email})`,
    issuer: 'MyApp'
  })

  // QRコード生成
  const qrCode = await QRCode.toDataURL(secret.otpauth_url!)

  // シークレットを保存（暗号化推奨）
  await userRepository.update(user.id, {
    mfaSecret: secret.base32,
    mfaEnabled: false  // 確認後に有効化
  })

  return {
    secret: secret.base32,
    qrCode
  }
}

// MFA検証
function verifyMFAToken(secret: string, token: string): boolean {
  return speakeasy.totp.verify({
    secret,
    encoding: 'base32',
    token,
    window: 1  // 前後30秒の時間差を許容
  })
}

// MFA有効化
async function enableMFA(userId: string, token: string) {
  const user = await userRepository.findById(userId)

  if (!user.mfaSecret) {
    throw new Error('MFAシークレットが設定されていません')
  }

  // トークン検証
  const isValid = verifyMFAToken(user.mfaSecret, token)

  if (!isValid) {
    throw new InvalidTokenError('無効なMFAトークンです')
  }

  // MFA有効化
  await userRepository.update(userId, {
    mfaEnabled: true
  })

  return { success: true }
}

// MFA対応ログイン
async function loginWithMFA(credentials: LoginCredentials, mfaToken?: string) {
  const user = await authenticate(credentials)

  if (user.mfaEnabled) {
    if (!mfaToken) {
      return {
        requiresMFA: true,
        tempToken: generateTempToken(user.id)
      }
    }

    const isValid = verifyMFAToken(user.mfaSecret, mfaToken)

    if (!isValid) {
      throw new InvalidTokenError('無効なMFAトークンです')
    }
  }

  const token = generateToken(user)

  return {
    requiresMFA: false,
    token
  }
}
```

## OAuth 2.0 / OpenID Connect

### ✅ OAuth 2.0クライアント実装

```typescript
import passport from 'passport'
import { Strategy as GoogleStrategy } from 'passport-google-oauth20'

// Google OAuth設定
passport.use(new GoogleStrategy({
  clientID: process.env.GOOGLE_CLIENT_ID!,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
  callbackURL: '/auth/google/callback'
},
async (accessToken, refreshToken, profile, done) => {
  try {
    // 既存ユーザー検索
    let user = await userRepository.findByGoogleId(profile.id)

    if (!user) {
      // 新規ユーザー作成
      user = await userRepository.create({
        googleId: profile.id,
        email: profile.emails[0].value,
        name: profile.displayName
      })
    }

    done(null, user)
  } catch (error) {
    done(error)
  }
}))

// OAuth認証ルート
app.get('/auth/google',
  passport.authenticate('google', {
    scope: ['profile', 'email']
  })
)

app.get('/auth/google/callback',
  passport.authenticate('google', { session: false }),
  (req, res) => {
    const user = req.user as User
    const token = generateToken(user)
    res.redirect(`/login?token=${token}`)
  }
)
```

---

[← 入力検証とインジェクション対策](INPUT-VALIDATION.md) | [次へ: セキュアヘッダーとその他の対策 →](SECURE-HEADERS.md)
