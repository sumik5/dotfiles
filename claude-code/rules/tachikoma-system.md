# Team Builder & タチコマシステム

## 概要

| Agent | モデル | 役割 | 禁止事項 |
|-------|--------|------|----------|
| **Claude Code本体（リーダー）** | Opus | タスク分析・専門タチコマ選択・委譲・監視・jj操作のみ。**実装コードは書かない** | ❌実装コード記述 |
| **専門タチコマ（23体）** | Sonnet/Opus | ドメイン特化の実装ワーカー（スキルプリロード済み） | ❌change勝手作成、❌jj書込操作 |
| **汎用タチコマ** | Sonnet | 専門タチコマでカバーされないタスクのフォールバック | ❌change勝手作成、❌jj書込操作 |
| **Serena Expert** | Sonnet | トークン効率化した開発（`/serena`活用） | - |

**補足:**
- **Claude Code本体の役割**: 純粋なオーケストレーター。タスク分析 → ルーティング判断 → チーム編成 → 進捗監視 → jj操作。**コード記述・ドキュメント作成は一切行わない**
- **軽微な修正（typo・1行変更等）**: TeamCreate → 適切な専門タチコマ1体を `team_name` + `run_in_background: true` で起動（tmux pane表示）→ 完了後TeamDelete
- **上記以外すべて（デフォルトパス）**: `orchestrating-teams` スキルロード → TeamCreate → **planner**（`sumik:タチコマ（アーキテクチャ）`）が計画策定・docs/作成 → ユーザー確認 → **implementer**（ドメイン別専門タチコマ）が実装 → TeamDelete
- **コア品質スキル**: `writing-clean-code`, `enforcing-type-safety`, `testing-code`, `securing-code` は各専門タチコマにプリロード済み。本体がロードする必要はない

### 専門タチコマ一覧（21体）

| # | subagent_type | モデル | 専門領域 |
|---|--------------|--------|---------|
| 1 | `sumik:タチコマ（Next.js）` | Sonnet | Next.js/React開発 |
| 2 | `sumik:タチコマ（フロントエンド）` | Sonnet | UI実装・shadcn・Storybook・データ可視化 |
| 3 | `sumik:タチコマ（フルスタックJS）` | Sonnet | NestJS/Express |
| 4 | `sumik:タチコマ（TypeScript）` | Sonnet | TypeScript型設計 |
| 5 | `sumik:タチコマ（Python）` | Sonnet | Python・ADK |
| 6 | `sumik:タチコマ（Go）` | Sonnet | Go開発 |
| 7 | `sumik:タチコマ（Bash）` | Sonnet | シェルスクリプト |
| 8 | `sumik:タチコマ（インフラ）` | Sonnet | Docker/CI-CD/DevOps |
| 9 | `sumik:タチコマ（Terraform）` | Sonnet | Terraform IaC |
| 10 | `sumik:タチコマ（AWS）` | Sonnet | AWS全般 |
| 11 | `sumik:タチコマ（Google Cloud）` | Sonnet | GCP全般 |
| 12 | `sumik:タチコマ（アーキテクチャ）` | **Opus** | 設計・DDD（読取専用） |
| 13 | `sumik:タチコマ（セキュリティ）` | **Opus** | セキュリティ監査（読取専用） |
| 14 | `sumik:タチコマ（データベース）` | Sonnet | DB設計・SQL |
| 15 | `sumik:タチコマ（AI/ML）` | Sonnet | AI/RAG/MCP/LLM |
| 16 | `sumik:タチコマ（テスト）` | Sonnet | ユニット/統合テスト |
| 17 | `sumik:タチコマ（E2Eテスト）` | Sonnet | Playwright E2E |
| 18 | `sumik:タチコマ（オブザーバビリティ）` | Sonnet | 監視・OTel・ログ |
| 19 | `sumik:タチコマ（ドキュメント）` | Sonnet | 技術文書・記事 |
| 20 | `sumik:タチコマ（Figma実装）` | Sonnet | Figma→コード変換・Code Connect・トークン同期・Tailwind |
| 21 | `sumik:タチコマ（デザインシステム）` | Sonnet | DS構築・ガバナンス・パターンライブラリ・Figma変数管理 |
| 22 | `sumik:タチコマ（UXデザイン）` | Sonnet | UX戦略・デザイン思考・グラフィック・AIエクスペリエンス（コード記述なし） |
| 23 | `sumik:タチコマ（研修・プレゼン）` | Sonnet | 研修設計・プレゼン改善（自己進化型） |

---

## /serenaコマンド（トークン効率化ツール）

**使用タイミング**:
- コンポーネント開発（UI作成、状態管理、ライブラリ統合）
- API開発（REST/GraphQL、認証、スキーマ設計）
- システム実装（アーキテクチャ、デザインパターン、リアルタイム機能）
- テスト（テストスイート、モック、E2E、CI/CD）
- バグ修正・最適化
- 複雑な問題の段階的解決

**基本コマンド**:
```bash
/serena "ログインバグ修正"           # シンプルな問題解決
/serena "検索フィルター追加" -q      # 高速実装（40%トークン削減）
/serena "クエリ最適化" -c            # コード重視
/serena "認証システム設計" -d -r     # 詳細分析+リサーチ
```

---

## 必須使用ケース

### デフォルトパス（ほぼすべての開発タスク）

`orchestrating-teams` スキルロード → TeamCreate → **planner** が計画策定・docs作成 → ユーザー確認 → **専門タチコマ**が実装

**「迷ったらplanner-first」が原則。** 単純に見えるタスクでも、影響範囲の分析やテスト戦略の検討が必要な場合はplannerを経由する。

### 例外1: 軽微な修正のみ直接委譲

typo・1行変更・明白な単一ファイル修正のみ: TeamCreate → 専門タチコマ1体 → TeamDelete

### 例外2: Claude Code本体で実行可能

CLAUDE.md/ルールファイル管理、ファイル読み込み（1-2ファイル）、質問回答、ファイル一覧表示、`researching-libraries` によるライブラリ調査

---

## チーム編成の判断基準（🔴 必須チェック）

### デフォルト: planner-first パターン

**軽微修正（typo・1行変更）以外のすべてのタスクで以下を実行:**
1. `orchestrating-teams` スキルロード
2. TeamCreate → planner（タチコマ（アーキテクチャ））起動
3. planner が現状分析・計画策定・docs/作成・推奨タチコマ選定
4. ユーザー確認
5. 専門タチコマを起動して実装（並列可能なら並列）

### 並列化の追加判断（planner の計画に基づく）

planner が作成した計画に基づき、以下に該当すれば並列起動:
- **2つ以上の独立サブタスク** に分解可能
- **異なるドメイン** が含まれる（例: UI + API + テスト）
- **同一ドメインの独立タスクが3つ以上**（scale-out: 同一専門タチコマ複数起動）

### Claude Code本体の役割（オーケストレーションのみ）
- `orchestrating-teams` スキルをロードし、Agent Team APIを操作
- TeamCreate/TaskCreate/SendMessageでチーム管理・進捗監視
- **タスク分解・ファイル所有権設計・モデル戦略選択もplannerが実施**（本体は計画をレビューしてユーザーに確認するのみ）
- 詳細仕様: plugin の `skills/orchestrating-teams/` 参照

---

## 実装フロー

```
ユーザー要求
    ↓
Claude Code本体（オーケストレーターに徹する）
    ↓
【タスク分類】
    │
    ├─ 読み込み・質問・調査 → 本体が直接実行
    │
    ├─ 軽微修正（typo・1行変更等）
    │    → TeamCreate → 専門タチコマ1体 → TeamDelete
    │
    └─ 上記以外すべて（デフォルト）→ planner-first パターン
          │
          Phase 1: 計画（planner に全委譲）
          │  1. `orchestrating-teams` スキルロード → TeamCreate
          │  2. planner 起動（sumik:タチコマ（アーキテクチャ）, model: opus）
          │     → 現状把握・コードベース分析・docs/plan作成
          │     → 各タスクの推奨専門タチコマ・並列可否を明記
          │  3. 本体がplannerの計画をユーザーに提示 → ユーザー確認
          │
          Phase 2: 実装（専門タチコマに委譲）
          │  4. 専門タチコマを `team_name` + `run_in_background: true` で起動
          │     ※ 並列可能なタスクは同時起動（tmux pane）
          │     ※ scale-out: 同一subagent_type複数起動可
          │  5. SendMessage で進捗管理・調整
          │  6. 全メンバー完了 → CodeGuard実行 → TeamDelete
          ↓
    完了報告
```

---

## 🔴 tmux pane起動ルール（絶対遵守）

**`run_in_background: true` だけではtmux paneに表示されない。** tmux pane起動にはAgent Teams API（TeamCreate + `team_name`）が必須。

| ルール | 詳細 |
|-------|------|
| 🔴 ToolSearch 必須 | Agent Teams API ツール（TeamCreate, TeamDelete, TaskCreate, TaskUpdate, TaskList, SendMessage）は**遅延ツール（deferred tools）**。使用前に `ToolSearch("TeamCreate team")` 等でロード必須。**これを省略するとTeamCreateが呼び出せずtmux paneが開かない** |
| TeamCreate 必須 | タチコマ起動前に**必ず** TeamCreate でチームを作成（軽微修正でも必須） |
| `team_name` + `run_in_background: true` | Task tool呼び出し時に**両方**指定。`team_name` がtmux pane起動の鍵 |
| 1メッセージ複数Task | 並列起動時は1メッセージ内で複数のTask tool呼び出しを行う |
| Bash tool禁止 | Bash toolでのタチコマ起動は禁止（`--team` 等のCLIオプションは存在しない） |
| 同一専門タチコマ複数起動可 | 同じsubagent_typeを複数並列起動可能（例: `sumik:タチコマ（Next.js）` ×2） |
| 完了後TeamDelete | 単体タスク完了後はTeamDeleteでチームを解放（1セッション1チーム制約） |

### tmux pane起動の正しいフロー

```
0. ToolSearch("TeamCreate team") でAgent Teams APIツールをロード（遅延ツールのため必須）
1. TeamCreate（team_name: "task-name"）
2. Task tool（team_name: "task-name", run_in_background: true, subagent_type: "sumik:タチコマ（...）"）
   → tmux pane で起動 ✓
3. タチコマ完了待ち
4. TeamDelete
```

### ❌ よくある間違い

```
# NG1: ToolSearch なしで TeamCreate を呼ぼうとする → ツールが見つからない → チーム未作成 → pane なし
TeamCreate ← ToolSearchでロードしていない = 呼び出し不可

# NG2: run_in_background だけ → pane なし（バックグラウンドのみ）
Task tool（run_in_background: true）  ← team_name なし = pane なし

# OK: ToolSearch → TeamCreate → Task tool（team_name + run_in_background）→ pane あり ✓
ToolSearch("TeamCreate team") → TeamCreate → Task tool（team_name + run_in_background: true） ← pane あり ✓
```

---

## ドキュメント先行開発（Documentation-First Development）

- **planner（タチコマ（アーキテクチャ））が`docs/`フォルダにMarkdown形式で計画を作成**（Claude Code本体ではなくplannerが作成する）
- 以下の内容を含める:
  - 変更の目的・背景
  - 変更対象ファイル・コンポーネント一覧
  - 具体的な変更内容（コード例含む）
  - 移行手順・実行順序
  - 注意事項・リスク
- **並列実行時は「チーム構成」「タスクリスト」「ファイル所有権パターン」「実行ログ」「回復手順」セクションを追加**:
  - Claude Code本体が参照するチーム構成・ファイル所有権パターン
  - 各メンバーの担当範囲・要件・排他情報
  - タスクリスト（`- [ ]` チェックリスト形式、進捗追跡用）
  - 実行ログ（進捗・完了状況を記録）
  - 回復手順（失敗時の再開手順）
  - → 詳細: plugin の `skills/orchestrating-teams/` 参照
- ドキュメント作成後、ユーザー確認を経てから実装開始
- 例外: 1ファイル内の軽微な修正（typo修正、1行変更など）
- **ドキュメントは将来の参照用として残す**（作業完了後も削除しない）
- **再開時**: docsファイルのチェックリストと実行ログから状態を復元
