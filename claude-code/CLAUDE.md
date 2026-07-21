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
| sumik-claude-plugin スキルを読込/使用中に改善余地を発見した時（description不正確・肥大・統合余地・知見追記漏れ・参照切れ・規約違反） | **即編集せず**下記「📥 スキル改善提案」へ所定フォーマットで1件追記（軽微typoは即修正可）。捕捉ルール厳守 |
| スキル改善提案が溜まった時（open 3件以上 or「スキル改善まわして」） | `authoring-plugins` の「🔄 改善提案INTAKE」（`references/IMPROVEMENT-INTAKE.md`）を起点に消費→処理済みを📥からドレイン |

## セッション引き継ぎ

- Named Session接頭辞: `feature-` / `bugfix-` / `refactor-` / `docs-` / `chore-`
- 対象: `~/.claude/projects/{project-key}/sessions-index.json` の最新 `modified` エントリ
- `/resume` で再開可能（`P` プレビュー、`/` 検索）

## 📥 スキル改善提案 (inbox)

sumik-claude-plugin スキルの改善提案キュー。捕捉(C)→消費(D=`authoring-plugins` の「🔄 改善提案INTAKE」)を繋ぐ単一キュー。**openのみ保持**し、消費後は削除（CLAUDE.md 300行原則を死守）。フォーマット全仕様は `authoring-plugins/references/IMPROVEMENT-INTAKE.md §2`。

**捕捉ルール**: ①実際に読込/使用したスキルに限る（未読の推測提案禁止）②1スキル1セッション1件 ③確度=低は書かない ④具体的改善文/削除対象行を伴うもののみ（漠然とした感想不可）⑤作業主目的を中断せずタスク完了後に追記。各提案は `### [PROPOSAL] <skill> / <種別> / <日付>` 見出し＋ skill・種別(description改善/分割/統合/内容追記/参照修正/規約違反)・改善点・理由(書籍名禁止)・確度(高/中)・影響範囲・status を箇条書きで持つ。

### [PROPOSAL] orchestrating-teams / 参照修正 / 2026-07-14
- skill: orchestrating-teams / 種別: 参照修正（herdr起動例のagent名前空間誤り）
- 改善点: `references/WORKFLOW-GUIDE.md` の herdr backend 起動例（Step 2「herdr バックエンド」および Step 5「herdr バックエンド」の bash スニペット）が `--agent sumik:tachikoma-str-product-mgr` / 実装例の `--agent sumik:tachikoma-fw-nextjs` 等、全て `sumik:` prefix で記載されている。実際にインストール済みプラグインの agent 名前空間は `devkit:`（`claude --agent <invalid> -p "OK"` が返す `Available agents: ...` 一覧で確認・`devkit:tachikoma-str-product-mgr` 等が正）。`sumik:` のままherdr起動すると `claude` プロセスが即エラー終了し、herdr pane が起動直後に消滅する（`agent_started` 成功レスポンスはpane作成成功を返すだけで中のclaudeプロセス生存を保証しないため誤って成功に見える＝サイレント失敗）。**追記訂正**: 当初「`Agent` tool の `subagent_type` は `sumik:` のまま機能する」と誤記したが、`Agent(subagent_type: "sumik:tachikoma-lang-bash")` を直接検証した結果 `Agent type 'sumik:tachikoma-lang-bash' not found. Available agents: ... devkit:tachikoma-lang-bash ...` と同一のエラーで即失敗することを確認した。つまり `sumik:` prefixは `Agent` tool 経由でも herdr `--agent` フラグ経由でも一貫して無効であり、`references/TEAM-PATTERNS.md` 等スキル内の他の `sumik:tachikoma-*` 表記も同様に誤りの可能性が高い（未走査。grep で `/Users/sumik/.claude/plugins/marketplaces/sumik/plugins/devkit/skills/` 配下に他にも `orchestrating-codex`・`converting-agents-to-codex`・`authoring-plugins` references・`creating-slides` 等 複数スキルで `sumik:tachikoma` 表記がヒットするが、本セッションでは未読のため未検証＝別セッションでの確認要）。なお本体側の個人設定 `~/dotfiles/claude-code/rules/tachikoma-system.md`・`rules/skill-triggers.md` は同じ根本原因のため本セッションで `devkit:` に修正済み（プラグイン本体ではなく個人dotfilesのため直接修正、スキル改善提案の対象外）。
- 理由: 2026-07-14 Dinumeraプロジェクト（countdown）でIAP機能planner起動時に実際に発生・`.learnings/ERRORS.md` の ERR-20260714-004 として実証済み（`timeout 25 claude --agent sumik:tachikoma-str-product-mgr ... -p "OK"` および `Agent(subagent_type: "sumik:tachikoma-lang-bash")` の両方で `not found` エラーを再現し原因確定）。
- 確度: 高 / 影響範囲: orchestrating-teams以外にも波及の疑いあり（要別セッション調査: orchestrating-codex, converting-agents-to-codex, authoring-plugins, creating-slides） / status: open

### [PROPOSAL] developing-databases / 内容追記 / 2026-07-10
- skill: developing-databases / 種別: 内容追記（OCR校正の残存・要技術裏取り）
- 改善点: references/ の3点を裏取りのうえ修正。①INTERNALS-DBMS-ARCHITECTURE.md の行指向DB代表例に C-Store が列挙（C-Store は列指向のため内容誤りの疑い）②INTERNALS-FAILURE-DETECTION-LEADER-ELECTION.md の引用キー [MOLINAR82]（GARCIAMOLINA82 の誤変換疑い・コーパス引用キー慣行と突合）③図9-x/図10-x 等、存在しない図への宙参照の整理（削除 or 文章化）。
- 理由: 2026-07-10 の INTERNALS 全15ファイル校正（inbox 5件消費の一環）で校正エージェントが「用語誤変換と違い内容判断・裏取りが必要」と保留報告した箇所。
- 確度: 中 / 影響範囲: 自スキルのみ / status: open

@RTK.md
