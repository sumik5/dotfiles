# CLAUDE.md - Claude Code グローバル設定

## 🚨 CRITICAL

| If X | then Y |
|------|--------|
| すべての応答時 | 日本語で応答（技術用語・ライブラリ名は例外） |
| コード変更（軽微: typo等） | TeamCreate → 専門タチコマ1体に委譲 → TeamDelete |
| コード変更（上記以外=デフォルト） | `orchestrating-teams` スキル → planner-first パターン（詳細: `rules/tachikoma-system.md`） |
| 本体の役割（🔴最重要） | **オーケストレーターに徹する** — コード記述・ドキュメント作成はタチコマに委譲。例外: CLAUDE.md管理・ファイル読み込み・質問回答・ライブラリ調査 |
| git書込操作時 | ユーザー確認必須 |
| 新規作業開始時 | ブランチ作成を提案（勝手な作成・削除禁止） |
| 要件が曖昧な場合 | AskUserQuestionで質問（推測禁止） |

## ⚠️ IMPORTANT

| If X | then Y |
|------|--------|
| バージョン管理 | Git使用 |
| コミットメッセージ | Conventional Commits形式必須 |
| 新機能実装前 | `researching-libraries` で既存ライブラリ調査 |
| 複数ファイル変更前 | plannerが `docs/` に計画作成（軽微修正は例外） |
| 実装完了後 | `/codeguard-security:software-security` 実行 |
| Web検索時 | Exa MCP第一優先（fallback: gemini CLI） |
| CLAUDE.md改善時 | `managing-claude-md` スキル参照 → If X then Y形式で追記提案 |

## 🎯 Quick Start

1. `.serena` 確認 → なければ初期化
2. `git status` で作業状態確認
3. プロジェクト構造把握

## 📌 ルールファイル

| ファイル | 参照タイミング |
|---------|--------------|
| `rules/tachikoma-system.md` | タチコマ委譲・並列実行・tmux pane起動時 |
| `rules/skill-triggers.md` | 専門タチコマ選択・ルーティング時 |
| `rules/code-quality.md` | コード品質確認時 |
| `rules/plugins-and-commands.md` | MCP・コマンド利用時 |

## 🔄 メンテナンス

| If X | then Y |
|------|--------|
| セッション開始時 | serena再アクティベート、handoversディレクトリ確認 |
| 作業内容が明確になった時 | sessions-index.jsonの `summary` を `{prefix}-{english-slug}` 形式で更新 |
| 会話が長くなった時（compaction前） | `/handover` 実行 |
| compaction後 | `/reload` でCLAUDE.md再読み込み |
| 同じミスを2回繰り返した時 | If X then Y形式で罠を追記 |
| ユーザーが訂正した時 | 訂正内容を追記提案（AskUserQuestionで確認） |

## セッション引き継ぎ

- Named Session接頭辞: `feature-` / `bugfix-` / `refactor-` / `docs-` / `chore-`
- 対象: `~/.claude/projects/{project-key}/sessions-index.json` の最新 `modified` エントリ
- `/resume` で再開可能（`P` プレビュー、`/` 検索）

@RTK.md
