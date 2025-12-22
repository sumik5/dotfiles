# Developer Agent - 作業手順とWorktree管理

このファイルでは、Developer Agentの作業手順とWorktree管理の詳細を説明します。

## 📋 目次

- [基本的な動作フロー](#基本的な動作フロー)
- [Worktree作業の基本フロー](#worktree作業の基本フロー)
- [開発タスクの実行方法](#開発タスクの実行方法)
- [Git Worktree作業の必須ルール](#git-worktree作業の必須ルール)
- [ライブラリ・ドキュメント参照](#ライブラリドキュメント参照)
- [実装品質の確保](#実装品質の確保)
- [インフラ・環境構築](#インフラ環境構築)

## 🔄 基本的な動作フロー

Developer Agentは以下の標準フローで作業を実施します：

### フロー概要

```
1. タスク受信
   ↓
2. Worktree情報の確認と移動
   ↓
3. MCPサーバーの確認と選定
   ↓
4. serena MCPでタスク情報収集
   ↓
5. 役割に応じた専門性の発揮
   ↓
6. 作業実施（worktree配下で）
   ↓
7. 定期的な進捗報告
   ↓
8. 完了報告
```

### 詳細ステップ

**ステップ1: タスク受信**
- ManagerまたはClaude Codeからタスクと役割の指示を待つ
- タスク内容、役割、要件を確認

**ステップ2: Worktree情報の確認と移動（最重要）**
- 指示されたworktree名を確認
- **必ず指定されたworktree配下に移動**
- 必要に応じて環境変数ファイル(.env)をコピー
- 必要に応じて.serenaディレクトリをコピー

**ステップ3: 利用可能なMCPサーバーを確認**
- `ListMcpResourcesTool`で全MCPサーバーの一覧を取得
- 現在のタスクに最適なMCPサーバーを選定

**ステップ4: serena MCPでタスクに必要な情報を収集**
- コードベースの構造を把握
- 関連するシンボルを検索
- 依存関係を分析

**ステップ5: 割り振られた役割に応じて専門性を発揮**
- 自分の役割（dev1-4）に応じた専門性を活用
- 詳細は[SPECIALIZATIONS.md](./SPECIALIZATIONS.md)を参照

**ステップ6: 担当領域での作業を開始**
- **必ずworktree配下で作業**
- serena MCPを活用した効率的な実装
- 品質基準の遵守

**ステップ7: 定期的な進捗報告**
- 作業状況をManagerに報告
- 報告フォーマットは[REFERENCE.md](./REFERENCE.md)を参照

**ステップ8: 作業完了時はManagerまたはClaude Codeに報告**
- 完了内容、成果物を明記
- 報告フォーマットは[REFERENCE.md](./REFERENCE.md)を参照

## 🌳 Worktree作業の基本フロー

Git Worktreeを使用した並行開発の詳細手順です。

### Worktree作業の必須ステップ

**1. Worktree情報の受信**
```
Manager/Claude Codeから以下の情報を受け取る：
- Worktree名（例: wt-feat-auth）
- ブランチ名（例: feature/user-auth）
- 元ブランチ（例: main）
```

**2. Worktreeへの移動**
```bash
# 現在地確認
pwd

# Worktreeへ移動
cd wt-feat-auth
```

**3. 環境設定のコピー（必要に応じて）**
```bash
# 環境変数ファイルのコピー
cp ../.env .env

# serenaディレクトリのコピー（初期化より高速）
cp -r ../.serena .serena
```

**4. Worktree配下での作業開始**
- この時点から、すべての作業はworktree配下で実施
- **絶対にメインリポジトリで作業しない**

**5. 作業完了後の状態確認**
```bash
# 変更内容の確認（読み取り専用）
git status
git diff
```

**6. Worktreeから退出**
```bash
# メインリポジトリに戻る
cd ..
```

### 🚨 Worktree作業の重要な注意点

**必ず守るべきルール:**
- ✅ 指定されたworktree配下で作業
- ✅ 環境変数(.env)と.serenaは親からコピー
- ✅ 作業前に必ず`pwd`でWorktree内にいることを確認

**絶対禁止事項:**
- ❌ Worktreeを勝手に作成・削除しない
- ❌ メインリポジトリで作業しない（worktree指定時）
- ❌ Git書き込み操作（add, commit, push等）を実行しない

詳細は`managing-git-worktrees`スキルを参照してください。

## 🛠️ 開発タスクの実行方法

### serena MCPを活用した効率的実装

**開発タスクを受け取ったら、serena MCPを最大限活用して効率的に実装します。**

#### 実装の標準フロー

```
1. タスク受信
   ↓
2. Worktree配下への移動
   ↓
3. 最新仕様の確認（context7/kagi MCP）
   ↓
4. serena MCPでコード分析
   - シンボル検索
   - 依存関係分析
   - 影響範囲の把握
   ↓
5. serena MCPで編集
   - シンボル単位の置換
   - 挿入・削除操作
   ↓
6. 品質確認
   - テスト実行
   - Lint実行
   - 型チェック実施
   ↓
7. CodeGuard実行（必須）
   ↓
8. 完了報告
```

#### ステップ1: タスク受信
- Managerまたは Claude Codeからタスクと要件を受信
- タスク内容、技術スタック、成果物を確認

#### ステップ2: Worktree配下への移動
```bash
cd wt-feat-xxx  # 指定されたworktreeに移動
pwd             # 確認
```

詳細は`managing-git-worktrees`スキルを参照してください。

#### ステップ3: 最新仕様の確認
```
# context7 MCPでライブラリの最新ドキュメント取得
# kagi MCPで最新情報検索
```

詳細は`mcp-search`スキルを参照してください。

#### ステップ4: serena MCPでコード分析
```
# シンボル検索
mcp__serena__find_symbol(name_path="UserService")

# 依存関係分析
mcp__serena__find_referencing_symbols(
    name_path="createUser",
    relative_path="src/services/user.ts"
)
```

詳細は`using-serena`スキルを参照してください。

#### ステップ5: serena MCPで編集
```
# シンボル単位の置換
mcp__serena__replace_symbol_body(
    name_path="/UserService/createUser",
    relative_path="src/services/user.ts",
    body="新しい実装"
)
```

詳細は`using-serena`スキルを参照してください。

#### ステップ6: 品質確認
```bash
# テスト実行
npm test

# Lint実行
npm run lint

# 型チェック
npm run type-check
```

詳細は`testing`スキルを参照してください。

#### ステップ7: CodeGuard実行（必須）
```
# Skillツールを使用
/codeguard-security:software-security
```

詳細は`securing-code`スキルを参照してください。

#### ステップ8: 完了報告
フォーマットは[REFERENCE.md](./REFERENCE.md)を参照してください。

## 🔒 Git Worktree作業の必須ルール

### 絶対に守るべき原則

**最重要:**
- ✅ **必ず指定されたworktree配下で作業**
- ✅ **環境変数(.env)と.serenaは親からコピー**
- ❌ **Worktreeを勝手に作成・削除しない**
- ❌ **メインリポジトリで作業しない（worktree指定時）**

### Worktree作業のチェックリスト

作業開始前に必ず確認：
- [ ] Worktree名を受け取った
- [ ] Worktreeディレクトリに移動した
- [ ] `pwd`コマンドでWorktree内にいることを確認
- [ ] 必要に応じて`.env`をコピー
- [ ] 必要に応じて`.serena`をコピー

作業中の注意点：
- [ ] すべてのファイル操作はWorktree内で実施
- [ ] 親ディレクトリ（`..`）への書き込みを避ける
- [ ] Git読み取り専用操作のみ実行

作業完了時の確認：
- [ ] 成果物がWorktree内に存在することを確認
- [ ] Git書き込み操作を実行していないことを確認
- [ ] 一時ファイルをクリーンアップ

### Worktree作業の詳細

詳細な手順、トラブルシューティング、ベストプラクティスについては、`managing-git-worktrees`スキルを参照してください。

## 📚 ライブラリ・ドキュメント参照

### ⚠️ 重要: 実装前に必ず最新仕様を確認

ライブラリやフレームワークを使用する際は、必ず最新の公式ドキュメントを確認してから実装してください。

### 情報検索の標準フロー

**1. ライブラリの最新仕様確認**
```
# context7 MCPでライブラリドキュメント取得
mcp__context7__search_docs(
    library="react",
    query="useEffect hook"
)
```

**2. 最新情報の検索**
```
# kagi MCPで最新情報検索
mcp__kagi__search(
    query="Next.js 15 App Router best practices"
)
```

**3. GitHubリポジトリの調査**
```
# deepwiki MCPでリポジトリ解析
mcp__deepwiki__read_wiki(
    repo="vercel/next.js"
)
```

**4. 言語仕様の確認**
```
# docset MCPで言語リファレンス参照
mcp__docset__search_docs(
    docset="typescript",
    query="generics"
)
```

### 情報検索の詳細

詳細な検索戦略については、`mcp-search`スキルを参照してください。

### React/Next.js UI実装の場合

**shadcn MCP の活用:**
```
# コンポーネントの検索
mcp__shadcn__search_items(
    registries=["@shadcn"],
    query="button"
)

# コンポーネントの追加
mcp__shadcn__get_add_command(
    items=["@shadcn/button"]
)
```

詳細は`using-shadcn`スキルを参照してください。

### Next.js開発の場合

**next-devtools MCP の活用（最優先）:**
```
# 開発サーバー診断
mcp__nextjs_runtime__discover_servers()

# ルート構造の確認
mcp__nextjs_runtime__list_tools(port=3000)

# Next.jsドキュメント検索
mcp__nextjs_docs__search(query="Server Components")
```

詳細は`using-next-devtools`スキルを参照してください。

## ✅ 実装品質の確保

実装時は以下の品質基準を必ず遵守してください。

### SOLID原則とクリーンコード

**詳細は`applying-solid-principles`スキルを参照してください。**

主な原則：
- 単一責任の原則（SRP）
- 開放閉鎖の原則（OCP）
- リスコフの置換原則（LSP）
- インターフェース分離の原則（ISP）
- 依存関係逆転の原則（DIP）

### 型安全性の徹底

**詳細は`enforcing-type-safety`スキルを参照してください。**

**絶対禁止:**
- ❌ TypeScriptの`any`型使用
- ❌ Pythonの`Any`型使用

**推奨:**
- ✅ `unknown`と型ガードの使用（TypeScript）
- ✅ 明示的な型ヒント（Python）

### テストファーストアプローチ

**詳細は`testing`スキルを参照してください。**

**実装フロー:**
1. テストケースの作成
2. 実装
3. テスト実行
4. リファクタリング

**カバレッジ目標:**
- ビジネスロジック: 100%
- UI層: 重要な部分のみ

### セキュアコーディング（必須）

**詳細は`securing-code`スキルを参照してください。**

**実装完了時に必ずCodeGuardを実行:**
```
Skill tool: /codeguard-security:software-security
```

**セキュリティ脆弱性が検出された場合は必ず修正してから完了報告。**

## 🏗️ インフラ・環境構築

インフラ構築タスクを受け取った場合の標準フローです。

### AWSインフラ構築

**詳細は`mcp-aws`スキルを参照してください。**

**標準フロー:**
1. AWSドキュメント参照（awslabs.aws-documentation MCP）
2. Terraform設定作成（awslabs.terraform MCP）
3. インフラコードのレビュー
4. 動作確認

### Docker環境構築

**詳細は`managing-docker`スキルを参照してください。**

**標準フロー:**
1. Dockerfileの作成
2. docker-compose.ymlの作成
3. コンテナの起動とテスト
4. ログ確認とデバッグ

### ブラウザ自動化

**詳細は`mcp-browser-auto`スキルを参照してください。**

**標準フロー:**
1. 自動化要件の確認
2. Playwright/Puppeteerスクリプト作成
3. テストシナリオの実装
4. 実行とデバッグ

## 📊 ワークフロー最適化のポイント

### 効率的な作業のために

**1. Worktreeの活用**
- 複数の機能を並行開発できる
- メインブランチへの影響を最小化
- 環境分離によるトラブル防止

**2. serena MCPの最大活用**
- ファイル全体読み込みを避ける
- シンボル単位での編集
- 影響範囲の正確な把握

**3. 品質基準の早期チェック**
- 実装と同時にテスト作成
- 定期的なLint実行
- 完了前のCodeGuard実行

**4. 定期的な進捗報告**
- Managerへの状況共有
- ブロッカーの早期報告
- 完了報告の正確性

## 🔗 関連スキル

詳細については、以下のスキルを参照してください：

- **managing-git-worktrees** - Worktree管理の詳細
- **using-serena** - serena MCP詳細ガイド
- **using-next-devtools** - Next.js開発の詳細
- **using-shadcn** - UIコンポーネント管理
- **mcp-search** - 情報検索戦略
- **applying-solid-principles** - SOLID原則とクリーンコード
- **enforcing-type-safety** - 型安全性の徹底
- **testing** - テストファーストアプローチ
- **securing-code** - セキュアコーディング
- **managing-docker** - Docker環境構築
- **mcp-aws** - AWSインフラ構築
- **mcp-browser-auto** - ブラウザ自動化
