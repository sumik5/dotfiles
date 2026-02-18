# Team Builder & タチコマシステム

## 概要

| Agent | モデル | 役割 | 禁止事項 |
|-------|--------|------|----------|
| **Claude Code本体（リーダー）** | Opus | タスク判断・`sumik:team-builder` agent起動・最終確認 | - |
| **Team Builder Agent** | Opus | チーム編成・タスク分解・タチコマ並列起動・進捗管理（`sumik:team-builder`） | - |
| **タチコマ** | Sonnet | 実装ワーカー（軽微修正は単体直接起動、複雑タスクはClaude Code本体配下でTeam member化） | ❌change勝手作成、❌jj書込操作、❌指定外changeでの作業 |
| **Serena Expert** | Sonnet | トークン効率化した開発（`/serena`活用） | - |

**補足:**
- **Claude Code本体の役割**: タスク分析・並列化判断を行い、Task toolで `sumik:team-builder` agentを起動してチーム編成を委譲
- **Team Builder Agentの役割**: TeamCreate/TaskCreate/SendMessage等の公式Agent Team APIでチーム操作を実行（docs先行開発、タチコマ並列起動、進捗管理、失敗回復）
- **軽微な修正（1ファイル・単一関心事）**: タチコマ1体を直接起動（team-builder不要）
- **複数ファイル・複雑なタスク**: Claude Code本体 → `sumik:team-builder` agent → タチコマ複数をTeam memberとして並列起動
- Team Builder Agentがファイル所有権パターン設計・タスク分解・モデル戦略選択・進捗管理を担当

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
- **マルチファイル・マルチ関心事**: **Team Builder**（`team-builder` Agent）でチーム編成 → タチコマ複数並列処理
- **単一ファイル・単一関心事の軽微修正**: タチコマ1体を直接起動
- **トークン効率重視**: `/serena`コマンドを積極活用

### 例外（Claude Code本体で実行可能）

ファイル読み込み（1-2ファイル）、質問回答、ファイル一覧表示、計画・設計ドキュメント作成

---

## 並列実行の判断基準（🔴 必須チェック）

**以下のいずれかに該当 → `sumik:team-builder` agentをTask toolで起動:**
1. **2つ以上のファイルを変更** かつ変更が相互に独立
2. **異なる関心事** が含まれる（例: UI + API + テスト）
3. **2つ以上の独立したサブタスク** に分解可能
4. **フロントエンドとバックエンド** の両方を変更

**以下の場合のみタチコマ直接起動:**
- 1ファイルのみの変更
- 密結合した変更（前のタスクの出力が次の入力に必要）

### Team Builder Agentによるチーム編成と並列実行
- Claude Code本体がTask toolで `sumik:team-builder` agentを起動
- Team Builder Agentがタスク分解・ファイル所有権設計・モデル戦略選択を実施
- Team Builder AgentがTeamCreate/TaskCreate/Task tool/SendMessageで各メンバー（タチコマ）を起動・調整・進捗管理
- 詳細仕様: plugin の `agents/team-builder.md` 参照

---

## 実装フロー（並列化対応）

```
ユーザー要求
    ↓
Claude Code本体（タスク分析）
    ↓
【コード修正が必要？】
    ├─ No → 直接実行（読み込み・質問・設計等）
    │
    └─ Yes → 計画をdocs/plan-xxx.mdに作成（複雑な場合）
        ↓ ユーザー確認
        ↓
    【独立サブタスクに分解可能？】（上記判断基準を適用）
        ├─ Yes → **Task toolで `sumik:team-builder` agentを起動**
        │         team-builderが以下を実行:
        │         1. docs/plan-*.md 作成 → ユーザー確認
        │         2. TeamCreate でチーム作成
        │         3. TaskCreate でタスク一覧作成
        │         4. Task tool でタチコマ複数を並列起動（run_in_background: true）
        │         5. SendMessage で進捗管理・調整
        │         6. 全メンバー完了後に統合・TeamDelete
        │
        └─ No  → タチコマ1体を直接起動（Task tool）
        ↓
    CodeGuard実行（必須）
    ↓ 完了報告
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
  - Team Builder Agentが参照するチーム構成・ファイル所有権パターン
  - 各メンバーの担当範囲・要件・排他情報
  - タスクリスト（`- [ ]` チェックリスト形式、進捗追跡用）
  - 実行ログ（進捗・完了状況を記録）
  - 回復手順（失敗時の再開手順）
  - → 詳細: plugin の `agents/team-builder.md` 参照
- ドキュメント作成後、ユーザー確認を経てから実装開始
- 例外: 1ファイル内の軽微な修正（typo修正、1行変更など）
- **ドキュメントは将来の参照用として残す**（作業完了後も削除しない）
- **再開時**: docsファイルのチェックリストと実行ログから状態を復元
