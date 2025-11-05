---
name: testing
description: テストファーストアプローチ - TDD、AAAパターン、テストカバレッジ100%を目標。テスタブルな設計と品質保証を支援。
---

# テストファーストアプローチ

## 📑 目次

このスキルは以下のファイルで構成されています：

- **SKILL.md** (このファイル): 概要と使用タイミング
- **[TDD.md](./TDD.md)**: TDDサイクルと実装パターン
- **[TEST-TYPES.md](./TEST-TYPES.md)**: テストピラミッド（単体、統合、E2E）
- **[TESTABLE-DESIGN.md](./TESTABLE-DESIGN.md)**: テスタブルな設計原則
- **[REFERENCE.md](./REFERENCE.md)**: ベストプラクティス、カバレッジ、チェックリスト

## 🎯 使用タイミング

- **新機能実装時（実装前にテスト作成）**
- **バグ修正時（再現テスト作成）**
- **リファクタリング時（回帰テスト実行）**
- **コードレビュー時（テストカバレッジ確認）**

## 📋 基本原則

### テストファースト開発

実装の前にテストを書く「TDD（Test-Driven Development）」を推奨します。

**基本サイクル:**
```
1. Red（失敗するテストを書く）
   ↓
2. Green（最小限のコードで通す）
   ↓
3. Refactor（リファクタリング）
   ↓
繰り返し
```

詳細は [TDD.md](./TDD.md) を参照してください。

### テストピラミッド

```
        /\
       /  \      E2E（少数）
      /____\     統合テスト（中程度）
     /______\    単体テスト（多数）
```

**原則:**
- 単体テストを最も多く作成
- 統合テストは適度に
- E2Eテストは最小限に

詳細は [TEST-TYPES.md](./TEST-TYPES.md) を参照してください。

### AAAパターン（必須）

すべてのテストは **Arrange-Act-Assert** パターンに従います：

```typescript
it('should create user with valid data', () => {
  // Arrange（準備）
  const userData = { name: 'John', email: 'john@example.com' }

  // Act（実行）
  const user = userService.createUser(userData)

  // Assert（検証）
  expect(user.name).toBe('John')
})
```

## 🎯 カバレッジ目標

### 推奨カバレッジ基準

```
- ビジネスロジック: 100%
- ユーティリティ関数: 100%
- コントローラー: 80%以上
- UI コンポーネント: 70%以上
```

詳細は [REFERENCE.md](./REFERENCE.md) を参照してください。

## 🎨 テスタブルな設計

テストしやすいコードを書くための設計原則：

**1. 依存性注入（DI）**
- コンストラクタでの依存注入
- モック可能な設計

**2. 純粋関数**
- 副作用のない関数
- 同じ入力に対して同じ出力

**3. インターフェース抽象化**
- 具象クラスではなくインターフェースに依存
- テスト用モックの作成が容易

詳細は [TESTABLE-DESIGN.md](./TESTABLE-DESIGN.md) を参照してください。

## 📊 クイックスタート

### 新機能実装時の基本フロー

```
1. テストを先に書く（Red）
   ↓
2. 最小限の実装（Green）
   ↓
3. リファクタリング（Refactor）
   ↓
4. カバレッジ確認
   ↓
5. 完了
```

### バグ修正時の基本フロー

```
1. バグを再現するテストを書く
   ↓
2. テストが失敗することを確認
   ↓
3. バグを修正
   ↓
4. テストが成功することを確認
   ↓
5. 完了
```

## 🚀 実践例

### TypeScript + Jest

```typescript
// テスト
describe('calculateTotal', () => {
  it('should calculate total with discount', () => {
    expect(calculateTotal([100, 200], 0.1)).toBe(270)
  })
})

// 実装
function calculateTotal(items: number[], discount: number): number {
  const subtotal = items.reduce((sum, item) => sum + item, 0)
  return subtotal * (1 - discount)
}
```

### E2Eテスト（Playwright）

```typescript
test('user registration flow', async ({ page }) => {
  await page.goto('/register')
  await page.fill('#email', 'john@example.com')
  await page.click('button[type="submit"]')
  await expect(page.locator('.success')).toBeVisible()
})
```

## 📋 最小限のチェックリスト

実装完了前に確認：
- [ ] AAAパターンに従っているか
- [ ] テスト名は仕様を説明しているか
- [ ] カバレッジ目標を達成しているか
- [ ] テストは独立しているか

完全なチェックリストは [REFERENCE.md](./REFERENCE.md) を参照してください。

## 🔗 関連スキル

- **solid-clean-code** - テスタブルな設計原則
- **type-safety** - 型安全なテストコード
- **mcp-browser-auto** - E2Eテスト実装
- **agent-developer** - Developer Agent実装ガイド
