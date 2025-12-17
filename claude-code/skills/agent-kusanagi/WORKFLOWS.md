# Manager Agent ワークフロー詳細

このファイルでは、Manager Agentの詳細なワークフロー手順を説明します。

## 📋 目次

- [基本ワークフロー](#基本ワークフロー)
- [ステップ1: PO指示の受信](#ステップ1-po指示の受信)
- [ステップ2: Worktree情報の確認](#ステップ2-worktree情報の確認)
- [ステップ3: serena MCPでコード分析](#ステップ3-serena-mcpでコード分析)
- [ステップ4: sequentialthinkingで依存関係分析](#ステップ4-sequentialthinkingで依存関係分析)
- [ステップ5: タスク配分計画の作成](#ステップ5-タスク配分計画の作成)
- [ステップ6: Claude Codeへ計画を返す](#ステップ6-claude-codeへ計画を返す)

## 🚀 基本ワークフロー

```
1. PO指示の受信
   ↓
2. Worktree情報の確認
   ↓
3. serena MCPでコード分析
   ↓
4. sequentialthinkingで依存関係分析
   ↓
5. タスク配分計画の作成
   ↓
6. Claude Codeへ計画を返す
```

## ステップ1: PO指示の受信

### 受信する情報

PO Agentから以下の情報を受け取ります：

1. **プロジェクト戦略**
   - 実装すべき機能の概要
   - ビジネス要件
   - 技術的制約

2. **Worktree情報**
   - 作業場所（worktree名）
   - ブランチ名
   - 作業の種類（新規/既存）

3. **優先順位と期限**
   - タスクの優先度
   - 完了期限
   - 依存関係の情報

### 確認事項

- [ ] PO指示の内容が明確か
- [ ] Worktree情報が正確か
- [ ] 技術的に実現可能か
- [ ] 必要なリソースは揃っているか

## ステップ2: Worktree情報の確認

### Worktree情報の把握

```bash
# Worktree一覧の確認
git worktree list

# 指定されたWorktreeの存在確認
# 例: wt-feat-auth の確認
ls -la | grep wt-feat-auth
```

### 確認項目

1. **Worktreeの存在確認**
   - POが作成したworktreeが存在するか
   - ブランチ名が正しいか

2. **作業環境の確認**
   - 必要な環境変数ファイル（.env）の存在
   - 必要な依存関係のインストール状況

3. **Worktree情報の記録**
   - すべてのDeveloperに伝達する情報を整理
   - 作業場所、ブランチ名を明確化

### Worktree情報の例

```markdown
### Worktree情報
- 作業場所: wt-feat-auth
- ブランチ: feature/user-auth
- 基点ブランチ: main
- 作業種別: 新規機能実装
```

## ステップ3: serena MCPでコード分析

### 分析の目的

- コードベースの構造を理解
- 既存の関連コードを特定
- 影響範囲を把握
- 依存関係を洗い出し

### 使用するserena MCPツール

#### 1. プロジェクト構造の把握

```
mcp__serena__list_dir
- relative_path: "."
- recursive: true
- skip_ignored_files: true
```

#### 2. 関連シンボルの検索

```
mcp__serena__find_symbol
- name_path: "対象のクラスや関数名"
- relative_path: "検索対象ディレクトリ"
- include_body: false  # 最初は構造のみ
```

#### 3. シンボル間の参照関係

```
mcp__serena__find_referencing_symbols
- name_path: "調査対象のシンボル"
- relative_path: "対象ファイル"
```

#### 4. パターン検索（必要に応じて）

```
mcp__serena__search_for_pattern
- substring_pattern: "検索パターン"
- relative_path: "検索範囲"
- restrict_search_to_code_files: true
```

### 分析結果の整理

収集した情報を以下の観点で整理：

1. **影響を受けるファイル**
   - 既存のコードで変更が必要な箇所
   - 新規作成が必要なファイル

2. **依存関係**
   - 他のモジュールへの依存
   - 他のモジュールからの参照

3. **技術スタック**
   - 使用している技術
   - 必要なライブラリやツール

## ステップ4: sequentialthinkingで依存関係分析

### 段階的思考プロセス

sequentialthinking MCPを使用して、複雑なタスクを段階的に分解：

```
mcp__sequentialthinking__sequentialthinking
- thought: "タスクAとタスクBの依存関係を分析"
- thoughtNumber: 1
- totalThoughts: 5 (推定)
- nextThoughtNeeded: true
```

### 分析の観点

#### 1. タスク間の依存関係

```
思考1: タスクAは独立して実行可能か？
  → Yes: 並列実行候補
  → No: 依存タスクを特定

思考2: タスクBはタスクAの完了を待つ必要があるか？
  → Yes: 段階的実行
  → No: 並列実行可能

思考3: タスクCとタスクDは相互に依存しているか？
  → Yes: 順次実行または再設計が必要
  → No: 並列実行可能
```

#### 2. データフローの分析

```
思考4: データの流れを追跡
  API実装 → データモデル → UI表示
  └─ 依存: APIが先、UIは後

思考5: 共有リソースの特定
  データベーススキーマ変更
  └─ 影響: 複数のタスクに影響するため、最初に実施
```

#### 3. 並列化の可能性

```
思考6: 並列実行可能なタスクのグループ化
  グループA: フロントエンド、バックエンド、テスト、ドキュメント
  └─ 判断: 完全に独立 → 並列実行可能
```

### 実行方法の決定

分析結果から、以下のいずれかを選択：

1. **【並列実行可能】**
   - すべてのタスクが独立
   - dev1〜dev4を同時起動

2. **【段階的実行】**
   - 一部に依存関係あり
   - 段階ごとに並列実行

3. **【順次実行】**（極力避ける）
   - 強い依存関係
   - 1つずつ順に実行

## ステップ5: タスク配分計画の作成

### 計画に含める情報

各Developer向けのタスクについて、以下を明確化：

#### 1. Developerの割り当て

- **Developer 1（dev1）**: フロントエンド担当
- **Developer 2（dev2）**: バックエンド担当
- **Developer 3（dev3）**: テスト担当
- **Developer 4（dev4）**: ドキュメント担当

#### 2. タスク詳細

各Developerのタスクに以下を記載：

```markdown
### Developer 1（フロントエンド）
**タスク**: ログインフォームの実装
**Worktree**: wt-feat-auth
**成果物**:
- src/components/LoginForm.tsx
- src/components/LoginForm.test.tsx
**技術要件**:
- React Hook Form使用
- zodでバリデーション
- shadcn/uiコンポーネント使用
**依存関係**: なし（並列実行可能）
**完了条件**:
- [ ] フォームコンポーネント実装
- [ ] 単体テスト実装（カバレッジ80%以上）
- [ ] CodeGuardチェック通過
```

#### 3. 実行順序の明示

```markdown
### 実行方法: 【並列実行可能】

すべてのDeveloperを同時起動してください。
タスク間に依存関係はありません。
```

または

```markdown
### 実行方法: 【段階的実行】

**第1段階**: Developer 1, 2を同時起動
- フロントエンド、バックエンドの基本実装

**第2段階**: 第1段階完了後、Developer 3, 4を同時起動
- テスト、ドキュメント作成
```

### 配分計画のチェックリスト

作成した計画が以下を満たしているか確認：

- [ ] すべてのWorktree情報が正確に記載されている
- [ ] 各Developerのタスクが明確である
- [ ] 成果物が具体的に定義されている
- [ ] 依存関係が正しく分析されている
- [ ] 実行方法（並列/段階的/順次）が明示されている
- [ ] 技術要件が具体的である
- [ ] 完了条件が測定可能である

## ステップ6: Claude Codeへ計画を返す

### 計画の返却

作成した配分計画をClaude Codeに返します。

**重要**:
- ❌ Developerを直接起動しない
- ✅ 計画のみを返す
- ✅ Claude Codeが計画に基づいてDeveloperを起動

### 返却フォーマット

```markdown
## タスク配分計画

### Worktree情報
- 作業場所: wt-feat-auth
- ブランチ: feature/user-auth

### 実行方法: 【並列実行可能】

### Developer 1（フロントエンド）
...（詳細）

### Developer 2（バックエンド）
...（詳細）

### Developer 3（テスト）
...（詳細）

### Developer 4（ドキュメント）
...（詳細）
```

### 計画返却後の流れ

```
Manager → 計画を返す
    ↓
Claude Code → 計画を受信
    ↓
Claude Code → Developerを起動（並列/段階的/順次）
    ↓
Developers → 実装作業開始（Worktree配下）
    ↓
Developers → 完了報告
    ↓
Manager → 統合確認（必要に応じて）
    ↓
PO → 最終確認
```

## 🔍 ワークフロー実行時の注意点

### serena MCP使用時の注意

1. **必要最小限の検索**
   - ファイル全体を読み込まない
   - シンボル単位で検索

2. **段階的な分析**
   - まず構造を把握（include_body: false）
   - 必要に応じて詳細を取得（include_body: true）

3. **検索範囲の絞り込み**
   - relative_pathで検索範囲を限定
   - パフォーマンス向上

### sequentialthinking使用時の注意

1. **適切な思考数の見積もり**
   - 複雑さに応じて調整
   - 途中で変更可能

2. **具体的な思考内容**
   - 曖昧な思考を避ける
   - 具体的な判断基準を明示

3. **分岐と修正**
   - 必要に応じて思考を分岐
   - 間違いに気づいたら修正

## 🔗 関連ファイル

- **[SKILL.md](./SKILL.md)** - 概要に戻る
- **[TASK-DISTRIBUTION.md](./TASK-DISTRIBUTION.md)** - タスク配分計画の詳細
- **[TOOLS.md](./TOOLS.md)** - 使用ツールの詳細
- **[REFERENCE.md](./REFERENCE.md)** - 禁止事項と成果物フォーマット
