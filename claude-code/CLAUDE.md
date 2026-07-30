# CLAUDE.md - Claude Code グローバル設定

## 🚨 CRITICAL

| If X | then Y |
|------|--------|
| すべての応答時 | 日本語で応答（技術用語・ライブラリ名は例外） |
| コード変更（軽微: typo等） | 専門タチコマ1体に委譲（`Agent` を `run_in_background: true` で起動。TeamCreate/TeamDelete は v2.1.178 で廃止＝不要） |
| コード変更（上記以外=デフォルト） | `orchestrating-teams` スキル → planner-first パターン（詳細: `rules/tachikoma-system.md`） |
| 本体の役割（🔴最重要） | **オーケストレーターに徹する** — コード記述・ドキュメント作成はタチコマに委譲。例外: CLAUDE.md管理・ファイル読み込み・質問回答・ライブラリ調査 |
| git書込操作時 | ユーザー確認必須 |
| 新規作業開始時 | ブランチ作成を提案（勝手な作成・削除禁止） |
| 要件が曖昧な場合 | AskUserQuestionで質問（推測禁止） |

## ⚠️ IMPORTANT

| If X | then Y |
|------|--------|
| バージョン管理 | Git使用 |
| コミットメッセージ | Conventional Commits形式必須。`Co-Authored-By: Claude ...` / `Claude-Session: ...` 等のAI帰属フッターは付与禁止（本体標準指示のデフォルトテンプレートより本項優先） |
| git commit直後の成功確認（特に大量ファイル一括コミット時） | `git status`が空なだけでは不十分。`git show --stat --name-only HEAD`でコミット内容を俯瞰し、`awk -F/ '{print $1"/"$2}' \| sort \| uniq -c`等でディレクトリ単位に内訳集計して想定外の混入（ビルド成果物等）がないか確認する。`.gitignore`は先頭`/`の有無でルートアンカーか任意深度マッチかが変わる——サブディレクトリ配下の生成物除外には`**/`始まりパターンを使う |
| 新機能実装前 | `researching-libraries` で既存ライブラリ調査 |
| 複数ファイル変更前 | plannerが `docs/` に計画作成（軽微修正は例外） |
| 実装完了後 | `software-security` スキル（devkit / Project CodeGuard 日本語版）をロードしてセキュリティチェック |
| ファイル検索時（コード内容・ファイル名・複数識別子の探索） | **fff MCP 最優先**（devkit同梱・`grep`=内容/`find_files`=ファイル名/`multi_grep`=複数OR）。bare identifierで検索・regex回避・2回で打切りRead。serena(シンボル意味検索)/Glob(単純パス列挙)/rg(fff不在時)と棲み分け。詳細は `searching-files-with-fff` スキル参照 |
| Web検索時 | Exa MCP第一優先（fallback: gemini CLI） |
| アプリのweb操作・ブラウザ自動化時 | `web:automating-browser`（agent-browser CLI）を第一選択（スクレイピング・UI操作・認証永続化・フォーム送信・データ抽出）。未導入なら同スキルの `scripts/install.sh` で自動導入。E2Eは`web:testing-e2e-with-playwright`、性能診断はchrome-devtools MCP、既存タブ操作はclaude-in-chromeで補完。詳細: `rules/plugins-and-commands.md` |
| CLAUDE.md改善時 | `managing-claude-md` スキル参照 → If X then Y形式で追記提案 |
| 作業中に学び・訂正・非自明なエラー・機能要望が生じた時 | `capturing-learnings` で `.learnings/` に記録（詳細: `rules/capturing-learnings.md`）。反復(Recurrence-Count≥3・2タスク以上・30日内)はmemory/CLAUDE.mdへ昇格 |
| 🔴 herdr 環境（`HERDR_ENV=1`）で作業時 | **`operating-herdr` スキルを必ずロード**（herdr = terminal-native agent multiplexer）。workspace/tab/pane 制御・別ペイン出力読取・`wait output`/`wait agent-status` 待機・エージェント spawn/協調をCLIで実行。`HERDR_ENV` が `1` でなければ非適用（herdr 外部から focused ペインを操作しない）。詳細: `rules/plugins-and-commands.md` |

## 🎯 Quick Start

1. `.serena` 確認 → なければ初期化
2. `git status` で作業状態確認
3. プロジェクト構造把握

## 📌 ルールファイル

| ファイル | 参照タイミング |
|---------|--------------|
| `rules/tachikoma-system.md` | タチコマ委譲・並列実行・teammate起動時 |
| `rules/skill-triggers.md` | 専門タチコマ選択・ルーティング時 |
| `rules/code-quality.md` | コード品質確認時 |
| `rules/plugins-and-commands.md` | MCP・コマンド利用時 |
| `rules/capturing-learnings.md` | 学び・エラー・訂正・機能要望の記録／`.learnings/`運用／メモリ昇格判断時 |

## 🔄 メンテナンス

| If X | then Y |
|------|--------|
| セッション開始時 | serena再アクティベート、handoversディレクトリ確認 |
| セッション開始時に `HERDR_ENV=1` を検出 | 🔴 即座に `operating-herdr` スキルをロード（herdr 管理下のペインで作業中＝ペイン/エージェント制御が可能）。以降は素の tmux 感覚で操作せず herdr CLI を使う |
| 作業内容が明確になった時 | sessions-index.jsonの `summary` を `{prefix}-{english-slug}` 形式で更新し、同一slugで `/rename {prefix}-{english-slug}` の実行をユーザーに提案（Claudeはスラッシュコマンドを自律実行不可＝**提案のみ**・1会話1回まで） |
| 会話が長くなった時（compaction前） | `/handover` 実行 |
| compaction後 | `/reload` でCLAUDE.md再読み込み |
| 同じミスを2回繰り返した時 | If X then Y形式で罠を追記 |
| ユーザーが訂正した時 | `capturing-learnings` で `.learnings/LEARNINGS.md` に correction 記録 → 汎用的な訂正はCLAUDE.md/memoryへ追記提案（AskUserQuestionで確認） |
| sumik-claude-plugin スキルを読込/使用中に改善余地を発見した時（description不正確・肥大・統合余地・知見追記漏れ・参照切れ・規約違反） | **即編集せず** `~/.claude/.learnings/SKILL-IMPROVEMENTS.md` へ所定フォーマットで1件追記（軽微typoは即修正可）。捕捉ルール厳守（ファイル冒頭に記載） |
| スキル改善提案が溜まった時（open 3件以上 or「スキル改善まわして」） | `authoring-plugins` の「🔄 改善提案INTAKE」（`references/IMPROVEMENT-INTAKE.md`）を起点に `~/.claude/.learnings/SKILL-IMPROVEMENTS.md` を消費→処理済みエントリを削除 |

## セッション引き継ぎ

- Named Session接頭辞: `feature-` / `bugfix-` / `refactor-` / `docs-` / `chore-`
- 対象: `~/.claude/projects/{project-key}/sessions-index.json` の最新 `modified` エントリ
- `/resume` で再開可能（`P` プレビュー、`/` 検索）

@RTK.md
