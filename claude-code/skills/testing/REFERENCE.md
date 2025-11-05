# テストのベストプラクティスとリファレンス

このファイルでは、テスト実装時のベストプラクティス、カバレッジ目標、チェックリスト、コマンドリファレンスを提供します。

## 📋 目次

- [カバレッジ目標](#カバレッジ目標)
- [ベストプラクティス](#ベストプラクティス)
- [テストコマンドリファレンス](#テストコマンドリファレンス)
- [実装チェックリスト](#実装チェックリスト)
- [トラブルシューティング](#トラブルシューティング)

## 🎯 カバレッジ目標

### レイヤー別の推奨カバレッジ

```
ビジネスロジック層:     100%  （必須）
ユーティリティ関数:     100%  （必須）
サービス層:            90%以上（推奨）
コントローラー層:      80%以上（推奨）
UIコンポーネント層:    70%以上（推奨）
統合テスト:            主要フロー（必須）
E2Eテスト:            クリティカルパス（必須）
```

### カバレッジメトリクス

**測定する指標:**
1. **行カバレッジ（Line Coverage）**
   - 実行された行の割合
   - 最も基本的な指標

2. **分岐カバレッジ（Branch Coverage）**
   - if/elseなど、すべての分岐を実行したか
   - 論理的な網羅性を確認

3. **関数カバレッジ（Function Coverage）**
   - 呼び出された関数の割合
   - 未使用コードの検出

4. **ステートメントカバレッジ（Statement Coverage）**
   - 実行されたステートメントの割合
   - 行カバレッジより精密

### カバレッジ確認コマンド

```bash
# Jest でカバレッジレポート生成
npm test -- --coverage

# Vitest でカバレッジレポート生成
npm run test:coverage

# カバレッジ閾値の設定（package.json または jest.config.js）
{
  "jest": {
    "coverageThreshold": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      }
    }
  }
}
```

### カバレッジの優先順位

**高優先度（100%必須）:**
- ビジネスロジック
- バリデーション関数
- セキュリティ関連コード
- 金額計算ロジック
- データ変換関数

**中優先度（80%以上推奨）:**
- API エンドポイント
- サービス層
- コントローラー
- ミドルウェア

**低優先度（努力目標）:**
- UI コンポーネント（ロジック少ない場合）
- 設定ファイル
- 型定義ファイル

## ✅ ベストプラクティス

### テスト構造のベストプラクティス

#### 1. AAA パターンの徹底

```typescript
it('should calculate total with discount', () => {
  // Arrange（準備）
  const items = [100, 200, 300]
  const discountRate = 0.1

  // Act（実行）
  const result = calculateTotal(items, discountRate)

  // Assert（検証）
  expect(result).toBe(540)
})
```

#### 2. テスト名は仕様を説明

```typescript
// ❌ 悪い例
it('test 1', () => { ... })
it('user test', () => { ... })

// ✅ 良い例
it('should throw error when email is invalid', () => { ... })
it('should return null when user not found', () => { ... })
it('should calculate discount correctly for multiple items', () => { ... })
```

#### 3. 1テスト1アサーション（原則）

```typescript
// ❌ 悪い例: 複数のアサーション
it('should create user', () => {
  const user = createUser(userData)
  expect(user.id).toBeDefined()
  expect(user.name).toBe('John')
  expect(user.email).toBe('john@example.com')
  expect(user.createdAt).toBeInstanceOf(Date)
})

// ✅ 良い例: 分割
describe('createUser', () => {
  it('should generate user id', () => {
    const user = createUser(userData)
    expect(user.id).toBeDefined()
  })

  it('should set user name from input', () => {
    const user = createUser({ ...userData, name: 'John' })
    expect(user.name).toBe('John')
  })

  it('should set user email from input', () => {
    const user = createUser({ ...userData, email: 'john@example.com' })
    expect(user.email).toBe('john@example.com')
  })
})
```

#### 4. テストの独立性

```typescript
// ❌ 悪い例: 前のテストに依存
let user: User

it('should create user', () => {
  user = createUser(userData) // グローバル変数に保存
})

it('should update user', () => {
  updateUser(user.id, { name: 'Jane' }) // 前のテストに依存
})

// ✅ 良い例: 各テストが独立
describe('User operations', () => {
  it('should create user', () => {
    const user = createUser(userData)
    expect(user.id).toBeDefined()
  })

  it('should update user', () => {
    const user = createUser(userData) // 独立して準備
    const updated = updateUser(user.id, { name: 'Jane' })
    expect(updated.name).toBe('Jane')
  })
})
```

### モック・スタブのベストプラクティス

#### 1. 必要最小限のモック

```typescript
// ❌ 悪い例: 過度なモック
const mockUser = {
  id: '1',
  name: 'John',
  email: 'john@example.com',
  address: { /* ... */ },
  preferences: { /* ... */ },
  // 不要なフィールドまでモック
}

// ✅ 良い例: 必要な部分のみ
const mockUser = {
  id: '1',
  name: 'John'
}
```

#### 2. モックの再利用

```typescript
// ✅ 良い例: テストヘルパーを作成
function createMockUser(overrides?: Partial<User>): User {
  return {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    ...overrides
  }
}

// 使用例
it('should process user', () => {
  const user = createMockUser({ name: 'Jane' })
  // ...
})
```

#### 3. スパイの活用

```typescript
// ✅ 良い例: 実装を呼びつつ、呼び出しを記録
const logger = {
  info: jest.fn(), // スパイ
  error: jest.fn()
}

const service = new UserService(db, logger)
await service.createUser(userData)

expect(logger.info).toHaveBeenCalledWith(
  expect.stringContaining('User created')
)
```

### 非同期テストのベストプラクティス

#### 1. async/await の使用

```typescript
// ❌ 悪い例: コールバック地獄
it('should fetch user', (done) => {
  fetchUser('1').then((user) => {
    expect(user.name).toBe('John')
    done()
  })
})

// ✅ 良い例: async/await
it('should fetch user', async () => {
  const user = await fetchUser('1')
  expect(user.name).toBe('John')
})
```

#### 2. エラーハンドリング

```typescript
// ✅ 良い例: エラーのテスト
it('should throw error for invalid id', async () => {
  await expect(fetchUser('invalid')).rejects.toThrow('Invalid ID')
})

// または
it('should throw error for invalid id', async () => {
  try {
    await fetchUser('invalid')
    fail('Should have thrown error')
  } catch (error) {
    expect(error.message).toBe('Invalid ID')
  }
})
```

#### 3. タイムアウトの設定

```typescript
// ✅ 良い例: タイムアウト設定
it('should complete within 5 seconds', async () => {
  const start = Date.now()
  await longRunningOperation()
  const duration = Date.now() - start

  expect(duration).toBeLessThan(5000)
}, 10000) // テスト全体のタイムアウト: 10秒
```

## 🛠️ テストコマンドリファレンス

### Jest コマンド

```bash
# すべてのテストを実行
npm test

# 特定のファイルのみ実行
npm test user.test.ts

# パターンマッチでテスト実行
npm test -- --testPathPattern=user

# watch モード（変更を監視）
npm test -- --watch

# カバレッジレポート生成
npm test -- --coverage

# 失敗したテストのみ再実行
npm test -- --onlyFailures

# 詳細な出力
npm test -- --verbose

# 並列実行の制御
npm test -- --maxWorkers=4

# 特定のテストスイートのみ
npm test -- --testNamePattern="should create user"
```

### Vitest コマンド

```bash
# すべてのテストを実行
npm run test

# watch モード
npm run test:watch

# UI モード
npm run test:ui

# カバレッジ
npm run test:coverage

# 特定のファイル
npm run test user.test.ts

# フィルター
npm run test -- --grep="user"
```

### Playwright コマンド

```bash
# すべてのE2Eテストを実行
npx playwright test

# 特定のブラウザで実行
npx playwright test --project=chromium

# ヘッドレスモードを無効化（デバッグ）
npx playwright test --headed

# UI モード
npx playwright test --ui

# デバッグモード
npx playwright test --debug

# レポート表示
npx playwright show-report

# 特定のテストファイル
npx playwright test login.spec.ts

# 並列実行数の制御
npx playwright test --workers=4
```

### テストスクリプトの設定例（package.json）

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:unit": "jest --testPathPattern=unit",
    "test:integration": "jest --testPathPattern=integration",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:all": "npm run test:unit && npm run test:integration && npm run test:e2e"
  }
}
```

## 📝 実装チェックリスト

### テスト実装前のチェックリスト

- [ ] 要件を理解しているか
- [ ] テスト対象のコードは実装されているか（TDDの場合は不要）
- [ ] テスト可能な設計になっているか（依存性注入等）
- [ ] テストデータの準備は完了しているか

### テスト作成時のチェックリスト

- [ ] テストファイルの命名規則に従っているか（`*.test.ts` または `*.spec.ts`）
- [ ] AAA パターンに従っているか
- [ ] テスト名は仕様を説明しているか
- [ ] 正常系のテストを書いたか
- [ ] 異常系のテストを書いたか
- [ ] エッジケースを考慮したか
- [ ] モック/スタブは適切に使用しているか
- [ ] テストは独立しているか（順序に依存しない）

### テスト実行後のチェックリスト

- [ ] すべてのテストが成功しているか
- [ ] カバレッジ目標を達成しているか
- [ ] 警告やエラーメッセージはないか
- [ ] テスト実行時間は許容範囲内か（単体テストは高速）
- [ ] CI/CD パイプラインでもテストが成功するか

### コードレビュー時のチェックリスト

- [ ] テストコードの可読性は高いか
- [ ] 重複したテストコードはないか
- [ ] テストヘルパーは適切に活用されているか
- [ ] マジックナンバーは定数化されているか
- [ ] コメントは必要十分か
- [ ] テストデータは意味のある値か（`foo`, `bar` など避ける）

### リリース前のチェックリスト

- [ ] すべてのテストが成功しているか
- [ ] カバレッジレポートを確認したか
- [ ] E2E テストが成功しているか
- [ ] パフォーマンステストを実施したか
- [ ] セキュリティテストを実施したか（CodeGuard等）
- [ ] クロスブラウザテストを実施したか（該当する場合）

## 🔧 トラブルシューティング

### よくある問題と解決策

#### 問題1: テストが不安定（フレーキー）

**症状:**
- 同じテストが成功したり失敗したりする
- CI/CD では失敗するがローカルでは成功する

**原因と解決策:**
```typescript
// ❌ 原因: タイミング依存
it('should update UI', async () => {
  clickButton()
  expect(getDisplayText()).toBe('Updated') // 非同期処理が完了する前に検証
})

// ✅ 解決策: 非同期処理の完了を待つ
it('should update UI', async () => {
  await clickButton()
  await waitFor(() => {
    expect(getDisplayText()).toBe('Updated')
  })
})

// ❌ 原因: 現在時刻に依存
it('should check expiry', () => {
  const item = { expiryDate: new Date() }
  expect(isExpired(item)).toBe(true) // 実行タイミングで結果が変わる
})

// ✅ 解決策: 時刻を固定
it('should check expiry', () => {
  const now = new Date('2024-01-01')
  const item = { expiryDate: new Date('2023-12-31') }
  expect(isExpired(item, now)).toBe(true)
})
```

#### 問題2: テストが遅い

**症状:**
- テスト実行に時間がかかる
- CI/CD パイプラインが遅い

**原因と解決策:**
```typescript
// ❌ 原因: 実際のDBを使用
beforeEach(async () => {
  await db.connect()
  await db.migrate()
})

// ✅ 解決策: インメモリDBまたはモックを使用
beforeEach(() => {
  db = createInMemoryDatabase()
})

// ❌ 原因: 不必要な待機
await page.waitForTimeout(5000) // 5秒待つ

// ✅ 解決策: 条件待機
await page.waitForSelector('.element', { timeout: 5000 })
```

#### 問題3: モックが機能しない

**症状:**
- モックを設定したのに実際の関数が呼ばれる
- テストが外部依存に接続しようとする

**原因と解決策:**
```typescript
// ❌ 原因: モックの設定タイミングが遅い
import { fetchUser } from './api'
jest.mock('./api') // importの後では遅い

// ✅ 解決策: importの前にモック
jest.mock('./api')
import { fetchUser } from './api'

// または
beforeEach(() => {
  jest.clearAllMocks()
  jest.resetAllMocks()
})
```

#### 問題4: カバレッジが上がらない

**症状:**
- テストを書いても特定の行がカバーされない
- 分岐カバレッジが低い

**原因と解決策:**
```typescript
// ❌ カバーされていない分岐
function processValue(value: number | null): number {
  if (value === null) {
    return 0
  }
  return value * 2
}

// テスト（null の場合がテストされていない）
it('should process value', () => {
  expect(processValue(5)).toBe(10)
})

// ✅ 解決策: すべての分岐をテスト
describe('processValue', () => {
  it('should process valid value', () => {
    expect(processValue(5)).toBe(10)
  })

  it('should return 0 for null', () => {
    expect(processValue(null)).toBe(0)
  })
})
```

### デバッグテクニック

#### 1. console.log デバッグ

```typescript
it('should calculate total', () => {
  const items = [100, 200]
  const result = calculateTotal(items)

  console.log('Items:', items)
  console.log('Result:', result)

  expect(result).toBe(300)
})
```

#### 2. デバッガーの使用

```typescript
it('should process data', () => {
  const data = prepareData()

  debugger // ブラウザのデバッガーが起動

  const result = processData(data)
  expect(result).toBeDefined()
})

// Node.js の場合
// node --inspect-brk node_modules/.bin/jest --runInBand
```

#### 3. テストの分離実行

```bash
# 特定のテストのみ実行
npm test -- --testNamePattern="should calculate total"

# 特定のファイルのみ実行
npm test user.test.ts

# .only を使用（一時的）
it.only('should calculate total', () => {
  // このテストのみ実行される
})
```

## 📊 テストメトリクスの追跡

### 推奨する測定項目

1. **テストカバレッジ**: 80%以上を維持
2. **テスト実行時間**: 単体テストは5分以内
3. **テスト失敗率**: 5%以下を目標
4. **フレーキーテスト率**: 1%以下を目標
5. **テスト数の推移**: 増加傾向を維持

### CI/CD でのテスト戦略

```yaml
# GitHub Actions の例
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Run unit tests
        run: npm run test:unit -- --coverage

      - name: Run integration tests
        run: npm run test:integration

      - name: Run E2E tests
        run: npm run test:e2e

      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## 🔗 関連ファイル

- **[SKILL.md](./SKILL.md)** - 概要に戻る
- **[TDD.md](./TDD.md)** - TDDサイクル
- **[TEST-TYPES.md](./TEST-TYPES.md)** - テストの種類
- **[TESTABLE-DESIGN.md](./TESTABLE-DESIGN.md)** - テスタブルな設計
