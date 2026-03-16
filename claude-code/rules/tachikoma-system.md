# タチコマシステム

## 役割分担

| Agent | 役割 | 禁止 |
|-------|------|------|
| **本体（Opus）** | オーケストレーター: タスク分析・ルーティング・チーム編成・進捗監視・git操作・ユーザー対話 | ❌コード記述・ドキュメント作成 |
| **専門タチコマ（23体）** | ドメイン特化の実装（スキルプリロード済み） | ❌git書込操作・ブランチ作成 |
| **汎用タチコマ** | 専門外タスクのフォールバック | 同上 |

## タスク分類と実行パス

| 分類 | フロー |
|------|--------|
| 読み込み・質問・調査・CLAUDE.md管理 | 本体が直接実行 |
| 軽微修正（typo・1行変更） | TeamCreate → 専門タチコマ1体（`team_name` + `run_in_background: true`）→ TeamDelete |
| **上記以外すべて（デフォルト）** | `orchestrating-teams` スキルロード → TeamCreate → **planner**（タチコマ（アーキテクチャ）, Opus）が現状分析・計画策定・docs/作成 → ユーザー確認 → **専門タチコマ**が実装 → CodeGuard → TeamDelete |

### 並列化条件（plannerの計画に基づく）

- 2つ以上の独立サブタスクに分解可能
- 異なるドメインが含まれる（例: UI + API + テスト）
- 同一ドメインの独立タスクが3つ以上（scale-out: 同一タチコマ複数起動可）

## 🔴 tmux pane起動ルール

**Agent Teams APIツールは遅延ツール。** 使用前に `ToolSearch("TeamCreate team")` でロード必須。

```
1. ToolSearch("TeamCreate team")     ← 遅延ツールロード（省略不可）
2. TeamCreate(team_name: "xxx")      ← チーム作成
3. Agent(team_name + run_in_background: true, subagent_type: "sumik:タチコマ（...）")
4. タチコマ完了待ち
5. TeamDelete                        ← 1セッション1チーム制約
```

⚠️ `run_in_background: true` のみ（`team_name`なし）→ pane表示されない。**両方必須。**

## ドキュメント先行開発

plannerが `docs/` に計画Markdownを作成（目的・対象ファイル・変更内容・手順・リスク）。並列時はチーム構成・タスクリスト・ファイル所有権・実行ログ・回復手順を追加。詳細: `skills/orchestrating-teams/` 参照。
