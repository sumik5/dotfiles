# Agent実行フローとコンテキスト管理

## 📋 実行順序の厳守

### 3段階の階層的実行

```
1. PO Agent起動
   └─ 戦略決定 + Worktree管理
       ↓
2. Manager Agent起動
   └─ タスク配分 + Worktree情報伝達
       ↓
3. Developer Agents並列起動（Claude Codeが実行）
   └─ 実装作業（Worktree配下）
```

---

## 🎯 Stage 1: PO Agent起動

### 入力
- ユーザーからの要求
- プロジェクトの現状

### 実行内容

1. **要求分析**
   - ユーザー要求の理解と解釈
   - プロジェクト全体への影響評価

2. **Worktree判断**
   - 新規作業か既存作業か判断
   - **新規の場合**: ユーザーに確認してworktree作成
   - **既存の場合**: 既存worktree名を把握

3. **戦略決定**
   - 実装方針の策定
   - 技術選定
   - リスク評価

4. **Manager指示作成**
   - 明確な戦略的指示
   - Worktree情報の明示
   - 期待される成果物の定義

### 出力
- Managerへの指示書（Worktree情報含む）
- 戦略的方針
- Worktree情報（新規作成時は名前、既存時は識別）

### 使用ツール
```bash
# Agent定義読み込み
Read ~/.claude/agents/aramaki-agent.md

# Worktree作成（ユーザー承認後）
Bash: git worktree add -b feature/xxx wt-feat-xxx main

# コードベース俯瞰
mcp__serena__get_symbols_overview()

# 戦略的思考
mcp__sequentialthinking__sequentialthinking()
```

---

## 🎯 Stage 2: Manager Agent起動

### 入力
- POからの戦略的指示
- Worktree情報
- ユーザー要求

### 実行内容

1. **タスク分析**
   - 戦略をタスクに分解
   - 依存関係の整理
   - 並列化可能性の判断

2. **配分計画作成**
   - 各Developerへのタスク割り当て
   - 実行順序の決定（並列/段階/順次）
   - Worktree情報の各タスクへの付与

3. **計画の詳細化**
   - 具体的な作業内容の明確化
   - 成果物の定義
   - 完了基準の設定

### 出力
- Claude Codeへの配分計画
- Developer向け詳細指示（Worktree情報含む）
- 実行順序の明示

### 使用ツール
```bash
# Agent定義読み込み
Read ~/.claude/agents/kusanagi-agent.md

# 詳細なコード分析
mcp__serena__find_symbol()
mcp__serena__search_for_pattern()

# タスク分割思考
mcp__sequentialthinking__sequentialthinking()
```

### 重要事項
**Managerは計画を返すだけで、Developer起動は行いません。**
起動はClaude Codeが実行します。

---

## 🎯 Stage 3: Developer Agents並列起動

### 入力
- Managerからの配分計画
- Worktree情報
- 具体的なタスク指示

### 実行内容（各Developer）

1. **Worktree移動**
   ```bash
   cd wt-feat-xxx
   pwd  # 確認
   git branch  # ブランチ確認
   ```

2. **環境設定**
   ```bash
   # 必要に応じて環境変数コピー
   cp ../.env .env

   # .serenaをコピー（初期化不要）
   cp -r ../.serena .serena
   ```

3. **実装作業**
   - コード作成・編集
   - テスト実装
   - ドキュメント作成

4. **完了報告**
   - 成果物の記述
   - 作業内容の詳細
   - 次ステップの提案（あれば）

### 並列起動の例
```bash
# Claude CodeがManager計画を受けて、1メッセージで4つ同時起動
Agent thread dev1: フロントエンド実装（wt-feat-xxx）
Agent thread dev2: バックエンドAPI実装（wt-feat-xxx）
Agent thread dev3: テスト実装（wt-feat-xxx）
Agent thread dev4: ドキュメント作成（wt-feat-xxx）
```

---

## 📝 Agent間のコンテキスト管理

### コンテキストフロー全体図

```
┌─────────────┐
│ユーザー要求 │
└──────┬──────┘
       ↓
┌─────────────────────────────────┐
│     PO Agent（戦略決定）         │
├─────────────────────────────────┤
│ 入力: ユーザー要求               │
│ 処理: 戦略分析、Worktree判断     │
│ 出力: 戦略指示 + Worktree情報    │
└──────┬──────────────────────────┘
       ↓ 戦略的指示 + Worktree情報
┌─────────────────────────────────┐
│   Manager Agent（タスク配分）    │
├─────────────────────────────────┤
│ 入力: PO指示 + Worktree情報      │
│ 処理: タスク分割、配分計画       │
│ 出力: 配分計画 + Worktree情報    │
└──────┬──────────────────────────┘
       ↓ 配分計画 + Worktree情報
┌─────────────────────────────────┐
│ Claude Code（Developer起動制御） │
├─────────────────────────────────┤
│ 入力: Manager計画                │
│ 処理: Developer並列起動          │
└──────┬──────────────────────────┘
       ↓ タスク指示 + Worktree情報
┌─────────────────────────────────┐
│ Developer Agents（並列実行）     │
├─────────────────────────────────┤
│ dev1: Frontend（wt-feat-xxx）    │
│ dev2: Backend（wt-feat-xxx）     │
│ dev3: Test（wt-feat-xxx）        │
│ dev4: Docs（wt-feat-xxx）        │
└──────┬──────────────────────────┘
       ↓ 完了報告（各Worktree内の成果）
┌─────────────────────────────────┐
│   Manager Agent（統合報告）      │
├─────────────────────────────────┤
│ 入力: 各Developer完了報告        │
│ 処理: 統合、整合性確認           │
│ 出力: プロジェクト完了報告       │
└──────┬──────────────────────────┘
       ↓ プロジェクト完了報告
┌─────────────────────────────────┐
│    PO Agent（最終確認）          │
├─────────────────────────────────┤
│ 入力: Manager統合報告            │
│ 処理: 戦略目標達成確認           │
│ 出力: ユーザーへの最終報告       │
└──────┬──────────────────────────┘
       ↓
┌─────────────┐
│ユーザーへ報告│
└─────────────┘
```

---

## 🔄 コンテキスト伝達の詳細

### PO → Manager

**伝達内容**:
```
- 戦略的方針
- 技術選定の理由
- Worktree情報（名前、ブランチ）
- 期待される成果物
- 制約条件
```

**形式例**:
```markdown
【Managerへの指示】

戦略的方針：
- ユーザー認証機能の実装
- JWT方式を採用

Worktree情報：
- 新規作成: wt-feat-user-auth
- ブランチ: feature/user-auth

期待される成果物：
- 認証API実装
- フロントエンド統合
- E2Eテスト
```

---

### Manager → Claude Code → Developer

**伝達内容**:
```
- 具体的なタスク内容
- 担当領域
- Worktree情報（各Developerへ）
- 依存関係
- 完了基準
```

**形式例**:
```markdown
【配分計画】

実行方式: 並列実行

dev1（Frontend）:
- タスク: ログイン画面実装
- Worktree: wt-feat-user-auth
- 成果物: LoginForm.tsx, useAuth.ts

dev2（Backend）:
- タスク: 認証API実装
- Worktree: wt-feat-user-auth
- 成果物: /api/auth/login, /api/auth/logout

dev3（Test）:
- タスク: E2Eテスト
- Worktree: wt-feat-user-auth
- 成果物: auth.e2e.test.ts

dev4（Docs）:
- タスク: API仕様書
- Worktree: wt-feat-user-auth
- 成果物: docs/api/auth.md
```

---

### Developer → Manager

**伝達内容**:
```
- 受領したタスク内容
- 実行結果
- 作成した成果物
- Worktree内での作業確認
- 課題・問題点（あれば）
```

**形式例**:
```markdown
【完了報告 - dev1】

受領タスク: ログイン画面実装（wt-feat-user-auth）

実行結果:
- LoginForm.tsxを作成
- useAuth.tsカスタムフック実装
- バリデーション実装

成果物:
- src/components/LoginForm.tsx
- src/hooks/useAuth.ts
- src/types/auth.ts

Worktree確認: wt-feat-user-auth配下で作業完了

次の指示をお待ちしています。
```

---

## ⚡ 効率的なワークフロー

### 1. Agent定義ファイルの1回読み込み

**最初のセッション開始時のみ**:
```bash
# 3つのAgent定義を一度に読み込む
Read ~/.claude/agents/aramaki-agent.md
Read ~/.claude/agents/kusanagi-agent.md
Read ~/.claude/agents/tachikoma-agent.md
```

**以降のAgent起動時**:
- 定義ファイルの再読み込み不要
- すでに読み込まれた定義を参照

### 2. 不要な往復の回避

**良い例（効率的）**:
```
PO → Manager: 明確な戦略＋Worktree情報
Manager → Claude Code: 具体的な配分計画＋Worktree情報
Claude Code → Developer: 詳細タスク＋Worktree情報
```

**悪い例（非効率）**:
```
PO → Manager: 曖昧な指示
Manager → PO: 確認（往復1）
PO → Manager: 追加情報
Manager → PO: 再確認（往復2）
...（繰り返し）
```

### 3. 並列実行の徹底

**Developer起動は必ず1メッセージで同時実行**:
```bash
# 良い例: 1メッセージで4つ同時起動
Agent thread dev1 & dev2 & dev3 & dev4

# 悪い例: 1つずつ起動
Agent thread dev1
（dev1完了待ち）
Agent thread dev2
（dev2完了待ち）
...
```

---

## 🔗 参照

- [ROLES.md](ROLES.md) - 各Agentの役割詳細
- [PARALLEL-EXECUTION.md](PARALLEL-EXECUTION.md) - 並列実行パターン
- [GUIDELINES.md](GUIDELINES.md) - 判断基準と最適化
