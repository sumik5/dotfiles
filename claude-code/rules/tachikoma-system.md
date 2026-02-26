# Team Builder & タチコマシステム

## 概要

| Agent | モデル | 役割 | 禁止事項 |
|-------|--------|------|----------|
| **Claude Code本体（リーダー）** | Opus | タスク分析・専門タチコマ選択・委譲・監視・jj操作のみ。**実装コードは書かない** | ❌実装コード記述 |
| **専門タチコマ（20体）** | Sonnet/Opus | ドメイン特化の実装ワーカー（スキルプリロード済み） | ❌change勝手作成、❌jj書込操作 |
| **汎用タチコマ** | Sonnet | 専門タチコマでカバーされないタスクのフォールバック | ❌change勝手作成、❌jj書込操作 |
| **Serena Expert** | Sonnet | トークン効率化した開発（`/serena`活用） | - |

**補足:**
- **Claude Code本体の役割**: タスク分析 → `rules/skill-triggers.md` のルーティング表で専門タチコマ選択 → 委譲 → 監視 → jj操作
- **軽微な修正（1ファイル・単一関心事）**: TeamCreate → 適切な専門タチコマ1体を `team_name` + `run_in_background: true` で起動（tmux pane表示）→ 完了後TeamDelete
- **複数ファイル・複雑なタスク**: `orchestrating-teams` スキルロード → Claude Code本体が直接 TeamCreate → planner（`sumik:タチコマ（アーキテクチャ）`）起動 → implementer（ドメイン別専門タチコマ）並列起動
- **コア品質スキル**: `writing-clean-code`, `enforcing-type-safety`, `testing-code`, `securing-code` は各専門タチコマにプリロード済み。本体がロードする必要はない

### 専門タチコマ一覧（20体）

| # | subagent_type | モデル | 専門領域 |
|---|--------------|--------|---------|
| 1 | `sumik:タチコマ（Next.js）` | Sonnet | Next.js/React開発 |
| 2 | `sumik:タチコマ（フロントエンド）` | Sonnet | UI/UX・shadcn・Figma |
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
| 20 | `sumik:タチコマ（デザイン）` | Sonnet | Figma MCP・デザイン→コード |

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

コード修正の委譲先:
- **マルチファイル・マルチ関心事**: `orchestrating-teams` スキルロード → Claude Code本体が直接チーム編成 → **ドメイン別専門タチコマ**複数並列処理
- **単一ファイル・単一関心事の軽微修正**: TeamCreate → **適切な専門タチコマ**1体を `team_name` + `run_in_background: true` で起動（tmux pane）→ 完了後TeamDelete
- **トークン効率重視**: `/serena`コマンドを積極活用

### 例外（Claude Code本体で実行可能）

ファイル読み込み（1-2ファイル）、質問回答、ファイル一覧表示、計画・設計ドキュメント作成、`researching-libraries` によるライブラリ調査

---

## 並列実行の判断基準（🔴 必須チェック）

**以下のいずれかに該当 → `orchestrating-teams` スキルロード → Claude Code本体が直接Agent Team APIで実行:**
1. **2つ以上のファイルを変更** かつ変更が相互に独立
2. **異なる関心事** が含まれる（例: UI + API + テスト）
3. **2つ以上の独立したサブタスク** に分解可能
4. **フロントエンドとバックエンド** の両方を変更
5. **同一ドメインの独立タスクが3つ以上** ある（scale-out: 同一専門タチコマを複数起動して高速化。例: 3ページ同時実装、複数テストスイート同時作成）

**以下の場合のみタチコマ直接起動:**
- 1ファイルのみの変更
- 密結合した変更（前のタスクの出力が次の入力に必要）

### Claude Code本体によるチーム編成と並列実行
- Claude Code本体が `orchestrating-teams` スキルをロードし、Agent Team APIを直接操作
- Claude Code本体がタスク分解・ファイル所有権設計・モデル戦略選択を実施
- Claude Code本体がTeamCreate/TaskCreate/Task tool/SendMessageで各メンバー（タチコマ）を起動・調整・進捗管理
- 詳細仕様: plugin の `skills/orchestrating-teams/` 参照

---

## 実装フロー（並列化対応）

```
ユーザー要求
    ↓
Claude Code本体（実装コードを書かない）
    ↓
【並列実行が必要そう？】（要求内容から即座に判断）
    ├─ Yes → **`orchestrating-teams` スキルロード → 即座にTeamCreate**
    │         Phase 1（現状把握・計画策定 → planner に全委譲）:
    │         1. TeamCreate でチーム作成
    │         2. planner タチコマ起動（subagent_type: `sumik:タチコマ（アーキテクチャ）`, model: opus）
    │            → 現状把握・コードベース分析・docs/plan作成・各タスクの推奨専門タチコマ明記
    │         3. 計画レビュー・ユーザー確認
    │         Phase 2（実装 → ドメイン別専門タチコマ並列起動）:
    │         4. TaskCreate + **ドメイン別専門タチコマ**を `team_name` + `run_in_background: true` で並列起動（tmux pane）
    │            ※ scale-out: 同一subagent_typeを複数起動可（例: タチコマ（Next.js）×3で3ページ同時実装）
    │         5. SendMessage で進捗管理・調整
    │         6. 全メンバー完了後に統合・TeamDelete
    │
    ├─ No（軽微修正） → `rules/skill-triggers.md` ルーティング表で専門タチコマ選択
    │                    → TeamCreate → Task tool（`team_name` + `run_in_background: true`）
    │                    → tmux pane起動 → 完了後TeamDelete
    │
    └─ No（読み込み・質問等） → 直接実行
    ↓
CodeGuard実行（必須）
    ↓ 完了報告
```

---

## 🔴 tmux pane起動ルール（絶対遵守）

**`run_in_background: true` だけではtmux paneに表示されない。** tmux pane起動にはAgent Teams API（TeamCreate + `team_name`）が必須。

| ルール | 詳細 |
|-------|------|
| TeamCreate 必須 | タチコマ起動前に**必ず** TeamCreate でチームを作成（軽微修正でも必須） |
| `team_name` + `run_in_background: true` | Task tool呼び出し時に**両方**指定。`team_name` がtmux pane起動の鍵 |
| 1メッセージ複数Task | 並列起動時は1メッセージ内で複数のTask tool呼び出しを行う |
| Bash tool禁止 | Bash toolでのタチコマ起動は禁止（`--team` 等のCLIオプションは存在しない） |
| 同一専門タチコマ複数起動可 | 同じsubagent_typeを複数並列起動可能（例: `sumik:タチコマ（Next.js）` ×2） |
| 完了後TeamDelete | 単体タスク完了後はTeamDeleteでチームを解放（1セッション1チーム制約） |

### tmux pane起動の正しいフロー

```
1. TeamCreate（team_name: "task-name"）
2. Task tool（team_name: "task-name", run_in_background: true, subagent_type: "sumik:タチコマ（...）"）
   → tmux pane で起動 ✓
3. タチコマ完了待ち
4. TeamDelete
```

### ❌ よくある間違い

```
# NG: run_in_background だけ → pane なし（バックグラウンドのみ）
Task tool（run_in_background: true）  ← team_name なし = pane なし

# OK: TeamCreate + team_name → pane あり
TeamCreate → Task tool（team_name + run_in_background: true） ← pane あり ✓
```

---

## ドキュメント先行開発（Documentation-First Development）

- **作業開始前に必ず`docs/`フォルダにMarkdown形式で計画をまとめる**
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
