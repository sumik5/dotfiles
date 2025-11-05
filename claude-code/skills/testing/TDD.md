# TDDサイクルと実装パターン

このファイルでは、テスト駆動開発（TDD）の詳細な手法と実装パターンを説明します。

## 📋 目次

- [TDDサイクル](#tddサイクル)
- [詳細な実装例](#詳細な実装例)
- [TDDのメリット](#tddのメリット)
- [実践的なTDDワークフロー](#実践的なtddワークフロー)

## 🔄 TDDサイクル

### 基本の3ステップ

```
1. Red（失敗するテストを書く）
   ↓
2. Green（最小限のコードで通す）
   ↓
3. Refactor（リファクタリング）
   ↓
繰り返し
```

### 各ステップの詳細

**ステップ1: Red（失敗するテストを書く）**
- まだ存在しない機能のテストを書く
- テストが失敗することを確認（Redの状態）
- テストが正しく失敗していることが重要

**ステップ2: Green（最小限のコードで通す）**
- テストを通すための最小限のコードを書く
- この段階では「美しさ」より「動くこと」を優先
- すべてのテストがGreenになることを確認

**ステップ3: Refactor（リファクタリング）**
- テストを通したまま、コードを改善
- 重複を削除、可読性を向上
- テストがGreenのままであることを確認しながら実施

## 💡 詳細な実装例

### 例1: 基本的な計算関数

**ステップ1: Red（テストを先に書く）**
```typescript
// calculate.test.ts
describe('calculateTotal', () => {
  it('should calculate total with discount', () => {
    expect(calculateTotal([100, 200], 0.1)).toBe(270)
  })
})

// この時点でテスト実行 → FAIL（関数が存在しない）
```

**ステップ2: Green（最小限の実装）**
```typescript
// calculate.ts
function calculateTotal(items: number[], discount: number): number {
  const subtotal = items.reduce((sum, item) => sum + item, 0)
  return subtotal * (1 - discount)
}

// テスト実行 → PASS
```

**ステップ3: Refactor（リファクタリング）**
```typescript
// calculate.ts（リファクタリング後）
function calculateTotal(items: number[], discount: number): number {
  validateItems(items)
  validateDiscount(discount)

  const subtotal = sumItems(items)
  return applyDiscount(subtotal, discount)
}

function validateItems(items: number[]): void {
  if (!Array.isArray(items)) {
    throw new Error('Items must be an array')
  }
  if (items.some(item => item < 0)) {
    throw new Error('Items must be non-negative')
  }
}

function validateDiscount(discount: number): void {
  if (discount < 0 || discount > 1) {
    throw new Error('Discount must be between 0 and 1')
  }
}

function sumItems(items: number[]): number {
  return items.reduce((sum, item) => sum + item, 0)
}

function applyDiscount(subtotal: number, discount: number): number {
  return subtotal * (1 - discount)
}

// テスト実行 → PASS（テストはグリーンのまま）
```

**ステップ4: テストの追加（エッジケース）**
```typescript
describe('calculateTotal', () => {
  it('should calculate total with discount', () => {
    expect(calculateTotal([100, 200], 0.1)).toBe(270)
  })

  it('should handle empty array', () => {
    expect(calculateTotal([], 0.1)).toBe(0)
  })

  it('should throw error for negative items', () => {
    expect(() => calculateTotal([-100], 0.1)).toThrow('Items must be non-negative')
  })

  it('should throw error for invalid discount', () => {
    expect(() => calculateTotal([100], 1.5)).toThrow('Discount must be between 0 and 1')
  })
})
```

### 例2: クラスベースの実装

**ステップ1: Red（テストを先に書く）**
```typescript
// user-service.test.ts
describe('UserService', () => {
  it('should create user with valid data', () => {
    const userService = new UserService()
    const user = userService.createUser({
      name: 'John Doe',
      email: 'john@example.com'
    })

    expect(user.id).toBeDefined()
    expect(user.name).toBe('John Doe')
    expect(user.email).toBe('john@example.com')
  })
})

// テスト実行 → FAIL
```

**ステップ2: Green（最小限の実装）**
```typescript
// user-service.ts
interface UserData {
  name: string
  email: string
}

interface User extends UserData {
  id: string
}

class UserService {
  createUser(data: UserData): User {
    return {
      id: crypto.randomUUID(),
      ...data
    }
  }
}

// テスト実行 → PASS
```

**ステップ3: Refactor（バリデーション追加）**
```typescript
// user-service.ts（リファクタリング後）
class UserService {
  createUser(data: UserData): User {
    this.validateUserData(data)

    return {
      id: this.generateId(),
      name: this.normalizeName(data.name),
      email: this.normalizeEmail(data.email)
    }
  }

  private validateUserData(data: UserData): void {
    if (!data.name || data.name.trim() === '') {
      throw new Error('Name is required')
    }
    if (!this.isValidEmail(data.email)) {
      throw new Error('Invalid email format')
    }
  }

  private isValidEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
  }

  private generateId(): string {
    return crypto.randomUUID()
  }

  private normalizeName(name: string): string {
    return name.trim()
  }

  private normalizeEmail(email: string): string {
    return email.toLowerCase().trim()
  }
}

// テスト実行 → PASS
```

**ステップ4: テストの追加**
```typescript
describe('UserService', () => {
  let service: UserService

  beforeEach(() => {
    service = new UserService()
  })

  it('should create user with valid data', () => {
    const user = service.createUser({
      name: 'John Doe',
      email: 'john@example.com'
    })

    expect(user.id).toBeDefined()
    expect(user.name).toBe('John Doe')
    expect(user.email).toBe('john@example.com')
  })

  it('should normalize email to lowercase', () => {
    const user = service.createUser({
      name: 'John',
      email: 'JOHN@EXAMPLE.COM'
    })

    expect(user.email).toBe('john@example.com')
  })

  it('should trim whitespace from name', () => {
    const user = service.createUser({
      name: '  John Doe  ',
      email: 'john@example.com'
    })

    expect(user.name).toBe('John Doe')
  })

  it('should throw error for empty name', () => {
    expect(() => service.createUser({
      name: '',
      email: 'john@example.com'
    })).toThrow('Name is required')
  })

  it('should throw error for invalid email', () => {
    expect(() => service.createUser({
      name: 'John',
      email: 'invalid-email'
    })).toThrow('Invalid email format')
  })
})
```

## 🎯 TDDのメリット

### 1. デザインの改善
- テストを先に書くことで、APIの使いやすさを考えざるを得ない
- モジュラーで疎結合な設計になりやすい

### 2. ドキュメントとしての役割
- テストコードが仕様書として機能
- 使用例が明確になる

### 3. リファクタリングの安心感
- テストがあることで、安心してリファクタリングできる
- 回帰バグを早期発見

### 4. デバッグ時間の削減
- バグが混入しにくい
- バグが入っても早期に発見できる

### 5. 実装の完了基準が明確
- すべてのテストがグリーンになったら完了

## 🚀 実践的なTDDワークフロー

### 新機能開発のワークフロー

```
1. ユーザーストーリー/要件を確認
   ↓
2. テストケースをリストアップ
   - 正常系
   - 異常系
   - エッジケース
   ↓
3. 最初のテストを書く（Red）
   ↓
4. 最小限の実装（Green）
   ↓
5. リファクタリング（Refactor）
   ↓
6. 次のテストケースに進む（ステップ3に戻る）
   ↓
7. すべてのテストケース完了
   ↓
8. カバレッジ確認
   ↓
9. コードレビュー
```

### バグ修正のワークフロー

```
1. バグレポートを確認
   ↓
2. バグを再現するテストを書く
   ↓
3. テストが失敗することを確認（Red）
   ↓
4. バグを修正（Green）
   ↓
5. テストが成功することを確認
   ↓
6. 関連するエッジケースのテスト追加
   ↓
7. リファクタリング（Refactor）
   ↓
8. 回帰テスト実行
```

### レガシーコードへのTDD導入

```
1. 既存コードを理解
   ↓
2. 現在の動作を保証するテストを書く
   ↓
3. テストが成功することを確認
   ↓
4. 小さくリファクタリング
   ↓
5. テストがグリーンのままか確認
   ↓
6. 繰り返し（ステップ4に戻る）
   ↓
7. 新機能は通常のTDDサイクルで追加
```

## 💡 TDDのヒント

### ヒント1: 小さく始める
最初から完璧を目指さず、最も単純なケースから始める

```typescript
// ❌ 悪い例: 最初から複雑
it('should calculate total with discount, tax, and shipping', () => {
  // 複雑すぎる
})

// ✅ 良い例: シンプルから始める
it('should sum items', () => {
  expect(sumItems([100, 200])).toBe(300)
})
```

### ヒント2: 1つずつ進める
一度に1つのテストケースだけに集中する

### ヒント3: テストを信頼する
- テストが失敗したら、まずテストが正しいか確認
- テストが正しければ、実装を修正

### ヒント4: リファクタリングを恐れない
- グリーンになったらリファクタリングのチャンス
- テストがあるので安心してリファクタリングできる

## 🔗 関連ファイル

- **[SKILL.md](./SKILL.md)** - 概要に戻る
- **[TEST-TYPES.md](./TEST-TYPES.md)** - テストの種類
- **[TESTABLE-DESIGN.md](./TESTABLE-DESIGN.md)** - テスタブルな設計
- **[REFERENCE.md](./REFERENCE.md)** - ベストプラクティス
