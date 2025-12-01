# CLAUDE.md - Claude Code 設定

## 🌐 言語設定（絶対遵守）

**CRITICAL: すべての応答は必ず日本語で行う**
- Claude Code本体、全Agent（PO/Manager/Developer）の応答
- タスク報告、エラーメッセージ、コード内コメント
- 例外: 技術用語、ライブラリ名、プログラミングキーワード

---

## 🚨 絶対ルール

### コード修正
- **Claude Code本体は絶対にコードを直接修正しない**
- コード修正は必ずAgent使用（PO→Manager→Developer）
- 例外: ファイル読み込み、質問回答のみ

### Git操作禁止
- **絶対禁止**: `git add`, `commit`, `push`, `merge`, `rebase`
- 許可: `git status`, `diff`, `log`, `branch`, `worktree list`

### Worktree管理
- **新規作業時**: 必ずユーザー確認してworktree作成提案
- **勝手な作成・削除禁止**
- 詳細: `git-worktree` スキル参照

---

## 🎯 Quick Start

### プロジェクト開始手順
1. `.serena`確認 → なければ`serena`初期化
2. オンボーディング実施
3. プロジェクト構造把握
4. プロジェクト種別検出（Next.js/Python）→ 言語固有スキル適用

**注**: serena MCPは自動的にオンデマンドで起動されます

---

## 🎨 品質基準

### 普遍的基準
`solid-clean-code`, `type-safety`, `testing`, `security-codeguard`, `technical-writing` スキル参照

### 言語固有基準
- **Next.js/React**: `nextjs-web-modern` スキル参照
- **Python**: `python-modern` スキル参照
- **Docker**: `dockerfile-best-practices` スキル参照

### フロントエンドUI基準
- **UI構築時**: `frontend-design` スキル参照
  - Webコンポーネント、ページ、アプリケーション構築時
  - Figmaデザインからの実装時
  - 汎用AI美学（AIスロップ）を避け、独創的なデザインを実現

**検出条件**:
- Next.js: `package.json`に`"next"`または`next.config.*`存在
- Python: `pyproject.toml`または`requirements.txt`存在
- Docker: `Dockerfile`または`docker-compose.yml`存在
- Frontend UI: Figma URL提供時、UI/コンポーネント構築指示時

---

## 📚 MCP使用ガイド

### modular-mcp の仕組み
**すべてのMCPはmodular-mcpによってオンデマンドで起動されます**
- コンテキスト量を大幅削減（常時起動なし）
- 必要な時に自動的に適切なMCPを選択・起動
- 設定: `~/.config/claude-code/modular-mcp.json`

### 最優先MCP（必須）
- **serena**: コード分析・編集（プロジェクト作業前に必ず初期化）
  - プロジェクト初期化、シンボル検索、効率的なコード変更
  - トリガー: 'edit code', 'refactor', 'find class/function', 'code analysis'
- **next-devtools**: Next.js専用（診断・アップグレード）
  - Next.js 16+のruntime診断、自動アップグレード、Cache Components最適化
  - トリガー: 'Next.js', 'upgrade Next.js', 'Cache Components', 'Server Components'

### カテゴリ別MCP
- 🔥 **開発**:
  - **serena**: コード分析・編集（シンボル検索、効率的なコード変更、プロジェクト構造分析）
  - **next-devtools**: Next.js専用開発ツール（診断、アップグレード、Cache Components最適化）
  - **shadcn**: shadcn/ui UIコンポーネント管理（検索、追加、使用例）
- 🔍 **検索**:
  - **context7**: ライブラリドキュメント取得（最新公式ドキュメント、API参照）
  - **deepwiki**: GitHubリポジトリ分析（オープンソースプロジェクト理解）
- 🛠️ **インフラ**:
  - **terraform**: Terraform IaCドキュメント（モジュール、プロバイダー、ポリシー）
  - **docker**: Docker/Composeコンテナ管理（作成、デプロイ、ログ取得）
- 🤖 **ブラウザ**:
  - **playwright**: 高度なE2Eテスト（クロスブラウザ、フォーム自動化）
  - **puppeteer**: 軽量ブラウザ自動化（スクリーンショット、PDF生成）
  - **chrome-devtools**: パフォーマンス分析（Core Web Vitals、ネットワーク分析）
- 📂 **変換**:
  - **mcp-pandoc**: ドキュメント形式変換（Markdown ↔ Word/PDF/LaTeX）
- 🧠 **思考**:
  - **sequentialthinking**: 複雑な問題解決（段階的思考、仮説検証）

### 優先順位
1. **プロジェクト作業開始**: `.serena`確認 → serena初期化・オンボーディング
2. **情報検索**: serena (コード) > context7 (ライブラリ) > deepwiki (GitHub)
3. **開発タスク**:
   - プロジェクト種別確認（Next.js/Python）→ 言語固有スキル適用
   - コード作業: serena必須
   - Next.js: next-devtools最優先
4. **ブラウザ自動化**: playwright (複雑) > puppeteer (軽量) > chrome-devtools (分析)

---

## 🤖 Agent使用ルール

### モデル選択（必須）
- **Claude Code本体**: Opus（デフォルト）
- **PO Agent**: Opus（戦略決定に高性能モデル）
- **Manager Agent**: Opus（タスク分析に高性能モデル）
- **Developer Agent**: Sonnet（実装に効率的モデル）

Task tool起動時に必ず`model`パラメータを指定：
```
Task(subagent_type="po-agent", model="opus", ...)
Task(subagent_type="manager-agent", model="opus", ...)
Task(subagent_type="developer-agent", model="sonnet", ...)
```

### 必須使用ケース
コード修正は必ずAgent使用:
- 複雑なタスク: PO → Manager → Developer（並列）
- 軽微な修正: Developer直接起動（worktree情報渡す）

### 例外（自分で実行可能）
ファイル読み込み（1-2ファイル）、質問回答、ファイル一覧表示

### Agent階層
- **PO** (Opus): 戦略決定、Worktree管理、ユーザー確認
- **Manager** (Opus): タスク配分、Worktree情報伝達
- **Developer** (Sonnet): 実装（worktree配下で作業）

詳細: `agent-hierarchy`, `agent-po`, `agent-manager`, `agent-developer` スキル参照

### 並列実行鉄則
- Developer起動は1メッセージで同時実行
- 独立タスクは絶対に並列化
- Agent定義ファイルは最初に1回だけ読み込む

---

## 🔒 セキュリティ

### CodeGuard（必須）
- コード実装完了時に必ず実行: `/codeguard-security:software-security`
- Developer Agentが実装後に自動実行
- 詳細: `security-codeguard` スキル参照

---

## 💡 ベストプラクティス

- **検索**: Grepツール（ripgrep）最優先
- **ファイル検索**: Globツール
- **ファイル読込**: Readツール
- **❌ 避ける**: Bashで`grep`, `find`, `cat`

---

## 🎯 トークン管理

### 監視（必須）
- **95%以上**: 即座にコンパクション実行
- **90%以上**: 次タスク前にコンパクション推奨
- **85%以上**: コンパクション検討

### コンパクション手順（自動化）
1. ユーザー通知（使用率XX%）
2. コンパクション実行
3. `/reload`実行（必須）
4. 確認メッセージ

### トークン節約
- serena MCP最大活用（ファイル全体読み込み避ける）
- Task tool活用（大規模調査は専用エージェント委任）

---

## 🔄 メンテナンス

### 日次
serena再アクティベート、worktree削除（`git worktree prune`）

### 週次
serenaメモリ整理、claude-memデータベース整合性確認、worktree一覧確認

### 月次
MCPサーバー更新確認、claude-memワーカー再起動
