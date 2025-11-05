# 使用ツール詳細リファレンス

このファイルでは、Manager Agentが使用する主要なMCPツールの詳細な使い方を説明します。

## 📋 目次

- [serena MCP - コード分析ツール](#serena-mcp---コード分析ツール)
- [sequentialthinking MCP - 段階的思考ツール](#sequentialthinking-mcp---段階的思考ツール)
- [その他の補助ツール](#その他の補助ツール)

## 🔍 serena MCP - コード分析ツール

serena MCPは、コードベースの詳細分析とシンボル間の依存関係調査に使用する最も重要なツールです。

### 基本原則

1. **ピンポイント分析**: 必要な部分のみを検索
2. **段階的取得**: まず構造、次に詳細
3. **範囲の限定**: relative_pathで検索範囲を絞る

### 主要ツール一覧

#### 1. list_dir - ディレクトリ構造の把握

**用途**: プロジェクト全体の構造を理解する

**使用例**:
```
mcp__serena__list_dir
- relative_path: "."
- recursive: true
- skip_ignored_files: true
```

**パラメータ**:
- `relative_path`: 調査対象のディレクトリ（"."でプロジェクトルート）
- `recursive`: サブディレクトリも含めるか
- `skip_ignored_files`: .gitignoreファイルを無視するか

**使用タイミング**:
- プロジェクト構造の全体把握
- 新しいファイルの配置場所の決定
- 関連ファイルの探索

#### 2. get_symbols_overview - ファイルのシンボル一覧取得

**用途**: ファイル内のクラス、関数、変数の構造を把握

**使用例**:
```
mcp__serena__get_symbols_overview
- relative_path: "src/services/user-service.ts"
```

**パラメータ**:
- `relative_path`: 対象ファイルのパス

**使用タイミング**:
- 新しいファイルの理解
- 編集対象シンボルの特定
- ファイル構造の把握

**出力例**:
```
UserService (Class)
├── constructor
├── createUser (Method)
├── updateUser (Method)
└── deleteUser (Method)

validateUserData (Function)
generateUserId (Function)
```

#### 3. find_symbol - シンボルの検索

**用途**: 特定のクラス、関数、変数を正確に検索

**使用例**:
```
mcp__serena__find_symbol
- name_path: "UserService/createUser"
- relative_path: "src/services"
- include_body: false  # 最初は構造のみ
```

**パラメータ**:
- `name_path`: シンボルのパス（"クラス名/メソッド名"形式）
- `relative_path`: 検索範囲（ディレクトリまたはファイル）
- `include_body`: シンボルの本体を含めるか
- `depth`: 子シンボルを取得する深さ

**name_pathの指定方法**:
```
# 単純な名前検索
"createUser"  # createUserという名前のシンボルすべて

# 絶対パス検索
"/UserService"  # トップレベルのUserServiceのみ

# 相対パス検索
"UserService/createUser"  # UserServiceクラス内のcreateUserメソッド

# ネストしたクラス
"OuterClass/InnerClass/method"
```

**使用タイミング**:
- 編集対象の正確な位置特定
- シンボルの定義確認
- メソッドやプロパティの一覧取得

#### 4. find_referencing_symbols - 参照元の検索

**用途**: 特定のシンボルがどこから参照されているか調査

**使用例**:
```
mcp__serena__find_referencing_symbols
- name_path: "createUser"
- relative_path: "src/services/user-service.ts"
```

**パラメータ**:
- `name_path`: 調査対象のシンボル
- `relative_path`: シンボルが定義されているファイル

**使用タイミング**:
- 影響範囲の調査
- リファクタリング前の準備
- 依存関係の把握

**出力例**:
```
createUserがこれらのファイルから参照されています:
- src/api/users/route.ts (Line 45)
- src/components/SignupForm.tsx (Line 89)
- tests/services/user-service.test.ts (Line 23)
```

#### 5. search_for_pattern - パターン検索

**用途**: 正規表現でコードパターンを検索

**使用例**:
```
mcp__serena__search_for_pattern
- substring_pattern: "await.*fetch"
- relative_path: "src/api"
- restrict_search_to_code_files: true
```

**パラメータ**:
- `substring_pattern`: 正規表現パターン
- `relative_path`: 検索範囲
- `restrict_search_to_code_files`: コードファイルのみ検索
- `context_lines_before`: マッチ前の行数
- `context_lines_after`: マッチ後の行数

**使用タイミング**:
- 特定のパターンの使用箇所調査
- アンチパターンの検出
- ライブラリの使用状況確認

#### 6. replace_symbol_body - シンボルの置換（使用禁止）

**注意**: Manager Agentは絶対に使用しません。Developer Agentのみが使用します。

### serena MCP使用のベストプラクティス

#### 1. 段階的な情報取得

```
ステップ1: ディレクトリ構造の把握
mcp__serena__list_dir
- relative_path: "."
- recursive: true

ステップ2: 関連ファイルのシンボル一覧取得
mcp__serena__get_symbols_overview
- relative_path: "src/services/user-service.ts"

ステップ3: 特定シンボルの詳細取得
mcp__serena__find_symbol
- name_path: "UserService/createUser"
- include_body: true  # ここで初めてbodyを取得

ステップ4: 影響範囲の確認
mcp__serena__find_referencing_symbols
- name_path: "createUser"
- relative_path: "src/services/user-service.ts"
```

#### 2. 検索範囲の絞り込み

```
❌ 悪い例: 範囲が広すぎる
mcp__serena__find_symbol
- name_path: "createUser"
- relative_path: "."  # プロジェクト全体を検索

✅ 良い例: 範囲を限定
mcp__serena__find_symbol
- name_path: "createUser"
- relative_path: "src/services"  # servicesディレクトリのみ
```

#### 3. include_bodyの使い分け

```
最初の調査: include_body: false
└─ 構造のみを把握（高速）

詳細が必要: include_body: true
└─ 実装内容を確認（必要な場合のみ）
```

### serena MCP使用例（実践）

#### 例1: 新機能追加の影響範囲調査

```
# 1. 既存のユーザーサービスの構造を把握
mcp__serena__get_symbols_overview
- relative_path: "src/services/user-service.ts"

# 2. createUserメソッドの詳細を確認
mcp__serena__find_symbol
- name_path: "UserService/createUser"
- relative_path: "src/services/user-service.ts"
- include_body: true

# 3. createUserの参照元を調査
mcp__serena__find_referencing_symbols
- name_path: "createUser"
- relative_path: "src/services/user-service.ts"

# 4. データベース操作のパターンを検索
mcp__serena__search_for_pattern
- substring_pattern: "prisma\\.user\\."
- relative_path: "src/services"
- restrict_search_to_code_files: true
```

#### 例2: リファクタリングの準備

```
# 1. 対象クラスのすべてのメソッドを取得
mcp__serena__find_symbol
- name_path: "UserService"
- relative_path: "src/services/user-service.ts"
- depth: 1  # メソッド一覧も取得

# 2. 各メソッドの参照元を確認
mcp__serena__find_referencing_symbols
- name_path: "UserService/createUser"
- relative_path: "src/services/user-service.ts"

# 3. 類似パターンの検索
mcp__serena__search_for_pattern
- substring_pattern: "class.*Service.*\\{"
- relative_path: "src/services"
```

## 🧠 sequentialthinking MCP - 段階的思考ツール

sequentialthinking MCPは、複雑な問題を段階的に分解し、解決策を探索するためのツールです。

### 基本原則

1. **段階的思考**: 一度に1つの問題に集中
2. **柔軟な調整**: 途中で見積もりを変更可能
3. **分岐と修正**: 必要に応じて思考を分岐・修正

### パラメータ詳細

```
mcp__sequentialthinking__sequentialthinking
- thought: string           # 現在の思考内容
- thoughtNumber: number     # 現在の思考番号（1から開始）
- totalThoughts: number     # 予想される総思考数
- nextThoughtNeeded: boolean # 次の思考が必要か
- isRevision: boolean       # 修正の思考か（オプション）
- revisesThought: number    # 修正対象の思考番号（オプション）
- branchFromThought: number # 分岐元の思考番号（オプション）
- branchId: string          # 分岐ID（オプション）
```

### 使用パターン

#### パターン1: 線形の段階的思考

**用途**: 依存関係の分析、タスクの分解

```
思考1:
thought: "タスクAとタスクBの関係を分析します。タスクAはログイン機能、タスクBはダッシュボード表示です。"
thoughtNumber: 1
totalThoughts: 5
nextThoughtNeeded: true

思考2:
thought: "タスクAはユーザー認証を実装します。タスクBは認証後のデータ表示なので、タスクAに依存します。"
thoughtNumber: 2
totalThoughts: 5
nextThoughtNeeded: true

思考3:
thought: "しかし、タスクBはモックデータで開発可能です。認証APIの仕様が明確なら並列実行できます。"
thoughtNumber: 3
totalThoughts: 5
nextThoughtNeeded: true

思考4:
thought: "API仕様書を確認します。仕様が明確なので、並列実行可能と判断します。"
thoughtNumber: 4
totalThoughts: 5
nextThoughtNeeded: true

思考5:
thought: "結論: タスクAとタスクBは並列実行可能です。ただし、統合テストは両方完了後に実施します。"
thoughtNumber: 5
totalThoughts: 5
nextThoughtNeeded: false
```

#### パターン2: 思考の修正

**用途**: 前の判断を見直す必要がある場合

```
思考1-3: （通常の思考）

思考4（修正）:
thought: "思考2の判断を修正します。タスクBはモックではなく実APIが必要でした。段階的実行に変更します。"
thoughtNumber: 4
totalThoughts: 6  # 総数を調整
nextThoughtNeeded: true
isRevision: true
revisesThought: 2

思考5-6: （修正後の思考）
```

#### パターン3: 思考の分岐

**用途**: 複数の選択肢を検討する場合

```
思考1-3: （共通の分析）

思考4（分岐A）:
thought: "選択肢A: すべてのタスクを並列実行する場合のメリット・デメリット"
thoughtNumber: 4
totalThoughts: 8
branchFromThought: 3
branchId: "option-parallel"
nextThoughtNeeded: true

思考5（分岐A続き）:
thought: "並列実行のメリット: 高速、デメリット: 統合が複雑"
thoughtNumber: 5
totalThoughts: 8
branchId: "option-parallel"
nextThoughtNeeded: true

思考6（分岐B）:
thought: "選択肢B: 段階的実行の場合のメリット・デメリット"
thoughtNumber: 6
totalThoughts: 8
branchFromThought: 3
branchId: "option-staged"
nextThoughtNeeded: true

思考7（分岐B続き）:
thought: "段階的実行のメリット: 安全、デメリット: 時間がかかる"
thoughtNumber: 7
totalThoughts: 8
branchId: "option-staged"
nextThoughtNeeded: true

思考8（統合）:
thought: "両方の選択肢を比較した結果、段階的実行を選択します。理由: 安全性が優先事項のため"
thoughtNumber: 8
totalThoughts: 8
nextThoughtNeeded: false
```

### 実践的な使用例

#### 例1: タスク依存関係の分析

```
思考1:
thought: "4つのタスクの依存関係を分析します。タスクA: フロントエンド、タスクB: バックエンド、タスクC: テスト、タスクD: ドキュメント"
thoughtNumber: 1
totalThoughts: 6
nextThoughtNeeded: true

思考2:
thought: "タスクAとタスクBの関係: フロントエンドはバックエンドAPIを呼び出します。依存関係がありそうです。"
thoughtNumber: 2
totalThoughts: 6
nextThoughtNeeded: true

思考3:
thought: "しかし、APIの仕様が明確なら、フロントエンドはモックで開発可能です。並列実行できます。"
thoughtNumber: 3
totalThoughts: 6
nextThoughtNeeded: true

思考4:
thought: "タスクCのテストについて: E2Eテストは両方の実装が必要ですが、単体テストは独立して作成可能です。"
thoughtNumber: 4
totalThoughts: 6
nextThoughtNeeded: true

思考5:
thought: "タスクDのドキュメント: API仕様書があれば独立して作成可能です。"
thoughtNumber: 5
totalThoughts: 6
nextThoughtNeeded: true

思考6:
thought: "結論: 並列実行可能です。ただし、E2Eテストは第2段階で実施します。第1段階: A, B, D並列、第2段階: C（E2Eテスト）"
thoughtNumber: 6
totalThoughts: 6
nextThoughtNeeded: false
```

#### 例2: 複雑な技術的判断

```
思考1:
thought: "認証システムのリファクタリング方法を検討します。現在: セッションベース、目標: JWTベース"
thoughtNumber: 1
totalThoughts: 8
nextThoughtNeeded: true

思考2:
thought: "移行方法の選択肢: 一括移行 vs 段階的移行"
thoughtNumber: 2
totalThoughts: 8
nextThoughtNeeded: true

思考3（分岐A）:
thought: "一括移行の場合: すべてのエンドポイントを一度に変更。リスクが高いが、早く完了します。"
thoughtNumber: 3
totalThoughts: 8
branchFromThought: 2
branchId: "big-bang"
nextThoughtNeeded: true

思考4（分岐B）:
thought: "段階的移行の場合: セッションとJWTを並行稼働。安全ですが、複雑性が増します。"
thoughtNumber: 4
totalThoughts: 8
branchFromThought: 2
branchId: "gradual"
nextThoughtNeeded: true

思考5:
thought: "本番環境へのリスクを考慮すると、段階的移行が適切です。"
thoughtNumber: 5
totalThoughts: 8
nextThoughtNeeded: true

思考6:
thought: "段階的移行の実施計画を立てます。第1段階: JWT発行機能追加、第2段階: 新規エンドポイントでJWT使用、第3段階: 既存エンドポイント移行"
thoughtNumber: 6
totalThoughts: 8
nextThoughtNeeded: true

思考7:
thought: "各段階のタスク配分を検討します。第1段階はdev1とdev2で並列実行可能です。"
thoughtNumber: 7
totalThoughts: 8
nextThoughtNeeded: true

思考8:
thought: "結論: 段階的移行を採用し、3段階で実施します。各段階内ではタスクを並列実行します。"
thoughtNumber: 8
totalThoughts: 8
nextThoughtNeeded: false
```

### sequentialthinking使用のベストプラクティス

#### 1. 適切な粒度

```
❌ 粗すぎる思考:
thought: "すべてを分析して結論を出します"
→ 段階的思考の意味がない

✅ 適切な粒度:
thought: "まず、タスクAとタスクBの関係を分析します"
→ 1つの観点に集中
```

#### 2. 具体的な内容

```
❌ 曖昧な思考:
thought: "依存関係について考えます"
→ 何を考えているか不明確

✅ 具体的な思考:
thought: "タスクAはデータベーススキーマ変更、タスクBはその変更に依存するAPI実装なので、タスクAが先です"
→ 具体的な判断と理由
```

#### 3. 総思考数の調整

```
最初の見積もり: totalThoughts: 5

途中で複雑さに気づく:
thought: "想定より複雑なので、さらに3つの思考が必要です"
totalThoughts: 8  # 調整
```

## 🛠️ その他の補助ツール

### Bash（読み取り専用操作）

**使用可能な操作**:
```bash
# Worktree情報の確認
git worktree list

# ブランチ確認
git branch

# 状態確認
git status

# ディレクトリ確認
ls -la

# ファイル検索
find src -name "*.ts"
```

**禁止操作**:
- ❌ `git add`
- ❌ `git commit`
- ❌ `git push`
- ❌ ファイル編集コマンド（`sed`, `awk`等）
- ❌ ファイル作成・削除コマンド

### Read（情報確認のみ）

**使用例**:
```
Read tool で設定ファイル確認:
- file_path: "package.json"
- file_path: "tsconfig.json"
- file_path: ".env.example"
```

**注意**: 実際のファイル編集は絶対に行いません。

## 📊 ツール選択のガイドライン

### 状況別のツール選択

| 状況 | 使用するツール | 理由 |
|------|---------------|------|
| プロジェクト構造の把握 | serena `list_dir` | 全体像を効率的に取得 |
| ファイルの構造確認 | serena `get_symbols_overview` | シンボル一覧を高速取得 |
| 特定シンボルの検索 | serena `find_symbol` | 正確な位置を特定 |
| 影響範囲の調査 | serena `find_referencing_symbols` | 参照元を一覧化 |
| パターン検索 | serena `search_for_pattern` | 正規表現で柔軟に検索 |
| 依存関係の分析 | sequentialthinking | 段階的に論理を構築 |
| 技術的判断 | sequentialthinking | 複数の選択肢を検討 |
| Worktree確認 | Bash `git worktree list` | Git情報の取得 |
| 設定ファイル確認 | Read | ファイル内容の確認 |

### 効率的な組み合わせ

```
フェーズ1: 全体把握
├─ serena list_dir
└─ Read（設定ファイル）

フェーズ2: 詳細分析
├─ serena get_symbols_overview
└─ serena find_symbol

フェーズ3: 依存関係分析
├─ serena find_referencing_symbols
└─ sequentialthinking（論理的思考）

フェーズ4: 計画策定
└─ sequentialthinking（配分計画）
```

## 🔗 関連ファイル

- **[SKILL.md](./SKILL.md)** - 概要に戻る
- **[WORKFLOWS.md](./WORKFLOWS.md)** - ワークフロー詳細
- **[TASK-DISTRIBUTION.md](./TASK-DISTRIBUTION.md)** - タスク配分計画
- **[REFERENCE.md](./REFERENCE.md)** - 禁止事項と成果物フォーマット
