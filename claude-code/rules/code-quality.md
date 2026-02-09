# コード品質ルール

## SOLID原則（全実装で必須）

- **S**: 単一責任（1クラス/関数 = 1責務）
- **O**: 開放閉鎖（拡張に開く、修正に閉じる）
- **L**: リスコフ置換（派生クラスは基底クラスと置換可能）
- **I**: インターフェース分離（必要なメソッドのみ）
- **D**: 依存関係逆転（抽象に依存）

詳細は `writing-clean-code` スキルを参照。

---

## 型安全性（絶対遵守）

- ❌ **`any`（TypeScript）、`Any`（Python）使用禁止**
- ✅ 明示的な型定義
- ✅ `unknown` + 型ガード
- ✅ ジェネリクス
- ✅ Utility Types

詳細は `enforcing-type-safety` スキルを参照。

---

## テストファースト

- Red（失敗テスト）→ Green（実装）→ Refactor
- **AAAパターン必須**: Arrange → Act → Assert
- `actual`/`expected`変数の明示的使用
- **カバレッジ目標**: ビジネスロジック100%、ユーティリティ100%

詳細は `testing` スキルを参照。

---

## セキュリティ（🔴 実装完了後必須）

```bash
# 実装完了後に必ず実行
/codeguard-security:software-security
```

- 全外部入力を検証
- SQLインジェクション対策（プリペアドステートメント）
- XSS対策（エスケープ処理）
- 機密情報は環境変数管理

詳細は `securing-code` スキルを参照。
