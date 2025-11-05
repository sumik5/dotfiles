# テストの種類とテストピラミッド

このファイルでは、各種テストの目的、実装方法、ベストプラクティスを詳しく説明します。

## 📋 目次

- [テストピラミッド](#テストピラミッド)
- [単体テスト（Unit Test）](#単体テストunit-test)
- [統合テスト（Integration Test）](#統合テストintegration-test)
- [E2Eテスト（End-to-End Test）](#e2eテストend-to-end-test)
- [テストの選び方](#テストの選び方)

## 🔺 テストピラミッド

### 基本構造

```
        /\
       /  \      E2E（少数・遅い・高コスト）
      /____\     統合テスト（中程度・中速・中コスト）
     /______\    単体テスト（多数・高速・低コスト）
```

### 理想的な配分比率

```
- 単体テスト: 70%
- 統合テスト: 20%
- E2Eテスト: 10%
```

### ピラミッド構造の理由

**下層（単体テスト）が多い理由:**
- 高速に実行できる
- 失敗原因の特定が容易
- メンテナンスコストが低い
- 開発中に頻繁に実行できる

**上層（E2E）が少ない理由:**
- 実行時間が長い
- 環境構築が複雑
- 失敗原因の特定が困難
- メンテナンスコストが高い

### アンチパターン: 逆ピラミッド

```
     ______      E2Eテストばかり
    /      \     統合テスト少ない
   /________\    単体テスト最小限
      /  \
     /____\
```

**問題点:**
- テスト実行に時間がかかる
- CI/CDパイプラインが遅くなる
- デバッグが困難
- メンテナンスコストが高い

## 🔬 単体テスト（Unit Test）

### 目的と特徴

**目的:**
- 個別の関数・メソッド・クラスの動作を検証
- 他のコンポーネントから独立して実行
- ビジネスロジックの正確性を保証

**特徴:**
- **高速**: ミリ秒単位で実行
- **独立性**: 外部依存なし（DB、API等はモック）
- **細かい粒度**: 1つの関数/メソッドのみをテスト
- **高頻度**: 開発中に何度も実行

### 実装例（TypeScript + Jest）

#### 基本的な単体テスト

```typescript
// sum.ts
export function sum(a: number, b: number): number {
  return a + b
}

// sum.test.ts
import { sum } from './sum'

describe('sum', () => {
  it('should add two positive numbers', () => {
    expect(sum(2, 3)).toBe(5)
  })

  it('should add negative numbers', () => {
    expect(sum(-2, -3)).toBe(-5)
  })

  it('should handle zero', () => {
    expect(sum(0, 5)).toBe(5)
  })
})
```

#### モックを使用した単体テスト

```typescript
// user-service.ts
export class UserService {
  constructor(private db: Database) {}

  async getUser(id: string): Promise<User | null> {
    return await this.db.findUser(id)
  }
}

// user-service.test.ts
import { UserService } from './user-service'

describe('UserService', () => {
  let mockDb: jest.Mocked<Database>
  let service: UserService

  beforeEach(() => {
    // データベースをモック化
    mockDb = {
      findUser: jest.fn()
    } as any

    service = new UserService(mockDb)
  })

  it('should return user when found', async () => {
    const mockUser = { id: '1', name: 'John' }
    mockDb.findUser.mockResolvedValue(mockUser)

    const result = await service.getUser('1')

    expect(result).toEqual(mockUser)
    expect(mockDb.findUser).toHaveBeenCalledWith('1')
  })

  it('should return null when user not found', async () => {
    mockDb.findUser.mockResolvedValue(null)

    const result = await service.getUser('999')

    expect(result).toBeNull()
  })
})
```

#### エッジケースのテスト

```typescript
// validation.ts
export function validateEmail(email: string): boolean {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return regex.test(email)
}

// validation.test.ts
describe('validateEmail', () => {
  // 正常系
  it('should accept valid email', () => {
    expect(validateEmail('user@example.com')).toBe(true)
  })

  // 異常系
  it('should reject email without @', () => {
    expect(validateEmail('userexample.com')).toBe(false)
  })

  it('should reject email without domain', () => {
    expect(validateEmail('user@')).toBe(false)
  })

  // エッジケース
  it('should reject empty string', () => {
    expect(validateEmail('')).toBe(false)
  })

  it('should reject email with spaces', () => {
    expect(validateEmail('user @example.com')).toBe(false)
  })
})
```

### 単体テストのベストプラクティス

**1. 1テスト1アサーション原則**
```typescript
// ❌ 悪い例: 複数の検証
it('should create and validate user', () => {
  const user = createUser({ name: 'John' })
  expect(user.name).toBe('John')
  expect(user.id).toBeDefined()
  expect(user.createdAt).toBeInstanceOf(Date)
})

// ✅ 良い例: 分割
it('should set user name', () => {
  const user = createUser({ name: 'John' })
  expect(user.name).toBe('John')
})

it('should generate user id', () => {
  const user = createUser({ name: 'John' })
  expect(user.id).toBeDefined()
})
```

**2. テスト名は仕様を説明**
```typescript
// ❌ 悪い例
it('test user creation', () => { ... })

// ✅ 良い例
it('should throw error when email is invalid', () => { ... })
```

**3. 外部依存はモック**
```typescript
// ✅ 良い例: データベースをモック
const mockDb = { save: jest.fn() }

// ❌ 悪い例: 実際のDBに接続（これは統合テスト）
const db = new Database('localhost:5432')
```

## 🔗 統合テスト（Integration Test）

### 目的と特徴

**目的:**
- 複数のコンポーネント間の連携を検証
- データベース、外部API等との統合を確認
- システムの一部分が正しく動作することを保証

**特徴:**
- **中速**: 秒単位で実行
- **部分的統合**: システムの一部分を結合
- **実環境に近い**: テスト用DBやAPIを使用
- **中頻度**: コミット前やCI/CDで実行

### 実装例（TypeScript + Jest）

#### データベース統合テスト

```typescript
// user-repository.test.ts
import { UserRepository } from './user-repository'
import { setupTestDatabase, teardownTestDatabase } from './test-utils'

describe('UserRepository Integration Tests', () => {
  let db: Database
  let repository: UserRepository

  beforeAll(async () => {
    // テスト用DBのセットアップ
    db = await setupTestDatabase()
  })

  afterAll(async () => {
    // テスト用DBのクリーンアップ
    await teardownTestDatabase(db)
  })

  beforeEach(async () => {
    // 各テスト前にデータをクリア
    await db.query('DELETE FROM users')
    repository = new UserRepository(db)
  })

  it('should save and retrieve user', async () => {
    // Arrange
    const userData = {
      name: 'John Doe',
      email: 'john@example.com'
    }

    // Act
    const savedUser = await repository.save(userData)
    const retrievedUser = await repository.findById(savedUser.id)

    // Assert
    expect(retrievedUser).toEqual(savedUser)
  })

  it('should update existing user', async () => {
    const user = await repository.save({
      name: 'John',
      email: 'john@example.com'
    })

    const updated = await repository.update(user.id, {
      name: 'John Doe'
    })

    expect(updated.name).toBe('John Doe')
    expect(updated.email).toBe('john@example.com')
  })
})
```

#### API統合テスト

```typescript
// api.test.ts
import request from 'supertest'
import { app } from './app'
import { setupTestDatabase } from './test-utils'

describe('User API Integration Tests', () => {
  beforeAll(async () => {
    await setupTestDatabase()
  })

  describe('POST /users', () => {
    it('should create new user', async () => {
      const response = await request(app)
        .post('/users')
        .send({
          name: 'John Doe',
          email: 'john@example.com'
        })
        .expect(201)

      expect(response.body).toMatchObject({
        name: 'John Doe',
        email: 'john@example.com'
      })
      expect(response.body.id).toBeDefined()
    })

    it('should return 400 for invalid email', async () => {
      await request(app)
        .post('/users')
        .send({
          name: 'John',
          email: 'invalid-email'
        })
        .expect(400)
    })
  })

  describe('GET /users/:id', () => {
    it('should return user by id', async () => {
      // まずユーザーを作成
      const createResponse = await request(app)
        .post('/users')
        .send({ name: 'John', email: 'john@example.com' })

      const userId = createResponse.body.id

      // 作成したユーザーを取得
      const response = await request(app)
        .get(`/users/${userId}`)
        .expect(200)

      expect(response.body).toMatchObject({
        id: userId,
        name: 'John'
      })
    })
  })
})
```

### 統合テストのベストプラクティス

**1. テストデータの独立性**
```typescript
beforeEach(async () => {
  // 各テスト前にデータをクリア
  await db.query('TRUNCATE TABLE users CASCADE')
})
```

**2. テスト環境の分離**
```typescript
// ❌ 悪い例: 本番DBを使用
const db = new Database(process.env.PRODUCTION_DB_URL)

// ✅ 良い例: テスト専用DB
const db = new Database(process.env.TEST_DB_URL)
```

**3. トランザクションの活用**
```typescript
let transaction: Transaction

beforeEach(async () => {
  transaction = await db.beginTransaction()
})

afterEach(async () => {
  await transaction.rollback() // テスト後にロールバック
})
```

## 🌐 E2Eテスト（End-to-End Test）

### 目的と特徴

**目的:**
- ユーザー視点でのシステム全体の動作を検証
- 実際のユーザーフローをシミュレート
- UI、バックエンド、データベース全てを含む統合確認

**特徴:**
- **低速**: 数秒〜数分かかる
- **完全統合**: システム全体を結合
- **実環境**: 本番に近い環境で実行
- **低頻度**: リリース前やCIで実行

### 実装例（Playwright）

#### 基本的なE2Eテスト

```typescript
// login.spec.ts
import { test, expect } from '@playwright/test'

test.describe('User Login Flow', () => {
  test('should successfully login with valid credentials', async ({ page }) => {
    // Arrange: ログインページに移動
    await page.goto('/login')

    // Act: 認証情報を入力
    await page.fill('input[name="email"]', 'user@example.com')
    await page.fill('input[name="password"]', 'password123')
    await page.click('button[type="submit"]')

    // Assert: ダッシュボードにリダイレクト
    await expect(page).toHaveURL('/dashboard')
    await expect(page.locator('h1')).toContainText('Welcome')
  })

  test('should show error message with invalid credentials', async ({ page }) => {
    await page.goto('/login')

    await page.fill('input[name="email"]', 'wrong@example.com')
    await page.fill('input[name="password"]', 'wrongpassword')
    await page.click('button[type="submit"]')

    // エラーメッセージが表示される
    await expect(page.locator('.error-message')).toBeVisible()
    await expect(page.locator('.error-message')).toContainText('Invalid credentials')
  })
})
```

#### 複雑なユーザーフロー

```typescript
// checkout.spec.ts
test('should complete purchase flow', async ({ page }) => {
  // 1. ログイン
  await page.goto('/login')
  await page.fill('[name="email"]', 'user@example.com')
  await page.fill('[name="password"]', 'password')
  await page.click('[type="submit"]')

  // 2. 商品をカートに追加
  await page.goto('/products')
  await page.click('button[data-product-id="123"]')
  await expect(page.locator('.cart-count')).toContainText('1')

  // 3. カートを確認
  await page.click('[href="/cart"]')
  await expect(page.locator('.cart-item')).toHaveCount(1)

  // 4. チェックアウト
  await page.click('button:has-text("Checkout")')

  // 5. 配送情報を入力
  await page.fill('[name="address"]', '123 Main St')
  await page.fill('[name="city"]', 'Tokyo')
  await page.fill('[name="zipcode"]', '100-0001')

  // 6. 支払い情報を入力
  await page.fill('[name="cardNumber"]', '4242424242424242')
  await page.fill('[name="expiry"]', '12/25')
  await page.fill('[name="cvv"]', '123')

  // 7. 注文確定
  await page.click('button:has-text("Place Order")')

  // 8. 確認ページ
  await expect(page.locator('.success-message')).toBeVisible()
  await expect(page.locator('.order-number')).toBeVisible()
})
```

#### ビジュアルリグレッションテスト

```typescript
test('should match screenshot', async ({ page }) => {
  await page.goto('/dashboard')

  // スクリーンショットを比較
  await expect(page).toHaveScreenshot('dashboard.png', {
    maxDiffPixels: 100 // 許容する差分ピクセル数
  })
})
```

### E2Eテストのベストプラクティス

**1. Page Object Patternの使用**
```typescript
// pages/login-page.ts
export class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/login')
  }

  async login(email: string, password: string) {
    await this.page.fill('[name="email"]', email)
    await this.page.fill('[name="password"]', password)
    await this.page.click('[type="submit"]')
  }

  async getErrorMessage() {
    return await this.page.locator('.error-message').textContent()
  }
}

// login.spec.ts
test('should login', async ({ page }) => {
  const loginPage = new LoginPage(page)
  await loginPage.goto()
  await loginPage.login('user@example.com', 'password')

  await expect(page).toHaveURL('/dashboard')
})
```

**2. テストデータの準備**
```typescript
test.beforeEach(async ({ page, request }) => {
  // APIでテストユーザーを作成
  await request.post('/api/test/users', {
    data: {
      email: 'test@example.com',
      password: 'password'
    }
  })
})
```

**3. 待機戦略**
```typescript
// ❌ 悪い例: 固定時間待機
await page.waitForTimeout(3000)

// ✅ 良い例: 要素の出現を待つ
await page.waitForSelector('.dashboard')

// ✅ 良い例: ネットワーク完了を待つ
await page.waitForLoadState('networkidle')
```

## 🎯 テストの選び方

### 意思決定フローチャート

```
テストしたい内容は？
    ↓
個別の関数/メソッド？
    ├─ Yes → 単体テスト
    └─ No → 複数のコンポーネント？
        ├─ Yes → 統合テスト
        └─ No → ユーザーフロー全体？
            └─ Yes → E2Eテスト
```

### 具体例による選択

| テスト対象 | テスト種類 | 理由 |
|-----------|-----------|------|
| バリデーション関数 | 単体テスト | 他の依存なし、高速に検証可能 |
| API エンドポイント | 統合テスト | DB との連携を含む |
| ログインからダッシュボード表示 | E2Eテスト | UI から DB まで全体の流れ |
| 計算ロジック | 単体テスト | 純粋関数、外部依存なし |
| データ永続化 | 統合テスト | DB との連携が必須 |
| 決済フロー | E2Eテスト | 複数画面、外部API連携 |

### バランスの取り方

**推奨アプローチ:**
1. **まず単体テストで基礎を固める**
   - ビジネスロジックは100%カバー
   - バグの早期発見

2. **統合テストで連携を確認**
   - 重要なAPI は統合テスト
   - DBとの連携部分を検証

3. **E2Eで主要フローを保証**
   - クリティカルなユーザーフローのみ
   - 最小限の数に抑える

**時間配分の目安:**
- 単体テスト作成: 50%
- 統合テスト作成: 30%
- E2Eテスト作成: 20%

## 🔗 関連ファイル

- **[SKILL.md](./SKILL.md)** - 概要に戻る
- **[TDD.md](./TDD.md)** - TDDサイクル
- **[TESTABLE-DESIGN.md](./TESTABLE-DESIGN.md)** - テスタブルな設計
- **[REFERENCE.md](./REFERENCE.md)** - ベストプラクティス
