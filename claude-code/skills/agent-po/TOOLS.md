# PO Agent ツールガイド

このドキュメントでは、PO Agentが使用する専用ツールとその詳細な使用方法を説明します。

## 🔧 PO Agent専用ツール一覧

PO Agentは以下の4つのツールを使用します：

1. **serena MCP** - プロジェクト分析と構造把握
2. **sequentialthinking MCP** - 複雑な問題の段階的分解
3. **kagi MCP** - 最新技術トレンド調査
4. **Bash** - Worktree管理

---

## 1️⃣ serena MCP（俯瞰的分析）

### 用途
- プロジェクト全体の構造把握
- 既存実装の調査
- 技術的制約の確認

### 主要コマンド

#### プロジェクトアクティベート
```python
# プロジェクトを初期化（最初に1回だけ実施）
mcp__serena__activate_project(project=".")
```

**使用タイミング**:
- プロジェクト作業の最初
- `.serena`ディレクトリが存在しない場合

#### オンボーディング確認
```python
# オンボーディング状態の確認
mcp__serena__check_onboarding_performed()

# オンボーディング未実施の場合は実行
mcp__serena__onboarding()
```

**使用タイミング**:
- プロジェクトアクティベート直後
- 新規プロジェクトの分析開始時

#### シンボル概要取得
```python
# ファイルの構造概要を取得
mcp__serena__get_symbols_overview(relative_path="src/main.ts")

# 複数ファイルの概要を取得
mcp__serena__get_symbols_overview(relative_path="src/services/auth.ts")
mcp__serena__get_symbols_overview(relative_path="src/models/user.ts")
```

**取得できる情報**:
- クラス、関数、変数の一覧
- シンボルの階層構造
- 各シンボルの位置情報

**使用例**:
```python
# 認証関連のコードを確認
overview = mcp__serena__get_symbols_overview(
    relative_path="src/services/auth.ts"
)

# 結果: AuthService クラス、login()、logout() メソッドを確認
```

#### シンボル検索
```python
# 特定のシンボルを検索
mcp__serena__find_symbol(
    name_path="AuthService",
    relative_path="src/services"
)

# パターンマッチング検索
mcp__serena__find_symbol(
    name_path="User",
    relative_path="src/models",
    substring_matching=True
)
```

**使用例**:
```python
# ユーザーモデルの実装を確認
user_symbol = mcp__serena__find_symbol(
    name_path="User",
    relative_path="src/models/user.ts",
    include_body=True  # コード本体も取得
)

# 結果: Userクラスの定義、プロパティ、メソッドを確認
```

#### パターン検索
```python
# 正規表現でコードを検索
mcp__serena__search_for_pattern(
    substring_pattern="review|rating",
    relative_path="src",
    restrict_search_to_code_files=True
)
```

**使用例**:
```python
# レビュー関連の既存実装を確認
review_code = mcp__serena__search_for_pattern(
    substring_pattern="review",
    relative_path="src/models"
)

# 結果: Review クラス、rating プロパティ、関連コードを発見
```

#### メモリ管理
```python
# プロジェクト固有の知識を保存
mcp__serena__write_memory(
    memory_name="authentication_strategy",
    content="""
## 認証戦略

技術選定: NextAuth.js
理由: Next.jsとの統合が優れている

実装方針:
- OAuth 2.0 プロバイダー対応（Google, GitHub）
- JWT トークンベース認証
- セッション管理はサーバーサイド
"""
)

# 保存した知識を読み込み
mcp__serena__read_memory(
    memory_file_name="authentication_strategy.md"
)
```

**使用タイミング**:
- 戦略決定後の知識保存
- 後続のセッションでの情報参照

### serena MCP使用のベストプラクティス

#### ❌ 避けるべき使い方
```python
# ファイル全体を読み込む（トークン無駄遣い）
# ReadツールでファイルをすべてRead
```

#### ✅ 推奨される使い方
```python
# 1. まず概要を取得
overview = mcp__serena__get_symbols_overview(relative_path="src/main.ts")

# 2. 必要なシンボルのみ詳細取得
symbol = mcp__serena__find_symbol(
    name_path="AuthService",
    relative_path="src/services/auth.ts",
    include_body=True
)

# 3. パターン検索で影響範囲を確認
related = mcp__serena__search_for_pattern(
    substring_pattern="AuthService",
    relative_path="src"
)
```

---

## 2️⃣ sequentialthinking MCP（段階的思考）

### 用途
- 複雑な問題の段階的分解
- 戦略の仮説検証
- 意思決定の論理的推論

### 基本的な使い方

```python
mcp__sequentialthinking__sequentialthinking({
    "thought": "現在の思考内容",
    "thoughtNumber": 1,           # 現在の思考番号
    "totalThoughts": 5,           # 予想される総思考数
    "nextThoughtNeeded": True     # 次の思考が必要か
})
```

### パラメータ詳細

| パラメータ | 型 | 説明 |
|-----------|-----|------|
| `thought` | string | 現在の思考ステップの内容 |
| `thoughtNumber` | number | 現在の思考番号（1から開始） |
| `totalThoughts` | number | 予想される総思考数（途中で変更可能） |
| `nextThoughtNeeded` | boolean | 次の思考ステップが必要か |
| `isRevision` | boolean | 前の思考を修正するか |
| `revisesThought` | number | 修正対象の思考番号 |

### 段階的思考の例

#### ケーススタディ: ユーザーレビュー機能の実装戦略

```python
# 思考1: 要件の明確化
mcp__sequentialthinking__sequentialthinking({
    "thought": "ユーザーレビュー機能の要件を明確にする。ユーザーは商品に対してレビューと5段階評価を投稿できる。",
    "thoughtNumber": 1,
    "totalThoughts": 7,
    "nextThoughtNeeded": True
})

# 思考2: 技術候補のリストアップ
mcp__sequentialthinking__sequentialthinking({
    "thought": "技術候補: (1) Next.js App Router + Prisma + PostgreSQL、(2) Next.js Pages Router + MongoDB、(3) Express.js + Sequelize + MySQL",
    "thoughtNumber": 2,
    "totalThoughts": 7,
    "nextThoughtNeeded": True
})

# 思考3: 各技術の評価
mcp__sequentialthinking__sequentialthinking({
    "thought": "候補1が最適と判断。理由: チームの習熟度が高く、型安全性が優れている。",
    "thoughtNumber": 3,
    "totalThoughts": 7,
    "nextThoughtNeeded": True
})

# 思考4: リスクの洗い出し
mcp__sequentialthinking__sequentialthinking({
    "thought": "リスク: Prismaのマイグレーションが複雑になる可能性。対策: 段階的にスキーマを設計。",
    "thoughtNumber": 4,
    "totalThoughts": 7,
    "nextThoughtNeeded": True
})

# 思考5: 優先順位の決定
mcp__sequentialthinking__sequentialthinking({
    "thought": "優先度1: レビュー投稿機能、優先度2: レビュー表示機能、優先度3: レビュー管理機能。",
    "thoughtNumber": 5,
    "totalThoughts": 7,
    "nextThoughtNeeded": True
})

# 思考6: 実装計画の策定
mcp__sequentialthinking__sequentialthinking({
    "thought": "3週間で完成。1週目: データベース設計、2週目: バックエンドAPI、3週目: フロントエンド実装。",
    "thoughtNumber": 6,
    "totalThoughts": 7,
    "nextThoughtNeeded": True
})

# 思考7: 最終決定
mcp__sequentialthinking__sequentialthinking({
    "thought": "戦略確定。Next.js 14 + Prisma + PostgreSQLで実装。新規worktree `wt-feat-user-reviews` を作成。",
    "thoughtNumber": 7,
    "totalThoughts": 7,
    "nextThoughtNeeded": False  # 思考完了
})
```

### 思考の修正と分岐

#### 前の思考を修正する場合
```python
# 思考3を再検討
mcp__sequentialthinking__sequentialthinking({
    "thought": "候補1ではなく候補2が適切かもしれない。MongoDBの方が柔軟性が高い。",
    "thoughtNumber": 4,
    "totalThoughts": 7,
    "nextThoughtNeeded": True,
    "isRevision": True,
    "revisesThought": 3  # 思考3を修正
})
```

#### 思考数を増やす場合
```python
# 予想より複雑だったので思考数を増やす
mcp__sequentialthinking__sequentialthinking({
    "thought": "追加の検討が必要。キャッシング戦略も考慮すべき。",
    "thoughtNumber": 8,
    "totalThoughts": 10,  # 7から10に増加
    "nextThoughtNeeded": True,
    "needsMoreThoughts": True
})
```

---

## 3️⃣ kagi MCP（最新情報調査）

### 用途
- 最新技術トレンドの調査
- ベストプラクティスの確認
- 技術選定のための情報収集

### 主要コマンド

#### Web検索
```python
# 最新のベストプラクティス検索
kagi MCPで以下を検索:
"Next.js 14 authentication best practices"
"Prisma schema design patterns"
"PostgreSQL performance optimization"
```

#### コンテンツ要約
```python
# 技術記事の要約
kagi MCPで以下のURLを要約:
"https://nextjs.org/docs/app/building-your-application/authentication"
```

### 使用例

#### ケース1: 認証技術の調査
```python
# ステップ1: 最新情報を検索
kagi MCPで検索: "Next.js 14 authentication libraries comparison 2024"

# ステップ2: 有力候補の詳細を要約
kagi MCPで要約:
- NextAuth.js公式ドキュメント
- Clerk認証サービス
- Auth0統合ガイド

# ステップ3: ベストプラクティスを確認
kagi MCPで検索: "Next.js 14 JWT vs session authentication"
```

#### ケース2: パフォーマンス最適化の調査
```python
# ステップ1: 最新のパフォーマンス手法を検索
kagi MCPで検索: "PostgreSQL query optimization 2024"

# ステップ2: インデックス戦略を調査
kagi MCPで要約: "PostgreSQL indexing best practices"

# ステップ3: キャッシング手法を確認
kagi MCPで検索: "Next.js data caching strategies"
```

---

## 4️⃣ Bash（Worktree管理）

### 用途
- Worktreeの作成（ユーザー承認後）
- Worktree一覧の確認
- Worktree状態の確認

### 主要コマンド

#### Worktree一覧確認
```bash
# すべてのworktreeを表示
git worktree list

# 出力例:
# /path/to/project         abc1234 [main]
# /path/to/wt-feat-auth    def5678 [feature/auth]
# /path/to/wt-fix-bug-123  ghi9012 [hotfix/bug-123]
```

**使用タイミング**:
- worktree作成前の重複チェック
- 既存worktree確認

#### 新規Worktree作成（ユーザー承認後のみ）
```bash
# 基本形式
git worktree add -b <ブランチ名> <worktree名> <元ブランチ>

# 具体例
git worktree add -b feature/user-auth wt-feat-user-auth main
```

**パラメータ説明**:
- `-b feature/user-auth`: 新規ブランチ名
- `wt-feat-user-auth`: worktree名（ディレクトリ名）
- `main`: 元となるブランチ

**使用タイミング**:
- ユーザーからworktree作成の承認を得た後のみ
- 絶対に勝手に作成しない

#### カテゴリ別worktree作成例

##### 機能開発
```bash
git worktree add -b feature/payment-integration wt-feat-payment main
```

##### バグ修正
```bash
git worktree add -b hotfix/memory-leak wt-fix-memory-leak main
```

##### 緊急修正
```bash
git worktree add -b hotfix/critical-security wt-hotfix-security main
```

##### 実験的開発
```bash
git worktree add -b experimental/new-arch wt-exp-new-arch main
```

##### リリース準備
```bash
git worktree add -b release/v2.0.0 wt-release-v2.0.0 main
```

### Worktree作成の完全フロー

```bash
# ステップ1: 現在のworktree確認
git worktree list

# ステップ2: ユーザーに確認（PO Agentの責任）
# 「worktree `wt-feat-user-auth` を作成してよろしいですか？」

# ステップ3: 承認後に作成
git worktree add -b feature/user-auth wt-feat-user-auth main

# ステップ4: 作成確認
git worktree list

# ステップ5: worktree名をManagerに伝達
# 「作業場所: wt-feat-user-auth」
```

---

## 🔄 ツールの組み合わせパターン

### パターン1: 技術選定プロセス

```
1. serena MCPで既存実装を確認
   ↓
2. kagi MCPで最新トレンドを調査
   ↓
3. sequentialthinking MCPで評価
   ↓
4. 技術選定を決定
```

**実装例**:
```python
# 1. 既存の認証実装を確認
existing_auth = mcp__serena__search_for_pattern(
    substring_pattern="authentication|auth",
    relative_path="src"
)

# 2. 最新のベストプラクティスを調査
# kagi MCPで: "Next.js 14 authentication best practices"

# 3. 段階的に評価
mcp__sequentialthinking__sequentialthinking({
    "thought": "既存実装と最新手法を比較。NextAuth.jsが最適と判断。",
    "thoughtNumber": 3,
    "totalThoughts": 5,
    "nextThoughtNeeded": True
})
```

### パターン2: Worktree管理プロセス

```
1. serena MCPで現在の作業を確認
   ↓
2. Bashでworktree一覧を確認
   ↓
3. sequentialthinking MCPで判断
   ↓
4. ユーザーに確認
   ↓
5. Bashでworktree作成
```

**実装例**:
```bash
# 1. 既存の作業を確認（serena MCP）
# 2. worktree一覧確認
git worktree list

# 3. 新規作業かどうか判断（sequentialthinking）
# 4. ユーザー確認
# 5. 承認後に作成
git worktree add -b feature/new-feature wt-feat-new-feature main
```

---

## ⚡ ツール使用の最適化

### トークン効率の向上

#### serena MCP
- **概要から詳細へ**: まず`get_symbols_overview`で全体像を把握
- **必要な部分のみ取得**: `find_symbol`で特定シンボルのみ取得
- **パターン検索の活用**: 影響範囲を効率的に確認

#### sequentialthinking MCP
- **適切な思考数**: 初期見積もりは少なめに、必要に応じて増やす
- **修正を恐れない**: `isRevision`で前の思考を改善
- **明確な終了**: `nextThoughtNeeded=False`で完了を明示

#### kagi MCP
- **具体的な検索クエリ**: "Next.js authentication"より"Next.js 14 NextAuth.js implementation guide"
- **要約の活用**: 長い記事は要約して効率的に情報取得

---

## 📝 ツール使用チェックリスト

### serena MCP
- [ ] プロジェクトをアクティベートした
- [ ] オンボーディングを確認/実施した
- [ ] 必要なシンボルのみ取得した
- [ ] 戦略決定をメモリに保存した

### sequentialthinking MCP
- [ ] 複雑な問題を段階的に分解した
- [ ] 適切な思考数を設定した
- [ ] 必要に応じて修正した
- [ ] 明確に思考を完了した

### kagi MCP
- [ ] 最新情報を検索した
- [ ] ベストプラクティスを確認した
- [ ] 技術比較を実施した

### Bash（Worktree）
- [ ] worktree一覧を確認した
- [ ] ユーザーに確認を取った（新規作成時）
- [ ] 承認後に作成した
- [ ] worktree名をManagerに伝達した

---

## 🔗 関連ドキュメント

- [WORKFLOWS.md](WORKFLOWS.md) - ツールを使用するワークフロー全体
- [STRATEGY.md](STRATEGY.md) - ツールを活用した戦略決定プロセス
- [REFERENCE.md](REFERENCE.md) - ツール使用の成果物フォーマット

---

**重要**: すべてのツールはPO Agentの戦略決定とWorktree管理を支援します。実装作業には使用しません。
