# CLAUDE.md - Claude Code グローバル設定

Claude Code グローバル設定。開発ワークフロー（Agent Teamオーケストレーション・タチコマ委譲・Jujutsu運用）とコード品質（SOLID・型安全性）の両方を全プロジェクト共通ルールとして定義。

---

## 🚨 CRITICAL

以下のルールに違反すると重大な問題を引き起こす:

| トリガー（If X） | 行動（then Y） |
|----------------|--------------|
| すべての応答時 | 必ず日本語で応答（例外: 技術用語・ライブラリ名・プログラミングキーワード） |
| コードファイル変更時（軽微: typo・1行変更等の明白な修正） | TeamCreate → **適切な専門タチコマ**1体に委譲（`team_name` + `run_in_background: true`）→ 完了後TeamDelete |
| コードファイル変更時（上記以外すべて＝デフォルト） | `orchestrating-teams` スキルロード → TeamCreate → **planner**（タチコマ（アーキテクチャ））が現状分析・計画策定・docs/作成 → ユーザー確認 → **専門タチコマ**が実装 → TeamDelete |
| Claude Code本体の役割（🔴最重要） | **オーケストレーターに徹する**: タスク分析・ルーティング判断・チーム編成・進捗監視・jj操作・ユーザー対話のみ。コード記述も計画ドキュメント作成もチームメイトに委譲。例外: CLAUDE.md/ルールファイル管理・ファイル読み込み（1-2ファイル）・質問回答・ライブラリ調査 |
| jj書込操作実行時（`jj new`, `jj commit`, `jj describe`, `jj git push`） | ユーザー確認必須（コミットメッセージ生成は `gcauto` を使用。対話的ツールのためClaude Codeからは `jj commit -m` を直接使用） |
| 新規作業開始時 | ユーザー確認してchangeとbookmark作成を提案（勝手な作成・削除禁止） |
| 要件・仕様が曖昧な場合 | AskUserQuestionツールで質問（推測での作業進行禁止） |

---

## ⚠️ IMPORTANT

品質・プロセスに関わるルール:

| トリガー（If X） | 行動（then Y） |
|----------------|--------------|
| バージョン管理操作時 | Jujutsu (jj) を使用（`git` コマンドは原則禁止。`jj git` サブコマンドは許可） |
| コミットメッセージ作成時 | Conventional Commits形式必須（`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`等） |
| 新機能の実装開始前 | `researching-libraries` スキルで既存ライブラリを調査（車輪の再発明禁止） |
| 複数ファイル変更の実装前 | planner（タチコマ（アーキテクチャ））が `docs/` に計画ドキュメント作成（軽微修正は例外） |
| コード品質確認時 | 専門タチコマがSOLID原則・型安全性を遵守（各タチコマにコア品質スキルがプリロード済み）。本体は直接チェックしない |
| 実装完了後 | CodeGuardセキュリティチェック実行（`/codeguard-security:software-security`） |
| Web検索・情報収集時 | Exa MCP（`searching-with-exa` スキル）を第一優先で使用（gemini CLI / WebSearch は fallback） |
| 作業中にCLAUDE.mdへ取り込むべき知見を発見した時 | `managing-claude-md` スキル参照し、適切なファイルにIf X then Y形式で追記提案（AskUserQuestionで確認後に追記） |

---

## 💻 よく使うコマンド

| コマンド | 説明 | 実行タイミング |
|---------|------|--------------|
| `jj status` | 作業コピーの状態確認 | 作業開始時、変更確認時 |
| `jj diff` | 現在の変更差分確認 | コミット前、変更内容確認時 |
| `jj log` | 変更履歴表示 | 履歴確認時 |
| `jj bookmark list` | bookmark一覧確認 | 作業ブランチ確認時 |
| `gcauto` | AI生成メッセージでコミット（対話式。Claude Codeからは `jj commit -m` を使用） | コミット作成時 |
| `/reload` | CLAUDE.md再読み込み | compaction後のコンテキスト復元時 |
| `/serena "問題"` | トークン効率的な構造化開発 | コンポーネント開発・API実装・バグ修正時 |
| `/resume [名前]` | Named Sessionの再開 | 中断したセッションの再開時 |

---

## 🎯 Quick Start

| ステップ | 行動 |
|---------|------|
| 1 | `.serena` 確認 → なければ serena 初期化・オンボーディング |
| 2 | `jj status` で作業状態確認 |
| 3 | プロジェクト構造把握 |

---

## 📌 ルールファイル参照

| ファイル | 内容 | 参照タイミング |
|---------|------|--------------|
| `rules/jujutsu.md` | Jujutsu バージョン管理ルール | jj操作の詳細確認時 |
| `rules/tachikoma-system.md` | Agent Teamオーケストレーション・タチコマシステム・並列実行・ドキュメント先行開発（`orchestrating-teams` スキル参照） | 並列実行判断時 |
| `rules/code-quality.md` | SOLID・型安全性・テスト・セキュリティ | コード実装・レビュー時 |
| `rules/plugins-and-commands.md` | プラグイン環境・MCP・スラッシュコマンド | プラグイン・MCP利用時 |
| `rules/skill-triggers.md` | サブエージェント委譲ガイド・ルーティング表 | コード実装委譲時の専門タチコマ選択 |

---

## 🔄 メンテナンス

| トリガー（If X） | 行動（then Y） |
|----------------|--------------|
| セッション開始時 | serena再アクティベート |
| セッション開始後、作業内容が明確になった時点 | sessions-index.jsonの最新エントリの `summary` を `{prefix}-{english-slug}` 形式（英語・kebab-case・50文字以内）で更新 |
| 会話が長く多くのツール呼び出し・ファイル変更を行った時（compaction前） | `/handover` を実行してHANDOVER.mdを生成（PreCompact hookはAI推論不可のため、Claude自身が先手を打つ） |
| compaction発生後 | `/reload` でCLAUDE.md再読み込み |
| 週次 | serenaメモリ整理、`jj bookmark list` で不要bookmark整理 |
| Claudeが同じミスを2回繰り返した時 | `managing-claude-md` スキル参照 → If X then Y形式で罠を追記 |
| ユーザーがClaudeの行動を訂正した時 | 訂正内容をIf X then Y形式で追記提案（AskUserQuestionで確認） |
| プロジェクト固有の暗黙知を発見した時 | プロジェクトCLAUDE.mdへの追記を提案（デバッグで判明した依存関係、環境固有の設定等） |
| 同じ説明をセッション内で2回以上した時 | 長期記憶（CLAUDE.md）への移動を提案（チャットは揮発する） |
| CLAUDE.md追記・改善時 | `managing-claude-md` スキル参照（8原則: 300行以下、段階的開示、優先度配置等） |

---

## セッション引き継ぎ・Named Session

- セッション開始時にプロジェクトルートの `.claude/handovers/` ディレクトリを確認し、ファイルが存在すれば最新のものを読み込む
- セッション終了時や作業の区切りでは `/handover` の実行を促す

### Named Session 命名規則

| 接頭辞 | 用途 | 例 |
|--------|------|-----|
| `feature-` | 新機能開発 | `feature-auth-system` |
| `bugfix-` | バグ修正 | `bugfix-login-redirect` |
| `refactor-` | リファクタリング | `refactor-api-layer` |
| `docs-` | ドキュメント作成・更新 | `docs-claude-md-update` |
| `chore-` | 設定変更・メンテナンス | `chore-deps-upgrade` |

- Claude自身が作業内容からセッション名を判定し、sessions-index.jsonの `summary` を更新
- 対象: `~/.claude/projects/{project-key}/sessions-index.json` の最新 `modified` エントリ（project-key = CWDの `/` → `-` 置換）
- 手動: `/rename` も利用可能、`/resume` で再開可能（`P` プレビュー、`/` 検索）
