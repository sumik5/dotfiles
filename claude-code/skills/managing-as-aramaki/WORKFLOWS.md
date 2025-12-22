# PO Agent ワークフローガイド

このドキュメントでは、PO Agentの実行手順とプロセスを詳細に説明します。

## 📊 全体ワークフロー

PO Agentは以下の3つの主要フェーズで動作します：

```
1. ユーザー要求の分析
    ↓
2. Worktree管理の判断
    ↓
3. Manager Agentへの指示作成
```

---

## 1️⃣ ユーザー要求の分析

### 実行手順

```
ユーザー要求受信
    ↓
要求の本質を理解
    ↓
実現可能性の検討
    ↓
技術的制約の確認（serena MCP使用）
    ↓
戦略の策定（sequentialthinking使用）
```

### 具体的なアクション

#### ステップ1: 要求の本質理解
- ユーザーが**本当に**求めているものは何か？
- 表面的な要求と真の課題を区別
- ビジネス価値と技術的実現性のバランス

#### ステップ2: 実現可能性の検討
- 現在のプロジェクト状態で実装可能か？
- 必要なリソース（時間、人員、技術）は何か？
- リスクと制約条件の洗い出し

#### ステップ3: 技術的制約の確認
serena MCPを使用してプロジェクト構造を分析：
```python
# プロジェクトアクティベート
mcp__serena__activate_project(project=".")

# オンボーディング確認
mcp__serena__check_onboarding_performed()

# 既存実装の調査
mcp__serena__get_symbols_overview(relative_path="src/main.ts")
```

#### ステップ4: 戦略の策定
sequentialthinking MCPで段階的に思考：
```python
# 複雑な問題を段階的に分解
mcp__sequentialthinking__sequentialthinking({
    "thought": "この機能実装のアプローチを検討",
    "thoughtNumber": 1,
    "totalThoughts": 5,
    "nextThoughtNeeded": True
})
```

---

## 2️⃣ Worktree管理の判断

### 判断フロー

```
新規作業か確認
    ↓
既存作業との関連性分析
    ├─ 関連あり → 既存worktree名を把握
    └─ 関連なし → 新規worktree必要
        ↓
        Step 1: Submoduleの有無を確認
        ├─ Submoduleなし → 通常フロー
        │   ↓
        │   ユーザーに確認
        │   「新しい作業のため、worktree `wt-feat-xxx` を作成しますか？」
        │   ↓
        │   プロジェクトルートにworktree作成
        │
        └─ Submoduleあり → 🚨変更対象を厳密に判断
            ↓
            「何を変更するか？」を明確化
            ├─ 親git自体のコード変更
            │   ↓
            │   ユーザーに確認
            │   「親git自体のコードを変更するため、worktree `wt-feat-xxx` を作成しますか？」
            │   ↓
            │   親gitルートにworktree作成
            │
            └─ Submodule内のコード変更
                🚫 親gitにworktreeを作成してはいけない
                ↓
                ユーザーに確認
                「submodule1内のコードを変更するため、
                 submodule1に worktree `wt-feat-xxx` を作成しますか？
                 ※親gitにはworktreeを作成しません」
                ↓
                対象submodule内にのみworktree作成
```

### 🚨 Step 1: Submoduleの有無を確認（必須）

```bash
ls -la .gitmodules
git submodule status
```

### 新規worktree作成の判断基準

#### 【Submoduleがない場合】通常フロー

##### ✅ 新規worktree作成が必要なケース
- 既存の作業と**独立した**新機能
- 異なる実装方針の**プロトタイプ**
- 緊急のバグ修正（**hotfix**）
- リリース準備作業

##### ❌ 既存worktree継続が適切なケース
- 既存機能の**拡張**
- 現在作業中の機能の**改善**
- 関連するバグ修正

#### 【Submoduleがある場合】🚨変更対象を厳密に判断

**⚠️ 絶対ルール: submodule内のコードを変更する場合、親gitにworktreeを作成してはいけない**

| 変更対象 | worktree作成場所 | worktreeパス |
|---------|-----------------|-------------|
| 親git自体のコード | 親gitルート | `wt-feat-xxx` |
| Submodule内のコード | 対象submodule内のみ | `submodule名/wt-feat-xxx`（🚫親gitには作らない） |

### ユーザー確認プロセス（AskUserQuestion形式必須）

**すべてのworktree確認はAskUserQuestion形式で行う**

#### Step 0: 作業場所の選択（最初に必ず確認）

```python
AskUserQuestion(
    questions=[{
        "question": "新しい作業を開始します。作業場所を選択してください",
        "header": "作業場所",
        "options": [
            {
                "label": "現在のブランチで作業",
                "description": f"現在のブランチ `{current_branch}` で直接作業"
            },
            {
                "label": "新規worktreeを作成",
                "description": "独立したworktreeで並行開発"
            }
        ],
        "multiSelect": False
    }]
)
```

#### Step 1: Submoduleがある場合の変更対象選択

```python
AskUserQuestion(
    questions=[{
        "question": "変更対象を選択してください",
        "header": "変更対象",
        "options": [
            {
                "label": "親git側のコード",
                "description": "プロジェクトルートの設定ファイルや親gitのソースコード"
            },
            {
                "label": f"Submodule: {submodule_name}",
                "description": f"{submodule_name}内のコードを変更（親gitにはworktree作成しない）"
            }
        ],
        "multiSelect": False
    }]
)
```

#### Step 2: Worktree作成確認（Submoduleなしまたは親git変更）

```python
AskUserQuestion(
    questions=[{
        "question": f"worktree `wt-feat-{feature_name}` を作成しますか？",
        "header": "Worktree作成",
        "options": [
            {
                "label": "作成する",
                "description": f"ブランチ `feature/{feature_name}` を作成（元: main）"
            },
            {
                "label": "作成しない",
                "description": "現在のブランチで作業を継続"
            }
        ],
        "multiSelect": False
    }]
)
```

#### Step 3: Worktree作成確認（Submodule内変更）

```python
AskUserQuestion(
    questions=[{
        "question": f"{submodule_name}内にworktreeを作成しますか？",
        "header": "Submodule Worktree",
        "options": [
            {
                "label": "作成する",
                "description": f"{submodule_name}/wt-feat-{feature_name} を作成（親gitには作成しない）"
            },
            {
                "label": "作成しない",
                "description": f"{submodule_name}の現在のブランチで作業"
            }
        ],
        "multiSelect": False
    }]
)
```

#### 承認取得後の作業

##### Submoduleなしまたは親git自体の変更
```bash
# worktree一覧確認（既存との重複チェック）
git worktree list

# 新規worktree作成
git worktree add -b feature/user-authentication wt-feat-user-authentication main
```

##### Submodule内の変更
```bash
# 🚫 親gitにはworktreeを作成しない

# 対象submoduleに移動
cd submodule1

# submodule内でworktree作成
git worktree add -b feature/xxx wt-feat-xxx main

# worktreeに移動
cd wt-feat-xxx
```

### 既存worktree使用の場合
```bash
# worktree一覧確認
git worktree list

# 既存worktree名を把握
# 例: wt-feat-payment が既に存在
```

Manager Agentに既存worktree名を伝達します。

---

## 3️⃣ Manager Agentへの指示作成

### 指示作成フロー

```
戦略決定
    ↓
worktree情報の準備
    ├─ 新規worktree名
    └─ または既存worktree名
    ↓
Manager向け指示作成
    ├─ プロジェクト目標
    ├─ 実装方針
    ├─ 技術選定
    ├─ 優先順位
    └─ **worktree情報**
    ↓
Managerに引き継ぎ
```

### Manager指示に含める内容

#### 1. プロジェクト目標
明確で測定可能な目標を設定：
- 何を実現するのか？
- 成功の定義は何か？
- ユーザー価値は何か？

#### 2. 実装方針
技術的なアプローチと設計方針：
- アーキテクチャパターン
- 技術スタック
- コーディング規約
- セキュリティ要件

#### 3. Worktree情報（最重要）
Managerが使用するworktree情報：
- **作業場所**: `wt-feat-user-authentication`
- **ブランチ**: `feature/user-authentication`
- **元ブランチ**: `main`

#### 4. 制約条件
実装時の制約：
- 技術的制約（既存システムとの互換性）
- 時間的制約（期限）
- リソース制約（利用可能なツール）

#### 5. 優先順位
タスクの優先順位付け：
1. 最優先事項
2. 次に重要な事項
3. その他（時間が許せば）

---

## 🔄 フェーズ間の連携

### 分析 → Worktree判断
- serena MCPで分析した結果をもとに新規作業かどうかを判断
- 既存実装との関連性を確認
- worktree作成の必要性を決定

### Worktree判断 → Manager指示
- 決定したworktree情報をManager指示に含める
- worktree名、ブランチ名、元ブランチを明記
- Manager Agentがこの情報をDeveloper Agentに伝達

---

## ⚡ パフォーマンス最適化

### 効率的な分析手法

#### 1. serena MCPで構造把握
**❌ 避けるべき**:
- ファイル全体を読み込む
- 不要なシンボルまで取得

**✅ 推奨**:
- シンボル検索で必要な情報のみ取得
- 概要取得から詳細へ段階的にアプローチ

#### 2. 段階的思考の活用
**sequentialthinkingの効果的な使用**:
- 複雑な判断を段階的に分解
- 仮説を立てて検証
- 思考プロセスを可視化

#### 3. 情報収集の優先順位
1. **プロジェクト内**: serena MCP
2. **技術情報**: kagi MCP
3. **ライブラリ仕様**: context7 MCP

---

## 📝 実行チェックリスト

### 要求分析フェーズ
- [ ] ユーザー要求の本質を理解した
- [ ] 実現可能性を検討した
- [ ] serena MCPで技術的制約を確認した
- [ ] sequentialthinkingで戦略を策定した

### Worktree判断フェーズ
- [ ] 新規作業か既存作業かを判断した
- [ ] 新規の場合、ユーザーに確認を取った
- [ ] ユーザー承認後にworktreeを作成した
- [ ] または既存worktree名を把握した

### Manager指示作成フェーズ
- [ ] プロジェクト目標を明確にした
- [ ] 実装方針を決定した
- [ ] Worktree情報を含めた
- [ ] 制約条件を洗い出した
- [ ] 優先順位を付けた

---

## 🔗 関連ドキュメント

- [STRATEGY.md](STRATEGY.md) - 戦略決定の詳細な判断基準
- [TOOLS.md](TOOLS.md) - 各MCPツールの詳細な使用方法
- [REFERENCE.md](REFERENCE.md) - Manager指示の具体的なフォーマット

---

**重要**: すべてのフェーズで、PO Agentは実装を行いません。戦略決定とWorktree管理に専念します。
