# 判断基準とパフォーマンス最適化

## 🎯 Agent使用の判断基準

### フローチャート: タスク受信時の判断

```
タスク受信
    ↓
コード修正が必要？
    ├─ No
    │   └─→ 直接実行可能
    │       ・ファイル読み込み（1-2ファイル）
    │       ・単純な質問への回答
    │       ・ファイル一覧表示
    │
    └─ Yes
        ↓
        Claude Code本体では絶対に実行しない
        ↓
        新規作業 or 既存作業？
        ├─ 新規作業
        │   └─→ ユーザーに確認
        │       「新しい作業のため、worktree `wt-feat/xxx` を作成しますか？」
        │       ├─ 承認 → worktree作成
        │       └─ 却下 → 既存worktreeで作業
        │
        └─ 既存作業
            └─→ 既存worktree名を把握
        ↓
        複雑なタスク？
        ├─ Yes（複雑）
        │   └─→ PO Agent起動
        │       ├─ 戦略決定
        │       ├─ Worktree管理
        │       └─ Manager指示
        │           ↓
        │       Manager Agent起動
        │       ├─ タスク配分
        │       ├─ Worktree情報伝達
        │       └─ 配分計画返却
        │           ↓
        │       Claude Code（Developer起動）
        │           ↓
        │       複数Developer並列実行
        │
        └─ No（軽微）
            └─→ Developer Agent直接起動
                ・Worktree情報を渡す
                ・単一タスク実行
```

---

## ✅ 直接実装可能な例外ケース

### 条件
以下の**全て**を満たす場合のみ、Agentシステムを使わず直接実装可能：

1. **単純性**: 実装が明白で複雑な判断不要
2. **小規模**: 1-2ファイル、数行程度の変更
3. **影響範囲**: 他の機能への影響がほぼない
4. **非本質的**: プロジェクトの中核機能ではない

### 具体例

#### ✅ OK - 直接実装可能
```
例1: ファイル読み込み
- Read ~/.claude/agents/aramaki.md
- Read package.json

例2: 単純な質問への回答
- 「このプロジェクトで使用している言語は？」
- 「ファイル構造を教えて」

例3: ファイル一覧表示
- Glob: **/*.ts
- Bash: ls -la src/

例4: 1行程度の修正
- タイポ修正（コメント内の誤字）
- インポート文の追加（1行）
```

#### ❌ NG - Agentシステム必須
```
例1: 新機能実装
- ユーザー認証機能の追加
→ PO → Manager → Developer

例2: 複数ファイルのバグ修正
- セキュリティ脆弱性の修正（3ファイル以上）
→ PO → Manager → Developer

例3: リファクタリング
- コンポーネント構造の再設計
→ PO → Manager → Developer

例4: テスト実装
- E2Eテストスイートの作成
→ PO → Manager → Developer

例5: ドキュメント作成（複数ファイル）
- API仕様書、ユーザーガイド、開発者向けドキュメント
→ PO → Manager → Developer
```

---

## ⚡ パフォーマンス最適化のポイント

### 1. Agent定義ファイルの1回読み込み

**最初のセッション開始時のみ**:
```bash
# 3つのAgent定義を一度に読み込む（並列実行）
Read ~/.claude/agents/aramaki.md
Read ~/.claude/agents/kusanagi.md
Read ~/.claude/agents/tachikoma.md
```

**以降のAgent起動時**:
- 定義ファイルの再読み込みは不要
- すでにメモリに読み込まれた定義を参照

**効果**:
- 初回読み込み: 3ファイル × 200行 = 600行読み込み
- 以降の起動: 0行読み込み（参照のみ）
- **大幅な時間短縮**

---

### 2. 複数Developerの同時起動

**❌ 非効率（避けるべき）**:
```bash
# メッセージ1
Agent thread dev1: タスクA
（dev1完了待ち）

# メッセージ2
Agent thread dev2: タスクB
（dev2完了待ち）

# メッセージ3
Agent thread dev3: タスクC
```
**時間**: T(dev1) + T(dev2) + T(dev3) = 合計時間

**✅ 効率的（推奨）**:
```bash
# 1メッセージで全て起動
Agent thread dev1: タスクA
Agent thread dev2: タスクB
Agent thread dev3: タスクC
```
**時間**: max(T(dev1), T(dev2), T(dev3)) = 最長タスクの時間のみ

**効果**:
- 3つのタスクを並列実行すれば、理論上1/3の時間
- 4つのタスクを並列実行すれば、理論上1/4の時間

---

### 3. 不要な往復の回避

**❌ 非効率（曖昧な指示）**:
```
PO → Manager: 「認証機能を実装してください」
Manager → PO: 「JWT? セッション? どちらですか？」
PO → Manager: 「JWTで」
Manager → PO: 「トークンの有効期限は？」
PO → Manager: 「24時間で」
...（繰り返し）
```
**往復回数**: 5回以上

**✅ 効率的（明確な指示）**:
```
PO → Manager:
「認証機能を実装してください。
- JWT方式を採用
- トークン有効期限: 24時間
- リフレッシュトークン: 7日間
- セキュア: httpOnly cookie使用」
Manager → Claude Code: 配分計画返却
```
**往復回数**: 1回

**効果**:
- 往復回数の削減
- 明確な指示による実装ミスの防止
- 全体的な実行時間の短縮

---

### 4. serena MCPでの効率的コード分析

**❌ 非効率（ファイル全体読み込み）**:
```bash
# 全ファイルを読み込む
Read src/components/Auth.tsx  # 500行
Read src/hooks/useAuth.ts     # 300行
Read src/api/auth.ts          # 400行
```
**読み込み量**: 1200行

**✅ 効率的（シンボル単位分析）**:
```bash
# serena MCPでシンボル検索
mcp__serena__find_symbol(name_path="Auth")
mcp__serena__find_symbol(name_path="useAuth")
```
**読み込み量**: 必要なシンボルのみ（100行程度）

**効果**:
- 読み込み量: 1/10以下
- 正確な位置特定
- 影響範囲の把握

---

## 📊 パフォーマンス比較表

| 項目 | 非効率な方法 | 効率的な方法 | 改善率 |
|-----|------------|-------------|--------|
| Agent定義読み込み | 毎回3ファイル | 初回のみ | 90%減 |
| Developer起動 | 順次起動 | 並列起動 | 75%減 |
| 往復回数 | 5回以上 | 1回 | 80%減 |
| コード分析 | ファイル全体 | シンボル単位 | 90%減 |

**総合効果**: 全体的な実行時間を**50-70%短縮**

---

## 🎯 判断基準の具体例

### ケース1: ユーザー登録機能の追加

**判断**:
- ✅ 複雑なタスク
- ✅ 複数ファイル
- ✅ 新機能実装

**実行方法**:
```
PO Agent起動
    ↓ 戦略決定（JWT認証、セキュリティ要件）
Manager Agent起動
    ↓ タスク配分（並列実行可能）
Developer Agents並列起動
    ├─ dev1: フロントエンド（登録フォーム）
    ├─ dev2: バックエンド（登録API）
    ├─ dev3: テスト（E2E）
    └─ dev4: ドキュメント（API仕様）
```

---

### ケース2: タイポ修正（コメント内）

**判断**:
- ✅ 単純
- ✅ 1ファイル、1行
- ✅ 影響範囲なし

**実行方法**:
```bash
# 直接実行可能
Edit src/components/Auth.tsx
old_string: "// Authenitcation logic"
new_string: "// Authentication logic"
```

---

### ケース3: セキュリティ脆弱性修正（5ファイル）

**判断**:
- ✅ 複雑（セキュリティ要件）
- ✅ 複数ファイル
- ✅ 影響範囲大

**実行方法**:
```
PO Agent起動
    ↓ 戦略決定（脆弱性分析、修正方針）
Manager Agent起動
    ↓ タスク配分（段階的実行）
Developer Agents段階的起動
    第1段階（並列）:
    ├─ dev1: 入力検証強化
    └─ dev2: XSS対策
    第2段階（並列）:
    ├─ dev3: CSRF対策
    └─ dev4: テスト強化
```

---

### ケース4: API仕様確認（1ファイル読み込み）

**判断**:
- ✅ 単純な情報取得
- ✅ ファイル読み込みのみ
- ✅ 実装不要

**実行方法**:
```bash
# 直接実行可能
Read docs/api/auth.md
```

---

## 🚨 トラブルシューティング

### 問題1: Developerが順次起動されている

**症状**:
```bash
Agent thread dev1: タスクA
（完了待ち）
Agent thread dev2: タスクB
```

**原因**: Claude Codeが並列起動していない

**解決策**:
```bash
# 1メッセージで全て起動するよう明示
Agent thread dev1: タスクA
Agent thread dev2: タスクB
Agent thread dev3: タスクC
```

---

### 問題2: PO AgentがDeveloperを起動している

**症状**: PO Agentがファイルを編集している

**原因**: PO Agentの役割を逸脱

**解決策**:
- PO Agentは戦略決定とWorktree管理のみ
- Developer起動はClaude Codeが実行

---

### 問題3: Manager AgentがDeveloperを起動している

**症状**: Manager AgentがDeveloper起動コマンドを実行

**原因**: Manager Agentの役割を逸脱

**解決策**:
- Managerは配分計画を返すのみ
- Developer起動はClaude Codeが実行

---

## 🔗 参照

- [ROLES.md](ROLES.md) - 各Agentの役割詳細
- [WORKFLOWS.md](WORKFLOWS.md) - 実行フロー全体
- [PARALLEL-EXECUTION.md](PARALLEL-EXECUTION.md) - 並列実行パターン
