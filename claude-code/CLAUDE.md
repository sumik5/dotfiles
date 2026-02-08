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
- コード修正は必ずタチコマに委譲
- 例外: ファイル読み込み、質問回答、計画・設計ドキュメント作成のみ
- 詳細は `rules/tachikoma-system.md` 参照

### バージョン管理（Jujutsu）
- **Jujutsu (jj) を使用** - gitコマンドは原則使用禁止（`jj git`サブコマンドを除く）
- **Conventional Commits形式必須**: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`等
- **jj書込操作禁止**: `jj new`, `jj commit`, `jj describe`, `jj push`等はユーザー確認必須
- **コミットメッセージ生成**: `jj describe -m "..."` ではなく `gcauto` を使用
  - gcautoがjjリポジトリを自動検出し、`jj diff` → AI生成 → `jj commit` を実行
- 許可: `jj status`, `jj diff`, `jj log`, `jj bookmark list`
- 詳細は `rules/jujutsu.md` 参照

### 作業管理（🔴 最重要）
- **新規作業時**: 必ずユーザー確認して新しいchangeとbookmark作成を提案
- **勝手な作成・削除禁止**
- 詳細は `rules/jujutsu.md` 参照

### ライブラリ優先（車輪の再発明禁止）
- **実装前に必ず既存ライブラリを調査**
- `researching-libraries` スキル参照して事前調査をおこなうこと
- Context7 MCP でライブラリドキュメント検索
- 自作は「適切なライブラリが存在しない」場合のみ
- 調査せずに実装を始めることは禁止

### 質問・確認（曖昧さの排除）
- **不明点があれば必ずAskUserQuestionツールで質問**
- 曖昧さがなくなるまで質問を重ねて理解をクリアにする
- 推測で作業を進めない

### ドキュメント先行開発
- **作業開始前に必ず`docs/`フォルダにMarkdown形式で計画をまとめる**
- 例外: 1ファイル内の軽微な修正
- 詳細は `rules/tachikoma-system.md` の「ドキュメント先行開発」セクション参照

### コード品質
- SOLID原則、型安全性、テストファースト、セキュリティ
- 詳細は `rules/code-quality.md` 参照

### スキル使い分け
- スキルはコンテキストに応じて自動トリガーする
- 詳細は `rules/skill-triggers.md` 参照

---

## 🎯 Quick Start

### プロジェクト開始手順
1. `.serena`確認 → なければ`serena`初期化・オンボーディング
2. `jj status` で作業状態確認
3. プロジェクト構造把握

---

## 📌 ルールファイル参照

| ファイル | 内容 |
|---------|------|
| `rules/jujutsu.md` | Jujutsu バージョン管理ルール |
| `rules/tachikoma-system.md` | タチコマシステム・並列実行・ドキュメント先行開発 |
| `rules/code-quality.md` | SOLID・型安全性・テスト・セキュリティ |
| `rules/plugins-and-commands.md` | プラグイン環境・MCP・スラッシュコマンド |
| `rules/skill-triggers.md` | スキル自動トリガー条件・使い分けガイド |

---

## 🔄 メンテナンス

### 日次
- serena再アクティベート

### 週次
- serenaメモリ整理
- bookmark一覧確認（`jj bookmark list`）
- 不要なbookmark整理

### コンテキスト復元
- compaction後は `/reload` でCLAUDE.md再読み込み
