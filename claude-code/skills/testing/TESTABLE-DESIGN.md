# テスタブルな設計原則

このファイルでは、テストしやすいコードを書くための設計原則と実装パターンを詳しく説明します。

## 📋 目次

- [テスタビリティの重要性](#テスタビリティの重要性)
- [依存性注入（DI）](#依存性注入di)
- [純粋関数](#純粋関数)
- [インターフェース抽象化](#インターフェース抽象化)
- [その他の設計原則](#その他の設計原則)
- [アンチパターン](#アンチパターン)

## 🎯 テスタビリティの重要性

### テスタブルなコードとは

**定義:**
- 独立してテストできる
- 依存関係が明示的
- 副作用が予測可能
- モック/スタブが容易

**メリット:**
- バグの早期発見
- リファクタリングの安全性
- ドキュメントとしての価値
- 設計品質の向上

### テスタビリティを阻害する要因

**1. 隠れた依存関係**
```typescript
// ❌ 悪い例: グローバル状態に依存
class UserService {
  getUser(id: string) {
    return globalDatabase.find(id) // テスト困難
  }
}
```

**2. 副作用の多さ**
```typescript
// ❌ 悪い例: 多くの副作用
function processOrder(order: Order) {
  sendEmail(order.email)        // メール送信
  updateInventory(order.items)  // 在庫更新
  logToFile(order)              // ファイル書き込み
  return calculateTotal(order)
}
```

**3. 強い結合**
```typescript
// ❌ 悪い例: 具象クラスに直接依存
class OrderService {
  private db = new PostgresDatabase() // 強く結合

  async saveOrder(order: Order) {
    return await this.db.save(order)
  }
}
```

## 💉 依存性注入（DI）

### 基本概念

**原則:**
- 依存するオブジェクトを外部から注入
- コンストラクタ、メソッド、プロパティで受け取る
- 内部で`new`しない

### コンストラクタインジェクション（推奨）

```typescript
// ✅ 良い例: コンストラクタで注入
interface Database {
  save(data: any): Promise<void>
  find(id: string): Promise<any>
}

class UserService {
  // 依存をコンストラクタで受け取る
  constructor(private db: Database) {}

  async createUser(userData: UserData): Promise<User> {
    const user = { ...userData, id: generateId() }
    await this.db.save(user)
    return user
  }

  async getUser(id: string): Promise<User | null> {
    return await this.db.find(id)
  }
}

// テスト時はモックを注入
const mockDb: Database = {
  save: jest.fn(),
  find: jest.fn()
}
const service = new UserService(mockDb)
```

### メソッドインジェクション

```typescript
// ✅ 良い例: メソッドで注入
class ReportGenerator {
  generateReport(data: Data, formatter: Formatter): string {
    const processed = this.processData(data)
    return formatter.format(processed) // 注入されたformatterを使用
  }

  private processData(data: Data) {
    // データ処理ロジック
    return processed
  }
}

// テスト時
const mockFormatter = { format: jest.fn().mockReturnValue('formatted') }
const generator = new ReportGenerator()
const result = generator.generateReport(data, mockFormatter)
```

### プロパティインジェクション

```typescript
// ✅ 良い例: プロパティで注入（フレームワークで使用）
class EmailService {
  // 依存をプロパティとして宣言
  logger?: Logger

  async sendEmail(to: string, subject: string, body: string) {
    try {
      await this.send(to, subject, body)
      this.logger?.info(`Email sent to ${to}`)
    } catch (error) {
      this.logger?.error(`Failed to send email: ${error}`)
      throw error
    }
  }
}

// テスト時
const service = new EmailService()
service.logger = mockLogger
```

### DIのテスト例

```typescript
// user-service.test.ts
describe('UserService', () => {
  let mockDb: jest.Mocked<Database>
  let service: UserService

  beforeEach(() => {
    // モックDBを準備
    mockDb = {
      save: jest.fn(),
      find: jest.fn()
    }

    // DIでモックを注入
    service = new UserService(mockDb)
  })

  it('should create user', async () => {
    const userData = { name: 'John', email: 'john@example.com' }

    await service.createUser(userData)

    expect(mockDb.save).toHaveBeenCalledWith(
      expect.objectContaining(userData)
    )
  })

  it('should get user by id', async () => {
    const mockUser = { id: '1', name: 'John' }
    mockDb.find.mockResolvedValue(mockUser)

    const result = await service.getUser('1')

    expect(result).toEqual(mockUser)
    expect(mockDb.find).toHaveBeenCalledWith('1')
  })
})
```

## 🔬 純粋関数

### 定義と特徴

**純粋関数の条件:**
1. 同じ入力に対して常に同じ出力
2. 副作用がない（外部状態を変更しない）
3. 外部状態に依存しない

**メリット:**
- テストが簡単
- 並列処理が安全
- 結果が予測可能
- メモ化が可能

### 純粋関数の例

```typescript
// ✅ 純粋関数
function add(a: number, b: number): number {
  return a + b
}

function calculateDiscount(price: number, rate: number): number {
  return price * (1 - rate)
}

function formatName(firstName: string, lastName: string): string {
  return `${lastName}, ${firstName}`
}

// テスト
describe('Pure Functions', () => {
  it('should always return same result', () => {
    expect(add(2, 3)).toBe(5)
    expect(add(2, 3)).toBe(5) // 何度実行しても同じ
  })

  it('should not have side effects', () => {
    const price = 100
    calculateDiscount(price, 0.1)
    expect(price).toBe(100) // 元の値は変わらない
  })
})
```

### 副作用のある関数を純粋に

```typescript
// ❌ 不純な関数: 外部状態を変更
let total = 0
function addToTotal(value: number): void {
  total += value // 副作用
}

// ✅ 純粋関数: 新しい値を返す
function calculateNewTotal(currentTotal: number, value: number): number {
  return currentTotal + value
}

// ❌ 不純な関数: 配列を直接変更
function sortItems(items: number[]): number[] {
  return items.sort() // 元の配列を変更
}

// ✅ 純粋関数: 新しい配列を返す
function sortItems(items: number[]): number[] {
  return [...items].sort() // コピーをソート
}
```

### 外部依存を引数に

```typescript
// ❌ 不純な関数: 現在時刻に依存
function isExpired(expiryDate: Date): boolean {
  return expiryDate < new Date() // 実行時刻で結果が変わる
}

// ✅ 純粋関数: 現在時刻を引数に
function isExpired(expiryDate: Date, now: Date): boolean {
  return expiryDate < now
}

// テスト
it('should check expiry correctly', () => {
  const expiryDate = new Date('2024-01-01')
  const now = new Date('2024-06-01')

  expect(isExpired(expiryDate, now)).toBe(true)
})
```

### 副作用の分離

```typescript
// ✅ 良い例: ロジックと副作用を分離
class OrderProcessor {
  // 純粋関数: ビジネスロジック
  calculateOrderTotal(items: Item[]): number {
    return items.reduce((sum, item) => sum + item.price, 0)
  }

  validateOrder(order: Order): ValidationResult {
    const errors: string[] = []

    if (order.items.length === 0) {
      errors.push('Order must have at least one item')
    }

    if (order.total < 0) {
      errors.push('Total cannot be negative')
    }

    return {
      isValid: errors.length === 0,
      errors
    }
  }

  // 副作用を含む関数: 明示的に分離
  async processOrder(order: Order): Promise<void> {
    // 1. 純粋関数で検証
    const validation = this.validateOrder(order)
    if (!validation.isValid) {
      throw new Error(validation.errors.join(', '))
    }

    // 2. 副作用を実行（DB、メール等）
    await this.saveOrder(order)
    await this.sendConfirmationEmail(order)
    await this.updateInventory(order.items)
  }
}
```

## 🏗️ インターフェース抽象化

### 基本原則

**依存性逆転の原則（DIP）:**
- 上位モジュールは下位モジュールに依存しない
- 両者は抽象（インターフェース）に依存する

### インターフェース定義

```typescript
// ✅ 抽象（インターフェース）を定義
interface EmailProvider {
  send(to: string, subject: string, body: string): Promise<void>
}

interface Logger {
  info(message: string): void
  error(message: string, error?: Error): void
}

interface CacheService {
  get(key: string): Promise<any>
  set(key: string, value: any, ttl?: number): Promise<void>
  delete(key: string): Promise<void>
}
```

### 実装の切り替え

```typescript
// 本番実装
class SendGridEmailProvider implements EmailProvider {
  async send(to: string, subject: string, body: string): Promise<void> {
    // SendGrid APIを使用
    await sendgridClient.send({ to, subject, html: body })
  }
}

// テスト用実装
class MockEmailProvider implements EmailProvider {
  sentEmails: Array<{ to: string; subject: string; body: string }> = []

  async send(to: string, subject: string, body: string): Promise<void> {
    this.sentEmails.push({ to, subject, body })
  }
}

// サービス（インターフェースに依存）
class UserRegistrationService {
  constructor(
    private emailProvider: EmailProvider, // 抽象に依存
    private logger: Logger
  ) {}

  async registerUser(userData: UserData): Promise<User> {
    const user = await this.createUser(userData)

    // インターフェース経由で使用
    await this.emailProvider.send(
      user.email,
      'Welcome!',
      'Thank you for registering'
    )

    this.logger.info(`User registered: ${user.id}`)

    return user
  }
}

// テスト
describe('UserRegistrationService', () => {
  it('should send welcome email', async () => {
    const mockEmail = new MockEmailProvider()
    const mockLogger = { info: jest.fn(), error: jest.fn() }
    const service = new UserRegistrationService(mockEmail, mockLogger)

    await service.registerUser({ email: 'user@example.com' })

    expect(mockEmail.sentEmails).toHaveLength(1)
    expect(mockEmail.sentEmails[0].to).toBe('user@example.com')
  })
})
```

### Strategy パターン

```typescript
// ✅ 良い例: 戦略を抽象化
interface PaymentStrategy {
  processPayment(amount: number): Promise<PaymentResult>
}

class CreditCardPayment implements PaymentStrategy {
  async processPayment(amount: number): Promise<PaymentResult> {
    // クレジットカード決済
    return { success: true, transactionId: 'CC123' }
  }
}

class PayPalPayment implements PaymentStrategy {
  async processPayment(amount: number): Promise<PaymentResult> {
    // PayPal決済
    return { success: true, transactionId: 'PP456' }
  }
}

class PaymentService {
  constructor(private strategy: PaymentStrategy) {}

  async pay(amount: number): Promise<PaymentResult> {
    return await this.strategy.processPayment(amount)
  }
}

// テスト
describe('PaymentService', () => {
  it('should process payment with strategy', async () => {
    const mockStrategy: PaymentStrategy = {
      processPayment: jest.fn().mockResolvedValue({
        success: true,
        transactionId: 'TEST123'
      })
    }

    const service = new PaymentService(mockStrategy)
    const result = await service.pay(100)

    expect(result.success).toBe(true)
    expect(mockStrategy.processPayment).toHaveBeenCalledWith(100)
  })
})
```

## 🎨 その他の設計原則

### 単一責任の原則（SRP）

```typescript
// ❌ 悪い例: 複数の責任
class UserManager {
  createUser(data: UserData) { /* ... */ }
  validateEmail(email: string) { /* ... */ }
  sendWelcomeEmail(user: User) { /* ... */ }
  generateReport() { /* ... */ }
}

// ✅ 良い例: 責任を分離
class UserService {
  createUser(data: UserData): User { /* ... */ }
}

class EmailValidator {
  validate(email: string): boolean { /* ... */ }
}

class EmailService {
  sendWelcomeEmail(user: User): void { /* ... */ }
}

class ReportGenerator {
  generateUserReport(): Report { /* ... */ }
}
```

### 小さなメソッド

```typescript
// ❌ 悪い例: 長いメソッド
class OrderService {
  processOrder(order: Order) {
    // バリデーション（20行）
    if (!order.items || order.items.length === 0) { /* ... */ }
    // 在庫確認（30行）
    for (const item of order.items) { /* ... */ }
    // 金額計算（20行）
    let total = 0
    // 決済処理（40行）
    // メール送信（15行）
  }
}

// ✅ 良い例: 小さなメソッドに分割
class OrderService {
  processOrder(order: Order) {
    this.validateOrder(order)
    this.checkInventory(order)
    const total = this.calculateTotal(order)
    this.processPayment(order, total)
    this.sendConfirmation(order)
  }

  private validateOrder(order: Order): void { /* ... */ }
  private checkInventory(order: Order): void { /* ... */ }
  private calculateTotal(order: Order): number { /* ... */ }
  private processPayment(order: Order, total: number): void { /* ... */ }
  private sendConfirmation(order: Order): void { /* ... */ }
}
```

### ファクトリーパターン

```typescript
// ✅ 良い例: ファクトリーで生成を抽象化
interface NotificationService {
  send(message: string): void
}

class NotificationFactory {
  static create(type: 'email' | 'sms' | 'push'): NotificationService {
    switch (type) {
      case 'email':
        return new EmailNotification()
      case 'sms':
        return new SmsNotification()
      case 'push':
        return new PushNotification()
    }
  }
}

// テスト時はモックファクトリーを使用
class MockNotificationFactory {
  static create(): NotificationService {
    return { send: jest.fn() }
  }
}
```

## ⚠️ アンチパターン

### Singleton（シングルトン）

```typescript
// ❌ 悪い例: テストが困難
class DatabaseSingleton {
  private static instance: DatabaseSingleton

  private constructor() {}

  static getInstance(): DatabaseSingleton {
    if (!DatabaseSingleton.instance) {
      DatabaseSingleton.instance = new DatabaseSingleton()
    }
    return DatabaseSingleton.instance
  }

  query(sql: string) { /* ... */ }
}

// 問題: テストでモックできない
class UserService {
  getUser(id: string) {
    const db = DatabaseSingleton.getInstance() // 強く結合
    return db.query(`SELECT * FROM users WHERE id = ${id}`)
  }
}

// ✅ 良い例: DIを使用
class UserService {
  constructor(private db: Database) {} // 注入可能

  getUser(id: string) {
    return this.db.query(`SELECT * FROM users WHERE id = ${id}`)
  }
}
```

### Static メソッドの乱用

```typescript
// ❌ 悪い例: staticメソッドに依存
class Utils {
  static getCurrentTime(): Date {
    return new Date() // テスト困難
  }
}

class OrderService {
  createOrder(items: Item[]) {
    const now = Utils.getCurrentTime() // モック不可
    return { items, createdAt: now }
  }
}

// ✅ 良い例: 時刻を注入
interface Clock {
  now(): Date
}

class OrderService {
  constructor(private clock: Clock) {}

  createOrder(items: Item[]) {
    const now = this.clock.now() // テスト時にモック可能
    return { items, createdAt: now }
  }
}

// テスト
const mockClock = { now: () => new Date('2024-01-01') }
const service = new OrderService(mockClock)
```

### new演算子の直接使用

```typescript
// ❌ 悪い例: 内部でnew
class OrderService {
  processOrder(order: Order) {
    const emailService = new EmailService() // 強く結合
    emailService.send(order.email, 'Confirmation', '...')
  }
}

// ✅ 良い例: 依存を注入
class OrderService {
  constructor(private emailService: EmailService) {}

  processOrder(order: Order) {
    this.emailService.send(order.email, 'Confirmation', '...')
  }
}
```

### グローバル状態への依存

```typescript
// ❌ 悪い例: グローバル変数に依存
let currentUser: User | null = null

class OrderService {
  createOrder(items: Item[]) {
    if (!currentUser) { // グローバル状態に依存
      throw new Error('Not authenticated')
    }
    return { items, userId: currentUser.id }
  }
}

// ✅ 良い例: 状態を明示的に渡す
class OrderService {
  createOrder(items: Item[], user: User) {
    return { items, userId: user.id }
  }
}
```

## 🔗 関連ファイル

- **[SKILL.md](./SKILL.md)** - 概要に戻る
- **[TDD.md](./TDD.md)** - TDDサイクル
- **[TEST-TYPES.md](./TEST-TYPES.md)** - テストの種類
- **[REFERENCE.md](./REFERENCE.md)** - ベストプラクティス
