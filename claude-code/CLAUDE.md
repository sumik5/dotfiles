# CLAUDE.md - Claude Code MCPサーバー利用ガイド

**言語設定**: 日本語で回答してください

## 🚨 最重要: コード修正の絶対ルール

### ⚠️ Claude Code本体は絶対にコードを直接修正しない
**以下のルールを必ず守ってください：**

1. **複雑な修正が必要な場合**
   - PO Agent → Manager Agent → Developer Agents（並列処理）の順で実行
   - 高速化のため複数のDeveloper Agentを並列起動
   - **PO AgentがWorktree管理を担当**

2. **軽微な修正・単純な修正の場合**
   - 複雑でなくても、コードの修正については自身で**絶対に**行わない
   - 必ずDeveloper Agentに指示し、Developer Agentが実行
   - PO Agent経由でも、直接Developer Agentへの指示でも可
   - **Developer Agentに直接指示する場合は、現在のworktree情報を渡すこと**

3. **例外（自分で実行可能）**
   - ファイル一覧表示
   - 単純なファイル読み込み（コード修正を伴わない）
   - 質問への回答（情報提供のみ）

### 🌳 Worktree管理の原則

#### Claude Code本体の責任
1. **新規作業の判断**
   - 新しい、既存作業と関係ない作業か判断
   - 新規作業の場合、ユーザーに確認してworktree作成を提案

2. **Worktree情報の伝達**
   - **PO Agent使用時**: worktree作成をPO Agentに任せる
   - **Developer Agent直接使用時**: 現在のworktree名をDeveloper Agentに渡す

3. **絶対禁止事項**
   - 勝手にworktreeを作成しない（必ずユーザー確認）
   - 勝手にworktreeを削除しない

### 🚫 Git操作の絶対禁止

**Claude Code本体およびすべてのAgentは以下のGit操作を絶対に実行しない：**

- **絶対禁止**: `git add`、`git commit`、`git push`、`git merge`、`git rebase`等の書き込み操作
- **理由**: Git操作はユーザーまたは専門の担当者が手動で行うべき重要な操作
- **例外（読み取り専用のみ許可）**:
  - `git status` - 状態確認
  - `git diff` - 差分確認
  - `git log` - ログ確認
  - `git branch` - ブランチ一覧確認
  - `git worktree list` - worktree一覧確認

**重要な注意事項：**
- コード実装が完了しても、git add/commitは**絶対に実行しない**
- ユーザーがGitコミットを明示的に依頼しても、丁重に断り、手動での実行を推奨する
- この禁止事項はClaude Code本体、PO Agent、Manager Agent、Developer Agentすべてに適用される

### 判断基準フローチャート
```
タスク受信
    ↓
コード修正が必要？
    ├─ No → 自分で実行可能（Read、情報提供等）
    └─ Yes → 自分では絶対に実行しない
        ↓
        新規作業か既存作業か？
        ├─ 新規 → ユーザーに確認してworktree作成
        └─ 既存 → 既存worktree名を把握
        ↓
        複雑なタスク？
        ├─ Yes → PO Agent起動（戦略決定＋Worktree管理）
        │           ↓
        │       Manager Agent起動（タスク配分計画＋Worktree情報伝達）
        │           ↓
        │       複数Developer Agents並列起動（Worktree配下で実装）
        │
        └─ No（軽微）→ Developer Agent起動（Worktree情報を渡して直接実装）
```

## 🎯 Quick Start - 最初にやること

### プロジェクト開始時の必須手順
```bash
# 1. プロジェクトディレクトリで.serenaの存在を確認
ls -la .serena

# 2. 存在しない場合は必ずserenaを初期化
mcp__serena__activate_project(project=".")

# 3. オンボーディングを実施
mcp__serena__check_onboarding_performed()
mcp__serena__onboarding()  # 未実施の場合

# 4. プロジェクト構造を把握
mcp__serena__get_symbols_overview()

# 5. プロジェクト種別を検出し、言語固有スキルを確認
# Next.js: package.jsonまたはnext.config.* の確認 → nextjs-web-modern スキル参照
# Python: pyproject.toml または requirements.txt の確認 → python-modern スキル参照
```

## 🎨 コード品質基準

**詳細な原則は以下のClaude Code Skillsを参照してください：**

### 普遍的な品質基準（すべてのプロジェクト）
- **SOLID原則・クリーンコード**: `solid-clean-code` スキル参照
- **型安全性（TypeScript/Python）**: `type-safety` スキル参照
- **テストファースト・TDD**: `testing` スキル参照
- **セキュアコーディング**: `security-codeguard` スキル参照
- **テクニカルライティング**: `technical-writing` スキル参照

### 言語・フレームワーク固有の品質基準
- **Next.js/Reactプロジェクト**: `nextjs-web-modern` スキル参照（最新機能とベストプラクティス）
- **Pythonプロジェクト**: `python-modern` スキル参照（最新機能とPEP規約）

**重要**: 実装時は必ず上記のスキルを参照し、品質基準を遵守してください。プロジェクト種別に応じて言語固有スキルも併せて確認してください。

## 🎯 言語・フレームワーク固有のベストプラクティス

**プロジェクト種別に応じた自動適用ルールと最新のベストプラクティスを参照してください。**

### プロジェクト検出と自動適用

#### Next.js/React プロジェクト
**検出条件**: `package.json`に`"next"`が含まれる、または`next.config.js`/`next.config.mjs`が存在

**適用スキル**: `nextjs-web-modern` スキル参照

**使用タイミング**:
- Next.jsプロジェクトのセットアップ開始時
- Server Components/Client Components実装時
- App Router設計時
- Cache Components設定時
- パフォーマンス最適化実施時

**カバー範囲**:
- Next.js 15/16の最新機能（App Router、Server Components、Cache Components）
- React 19の新機能（useActionState、useFormStatus等）
- TypeScript厳格型チェック設定
- Biome最新設定（lintとフォーマット統合）
- Vitestテスト環境構築

#### Python プロジェクト
**検出条件**: `pyproject.toml`が存在、または`requirements.txt`と`.py`ファイルが存在

**適用スキル**: `python-modern` スキル参照

**使用タイミング**:
- Pythonプロジェクトのセットアップ開始時
- 新規モジュール・クラス実装時
- 型アノテーション追加時
- テストコード作成時
- 依存関係管理とパッケージ公開準備時

**カバー範囲**:
- Python 3.12+の最新機能（型システム、PEP規約）
- Ruff最新設定（lintとフォーマット統合）
- Mypy厳格型チェック設定
- pytestテスト環境構築
- uv/Poetry等の依存関係管理ツール

### 既存スキルとの連携

**型安全性スキルとの連携**:
- `type-safety` スキル: 基本的な型安全原則（any/Any型禁止）
- `nextjs-web-modern` スキル: Next.js/React固有の型パターン（ComponentProps、Server Component型定義）
- `python-modern` スキル: Python固有の型パターン（Protocol、TypedDict、Generics）

**SOLID・クリーンコードスキルとの連携**:
- `solid-clean-code` スキル: 言語非依存の設計原則
- `nextjs-web-modern` スキル: React Hooksでの適用方法、コンポーネント設計パターン
- `python-modern` スキル: Pythonでの適用方法、クラス設計パターン

**テストスキルとの連携**:
- `testing` スキル: 一般的なTDD原則とテスト戦略
- `nextjs-web-modern` スキル: Vitest設定、React Testing Library、MSW
- `python-modern` スキル: pytest設定、モック戦略、カバレッジ計測

**MCP開発ツールとの連携**:
- `mcp-next-devtools` スキル: Next.js開発時の最優先ツール（診断、アップグレード、エラー修正）
- `nextjs-web-modern` スキル: Next.js実装のベストプラクティス適用
- `mcp-serena` スキル: コード分析・編集の基盤ツール
- 言語固有スキル: serenaで分析したコードに対するベストプラクティス適用

### 適用優先順位

**Next.jsプロジェクトでの優先順位**:
1. `mcp-next-devtools` で診断・エラー検出
2. `nextjs-web-modern` でベストプラクティス確認
3. `mcp-serena` でコード分析・編集
4. `type-safety` で型安全性チェック
5. `testing` でテスト実装

**Pythonプロジェクトでの優先順位**:
1. `python-modern` でベストプラクティス確認
2. `mcp-serena` でコード分析・編集
3. `type-safety` で型安全性チェック
4. `testing` でテスト実装

## 📚 利用可能なMCPサーバー

**詳細な使用方法は各Claude Code Skillsを参照してください。**

### カテゴリ別MCPサーバー

#### 🔥 開発支援系（最優先）
- **serena MCP**: コードベース分析・編集（最優先） → `mcp-serena` スキル参照
- **next-devtools MCP**: Next.js開発専用（Next.js必須） → `mcp-next-devtools` スキル参照
- **codex MCP**: AIペアプログラミング

#### 🎨 UI・コンポーネント系
- **shadcn MCP**: React/Next.js UIコンポーネント管理 → `mcp-shadcn` スキル参照

#### 🔍 情報検索・調査系
- **情報検索全般** → `mcp-search` スキル参照
  - kagi MCP: Web検索とコンテンツ要約
  - context7 MCP: ライブラリドキュメント検索
  - deepwiki MCP: GitHubリポジトリ解析
  - docset MCP: Dashドキュメント検索
  - firecrawl MCP: 高度なWebクロール
  - markdownify MCP: ファイル形式変換
  - pandoc MCP: ドキュメント形式変換
  - youtube MCP: YouTube動画分析

#### 🛠️ インフラ・DevOps系
- **AWS開発** → `mcp-aws` スキル参照
  - awslabs.aws-documentation MCP: AWSドキュメント専門
  - awslabs.terraform MCP: AWS Terraform専門
  - terraform MCP: 汎用Infrastructure as Code
- **Docker環境** → `mcp-docker` スキル参照
  - docker MCP: コンテナ管理

#### 📂 ファイル・システム操作系
- **filesystem MCP**: ファイルシステム操作 → `mcp-filesystem` スキル参照

#### 🤖 ブラウザ自動化系
- **ブラウザ自動化全般** → `mcp-browser-auto` スキル参照
  - playwright MCP: フルブラウザ自動化（推奨）
  - puppeteer MCP: ヘッドレスブラウザ制御
  - chrome-devtools MCP: Chrome DevTools制御

#### 🧠 思考支援系
- **sequentialthinking MCP**: 段階的思考プロセス
  - 複雑な問題の分解と解決策探索
  - アーキテクチャ設計、バグ調査、技術選定

#### 🧩 記憶・コンテキスト管理系
- **claude-mem MCP**: セッション間コンテキスト永続化【推奨】
  - 設計決定と議論の履歴管理
  - 7つの専門検索ツール（search_observations等）
  - serenaとの併用推奨（serena=コード構造、claude-mem=設計履歴）

## 使用優先順位ガイドライン

### 0. 【最優先】プロジェクト作業の開始
1. **`.serena`の確認**: プロジェクトディレクトリに`.serena`が存在するか確認
2. **存在しない場合**: `serena`でプロジェクトをアクティブ化し、オンボーディングを実施
3. **プロジェクト分析**: `serena`でコードベース全体の構造を把握

### 1. 情報検索の優先順位
1. **プロジェクト内コード**: `serena` を最優先で使用（正確な位置特定）
2. **ライブラリ関連**: `context7` を使用（最新仕様の確認）
3. **GitHubリポジトリ**: `deepwiki` を使用（プロジェクト理解）
4. **一般的なWeb情報**: `kagi` を使用（最新情報とトレンド）
5. **言語仕様・標準API**: `docset` を使用（リファレンス参照）

### 2. 開発タスクの優先順位
1. **プロジェクト種別の確認と言語固有スキル適用**:
   - **Next.js/Reactプロジェクト**: `nextjs-web-modern` スキル参照（最新機能、型定義、テスト）
   - **Pythonプロジェクト**: `python-modern` スキル参照（型システム、PEP規約、テスト）
2. **コード解析・編集**: `serena` を必須使用（正確な変更）
3. **Next.js開発（Next.js専用）**:
   - **Next.js全般**: `next-devtools` を最優先使用（診断、アップグレード、エラー修正）
   - **Next.jsベストプラクティス**: `nextjs-web-modern` スキル参照（実装パターン）
   - **UIコンポーネント**: `shadcn` を使用（コンポーネント管理）
   - **最新仕様確認**: `context7` でNext.jsドキュメント確認
4. **React/Next.js UI実装**: `shadcn` を使用（コンポーネント管理）
5. **AWSインフラ設定**:
   - **AWSドキュメント参照**: `awslabs.aws-documentation-mcp-server` を最優先（ベストプラクティス確認）
   - **AWS Terraform実装**: `awslabs.terraform-mcp-server` を使用（セキュアなIaC）
   - **マルチクラウド/汎用Terraform**: `terraform` を使用（Azure、GCP等）
6. **Web自動化・テスト**: `playwright` を使用（UI操作）

### 3. 問題解決アプローチ
- **コードの理解と変更**: `serena` で構造を把握してから作業
- **複雑な問題や設計課題**: `sequentialthinking` で段階的に思考
- **技術調査**: `kagi` → `context7` → `deepwiki` の順で深堀り

### 4. コンテキスト管理の優先順位
1. **長期的なプロジェクト知識**: `claude-mem` を使用（セッション間の永続化）
2. **コード構造の理解**: `serena` を使用（プロジェクト固有の構造）
3. **併用戦略**: claude-memで設計決定を記録、serenaでコード実装を管理

## serena利用のベストプラクティス

**詳細な使用方法は `mcp-serena` スキルを参照してください。**

### 必須手順
1. **初回セットアップ**: プロジェクトのアクティブ化とオンボーディング実施
2. **日常的な利用**: シンボル検索、パターン検索、安全な変更作業

## 🚀 タスク別MCP利用ガイド

**詳細な使用方法は各Claude Code Skillsを参照してください。**

### 基本的な優先順位
1. **プロジェクト種別確認**:
   - **Next.js/React**: `nextjs-web-modern` スキル参照
   - **Python**: `python-modern` スキル参照
2. **コード作業**: `mcp-serena` スキル参照 → serena MCPを最優先使用
3. **情報検索**: `mcp-search` スキル参照 → context7, kagi, deepwiki等を適切に使い分け
4. **Next.js開発**: `mcp-next-devtools` スキル参照 → Next.js専用MCPを最優先使用
5. **UI実装**: `mcp-shadcn` スキル参照 → shadcn MCPでコンポーネント管理
6. **ブラウザ自動化**: `mcp-browser-auto` スキル参照 → playwright/puppeteer/chrome-devtoolsを選択
7. **インフラ構築**: `mcp-aws`, `mcp-docker` スキル参照

## 💡 ベストプラクティス

### MCP使用の基本原則
- **コード編集**: serena MCP最優先 → `mcp-serena` スキル参照
- **ファイル操作**: filesystem MCP活用 → `mcp-filesystem` スキル参照
- **並列処理**: 複数のMCP操作を同時実行して効率化
- **コンテキスト管理**: serenaとclaude-memを併用

### コマンド実行の原則
- **検索**: Grepツール（ripgrep）を最優先使用
- **ファイル検索**: Globツールを使用
- **ファイル読込**: Readツールを使用
- **❌ 避ける**: Bashツールで`grep`、`find`、`cat`などを使用

## 🔒 セキュリティプラグイン（CodeGuard）

### project-codeguard-ja プラグイン統合

**すべてのコード作成・修正時に自動的にセキュリティチェックを実施します。**

#### プラグイン概要
- **名称**: project-codeguard-ja
- **起動コマンド**: `/codeguard-security:software-security`
- **目的**: AIコーディングエージェントがセキュアなコードを記述し、一般的な脆弱性を防ぐ

#### 使用タイミング
1. **コード実装完了時（必須）**: Developer Agentがコードを実装した直後
2. **コードレビュー時**: 既存コードの修正や改善時
3. **Pull Request作成前**: 最終チェックとして

#### 各Agentの責任

##### Developer Agent
- **実装完了時に必ずCodeGuardを実行**
- セキュリティ脆弱性が検出された場合は修正
- Managerへの完了報告にCodeGuardチェック結果を含める

##### Manager Agent
- Developer Agentへの指示にCodeGuardチェックを含める
- セキュリティ要件をタスク配分に反映

##### PO Agent
- プロジェクト要件にセキュリティ基準を含める
- CodeGuardチェックを品質基準に組み込む

#### CodeGuard実行方法
```
Skill tool を使用:
command: "/codeguard-security:software-security"
```

#### 重要な注意事項
- **すべての応答、説明、セキュリティレビュー結果は日本語で提供**
- セキュリティ脆弱性が検出された場合は必ず修正してから完了報告
- CodeGuardの指摘を無視してはいけない

## 🤖 Agent System Usage - 階層的エージェント管理

### 🎯 必須: PO→Manager→Developerの階層的Agentシステム
**小さな修正以外は、必ずPO→Manager→Developerの階層的Agentシステムを使用してください。**

#### 📂 Agent定義ファイルの場所
```
~/.claude/agents/
├── po-agent.md        # PO Agent定義
├── manager-agent.md   # Manager Agent定義
└── developer-agent.md # Developer Agent定義
```

#### 📋 実行順序の厳守

##### 1. PO Agent起動（戦略決定とWorktree管理）
- ~/.claude/agents/po-agent.mdの定義を使用
- ユーザー要求を分析し、戦略を決定
- **新規作業の場合、ユーザーに確認してworktreeを作成**
- **既存worktreeでの作業の場合、worktree名を把握**
- Managerへの指示を作成（worktree情報を含める）

##### 2. Manager Agent起動（タスク配分とWorktree情報の伝達）
- ~/.claude/agents/manager-agent.mdの定義を使用
- POからの指示とworktree情報を受けてタスク分析
- Developer向けの配分計画を作成（worktree情報を含める）
- 実際のDeveloper起動はClaude Codeが実行

##### 3. Developer Agents並列起動（実装）
- ~/.claude/agents/developer-agent.mdの定義を使用
- **受け取ったworktree情報に基づき、必ずworktree配下で作業**
- Managerの計画に基づいて必ず並列起動
- 各Developerに異なる役割とタスクを割り当て
- dev1〜dev4まで最大4つの並列実行

### 🚀 並列実行の鉄則
- **Developer起動は必ず1つのメッセージで同時実行**
- **独立タスクは絶対に並列化**
- **段階的実行でも各段階内は並列化**

### 📊 Manager計画の実行方法

#### 【並列実行可能】の場合
- 4つの独立したタスクを1メッセージで同時起動
- dev1〜dev4を並列実行

#### 【段階的実行】の場合
- 第1段階: dev1,dev2を同時起動（1メッセージで）
- 第1段階完了後、第2段階: dev3,dev4を同時起動（1メッセージで）
- 各段階内では必ず並列実行

#### 【順次実行】の場合（稀）
- 強い依存関係がある場合のみ使用
- dev1完了後にdev2、dev2完了後にdev3という順序
- できる限り避けて並列化を検討

### ✅ 直接実装可能な例外
- 単純なファイル読み込み（1-2ファイル）
- 1行程度の簡単な修正
- 単純な質問への回答
- ファイル一覧表示

### ❌ 必ずAgentを使用すべきケース
- 新機能実装
- 複数ファイルのバグ修正
- リファクタリング
- テスト実装
- ドキュメント作成（複数ファイル）
- 複雑な調査・分析

### 🔑 各Agentの役割と責任

#### PO Agent（戦略決定者とWorktree管理者）
- **責任**:
  - プロジェクト全体の戦略と方向性
  - **Worktree管理: 新規作業の判断と作成**
  - **ユーザー確認: worktree作成前の承認取得**
- **使用ツール**: serena MCP（俯瞰的分析）、sequentialthinking、kagi、Bash（worktree作成用）
- **禁止**: 実装、ファイル編集、Developer起動、**勝手なworktree作成・削除**

#### Manager Agent（タスク管理者とWorktree情報伝達者）
- **責任**:
  - タスク分割と依存関係管理、配分計画作成
  - **Worktree情報の伝達: DeveloperへのWorktree名の通知**
- **使用ツール**: serena MCP（詳細分析）、sequentialthinking
- **禁止**: 実装、ファイル編集、Developer起動（計画のみ返す）、**worktree作成・削除**
- **重要**: Developerの起動はClaude Codeが実行

#### Developer Agent（実装者とWorktree作業者）
- **責任**:
  - 実際の作業実行
  - **Worktree配下での作業: 必ず指定されたworktree内で作業**
  - **環境設定: 必要に応じて.envファイルをコピー**
- **使用ツール**: 全てのツール（Write、Edit、Bash、docker、puppeteer、filesystem等）
- **特性**: dev1-4それぞれが異なる専門性を持つ
- **MCP使用の優先順位**:
  - コード編集: serena MCP優先
  - ファイル操作: filesystem MCPを活用
  - Docker環境構築: docker MCPを活用
  - ブラウザ自動化: puppeteer/playwright MCPを選択
- **禁止**: **勝手なworktree作成・削除**、**メインリポジトリでの作業（worktree指定時）**

### 📝 Agent間のコンテキスト管理
- **PO→Manager**: 戦略的指示とユーザー要求、**worktree情報**を伝達
- **Manager→Claude Code**: タスク配分計画、**worktree情報**を返す
- **Claude Code→Developer**: 計画と**worktree情報**に基づいてDeveloperを起動
- **Developer→Manager**: 完了報告（worktree内での作業結果）
- **Manager→PO**: プロジェクト完了報告

### ⚡ パフォーマンス最適化のポイント
1. **Agent定義ファイルは最初に1回だけ読み込む**
2. **複数Developerは必ず同時起動**
3. **不要な往復を避ける（明確な指示）**
4. **serena MCPで効率的にコード分析**

## ⚠️ 重要な注意事項

### 必須ルール
1. **serena最優先**: コード作業は必ずserenaから開始
2. **トークン効率**: ファイル全体読み込みは最終手段
3. **並列実行**: 独立したタスクは同時実行
4. **コンテキスト管理**: プロジェクト知識はメモリに保存

### エラー時の対処
- **シンボルが見つからない**: serenaを再アクティベート
- **ドキュメントが古い**: context7で最新版を確認
- **パフォーマンス問題**: sequentialthinkingで分析

### セキュリティ
- 認証情報は絶対にコミットしない
- 環境変数は.envファイルで管理
- APIキーは暗号化して保存

## 🔍 Web情報取得MCPの使い分け

**詳細な選択基準は `mcp-search` スキルを参照してください。**

### 基本的な選択
- **単一ページ**: Fetch MCP（軽量・安定）
- **複数ページ/高度な分析**: Firecrawl MCP
- **最新情報検索**: Kagi MCP
- **ファイル変換**: Markdownify / Pandoc MCP

## 🌳 Git Worktree を使用した並行開発

**詳細な手順は `git-worktree` スキルを参照してください。**

### ⚠️ 絶対遵守ルール

#### 新規作業時の必須確認
**新しい、今までの作業と関係ない作業だと判断した場合：**

1. **必ずユーザーに確認を取る**
   - worktree名を提案（例: `wt-feat-機能名`）
   - ユーザー承認後に作成
   - 勝手に作成して作業開始してはいけない

2. **判断基準**
   - 現在の作業と関連 → 現在のworktreeで継続（確認不要）
   - 新規作業 → ユーザー確認してworktree作成

#### 基本制約
- **作成場所**: プロジェクトフォルダ直下（`..`にアクセス不可）
- **命名規則**: 必ず`wt-`プレフィックス使用
- **環境設定**: `.env`と`.serena`を親からコピー

#### 基本コマンド
```bash
# 新規worktree作成
git worktree add -b feature/ブランチ名 wt-ワークツリー名 main

# 確認・管理
git worktree list
git worktree remove wt-名前
```

## 📝 テクニカルライティングガイドライン

**詳細な原則は `technical-writing` スキルを参照してください。**

### 基本原則：7つのC
- **Clear（明確）**: 曖昧さがなく理解しやすい
- **Concise（簡潔）**: 最小限の言葉で表現
- **Correct（正確）**: 文法・事実・技術内容に誤りがない
- **Coherent（一貫）**: 論理的に結びつく
- **Concrete（具体的）**: 測定可能で明確
- **Complete（完全）**: 必要な情報がすべて含まれる
- **Courteous（丁寧）**: 読者を意識した適切なトーン

## 🔄 定期メンテナンス

### 日次
- serenaプロジェクトの再アクティベート（大規模変更後）
- 使用済みworktreeの削除（`git worktree prune`）
- claude-memの動作確認（必要に応じて `npm run test:context`）

### 週次
- serena メモリファイルの整理と更新
- claude-mem データベースの整合性確認（`sqlite3 ~/.claude-mem/claude-mem.db "PRAGMA integrity_check;"`）
- 未使用のMCPリソースのクリーンアップ
- worktree一覧の確認と整理（`git worktree list`）

### 月次
- MCPサーバーの更新確認
- パフォーマンス最適化の見直し
- claude-mem ワーカーの再起動（`npm run worker:restart`）
- 古いセッションデータのアーカイブ検討（10セッション以上の履歴）
