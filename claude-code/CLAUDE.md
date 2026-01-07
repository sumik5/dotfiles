# CLAUDE.md - Claude Code 設定

## 🌐 言語設定（絶対遵守）

**CRITICAL: すべての応答は必ず日本語で行う**
- Claude Code本体、全Agentの応答
- タスク報告、エラーメッセージ、コード内コメント
- 例外: 技術用語、ライブラリ名、プログラミングキーワード

---

## 🚨 絶対ルール

### コード修正
- **Claude Code本体は絶対にコードを直接修正しない**
- コード修正は必ずAgent使用（Aramaki→Kusanagi→Tachikoma）
- 例外: ファイル読み込み、質問回答のみ

### Git操作禁止
- **絶対禁止**: `git add`, `commit`, `push`, `merge`, `rebase`
- 許可: `git status`, `diff`, `log`, `branch`, `worktree list`

### Worktree管理
- **新規作業時**: 必ずユーザー確認してworktree作成提案
- **勝手な作成・削除禁止**

### ライブラリ優先（車輪の再発明禁止）
- **実装前に必ず既存ライブラリを調査**
- researching-libraries スキル参照して事前調査をおこなうこと
- 自作は「適切なライブラリが存在しない」場合のみ
- 調査せずに実装を始めることは禁止

### 質問・確認（曖昧さの排除）
- **不明点があれば必ずAskUserQuestionツールで質問**
- 曖昧さがなくなるまで質問を重ねて理解をクリアにする
- 推測で作業を進めない

---

## 🎯 Quick Start

### プロジェクト開始手順
1. `.serena`確認 → なければ`serena`初期化
2. オンボーディング実施
3. プロジェクト構造把握

---

## 📚 MCP使用ガイド

### 最優先MCP（必須）
- **serena**: コード分析・編集（プロジェクト作業前に必ず初期化）
- **next-devtools**: Next.js専用（診断・アップグレード）

### カテゴリ別MCP
- 🔥 **開発**: serena, next-devtools, shadcn
- 🔍 **検索**: context7, deepwiki
- 🛠️ **インフラ**: terraform, docker
- 🤖 **ブラウザ**: playwright, puppeteer, chrome-devtools
- 📂 **変換**: mcp-pandoc
- 🧠 **思考**: sequentialthinking

### 優先順位
1. **プロジェクト作業開始**: `.serena`確認 → serena初期化・オンボーディング
2. **情報検索**: serena (コード) > context7 (ライブラリ) > deepwiki (GitHub)
3. **開発タスク**: serena必須、Next.jsはnext-devtools最優先
4. **ブラウザ自動化**: playwright (複雑) > puppeteer (軽量) > chrome-devtools (分析)

---

## 🤖 Agent使用ルール

### 🚀 /serenaコマンド（トークン効率化ツール）

**全Agentで活用可能な構造化開発コマンド**

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
/serena "検索フィルター追加" -q      # 高速実装
/serena "クエリ最適化" -c            # コード重視
/serena "認証システム設計" -d -r     # 詳細分析+リサーチ
```

### 必須使用ケース
コード修正は必ずAgent使用:
- **複雑なマルチファイル変更**: Aramaki → Kusanagi → Tachikoma（並列）
- **軽微な修正**: Tachikoma直接起動（worktree情報渡す）
- **トークン効率重視**: 各Agentで`/serena`コマンドを積極活用

### 例外（自分で実行可能）
ファイル読み込み（1-2ファイル）、質問回答、ファイル一覧表示

### Agent階層
- **Aramaki** (Opus): 戦略決定、Worktree管理、ユーザー確認
- **Kusanagi** (Opus): タスク配分、Worktree情報伝達
- **Tachikoma** (Sonnet): 実装（worktree配下で作業、`/serena`活用推奨）

### 並列実行鉄則
- Tachikoma起動は1メッセージで同時実行
- 独立タスクは絶対に並列化
- Agent定義ファイルは最初に1回だけ読み込む

---

## 🔄 メンテナンス

### 日次
serena再アクティベート

### 週次
serenaメモリ整理、claude-memデータベース整合性確認、worktree一覧確認

### 月次
claude-memワーカー再起動
