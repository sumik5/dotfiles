# 学びログ (LEARNINGS)

このファイルはプロジェクト作業中に得た学び・訂正・知識ギャップ・ベストプラクティスを蓄積します。
エントリ書式の詳細と昇格ルールは `capturing-learnings` スキル（INSTRUCTIONS.md）を参照してください。

---

<!-- 以下に [LRN-YYYYMMDD-XXX] エントリを追記してください -->

## [LRN-20260627-001] best_practice

**記録日時**: 2026-06-27T10:20:05+09:00
**優先度**: low
**ステータス**: resolved
**領域**: config

### 要約
`glogs` の fzf 対話モードで左側のコミット一覧を動かしたい場合は、`ctrl-j:down,ctrl-k:up` を使う。

### 詳細
`glogs` は `fzf --preview` で右側に `git show` を表示しており、以前の `Ctrl-J / Ctrl-K` は `preview-down / preview-up` に割り当てられていたため右側プレビューがスクロールした。左側のコミットログ選択を上下させるには fzf の通常移動アクション `down / up` に割り当てる。

### 推奨アクション
`glogs` のキーバインドを変更するときは、左側の一覧操作には `down / up`、右側のプレビュー操作には `preview-*` アクションを使い分ける。

### メタデータ
- 発生源: conversation
- 関連ファイル: bin/glogs
- タグ: glogs, fzf, keybinding
- 関連(See Also):
- Pattern-Key: glogs-fzf-pane-keybinding
- Recurrence-Count: 1 / First-Seen: 2026-06-27 / Last-Seen: 2026-06-27
