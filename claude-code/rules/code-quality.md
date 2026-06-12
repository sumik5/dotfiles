# コード品質ルール

各タチコマにコア品質スキルがプリロード済み。本体はチェック不要。

## SOLID原則 → `writing-clean-code` スキル参照

S(単一責任) O(開放閉鎖) L(リスコフ置換) I(インターフェース分離) D(依存関係逆転)

## 型安全性 → `mastering-typescript`（TS）・`developing-python`（Python）スキル参照

❌ `any`(TS)/`Any`(Python)禁止 → `unknown`+型ガード/ジェネリクス/Utility Types

## テストファースト → `testing-code` スキル参照

Red→Green→Refactor。AAAパターン必須。カバレッジ: ビジネスロジック100%

## セキュリティ → `securing-code` スキル参照

実装完了後 `software-security` スキル（devkit / Project CodeGuard 日本語版）を必須ロード。全外部入力検証・SQLi/XSS対策・機密情報は環境変数。
