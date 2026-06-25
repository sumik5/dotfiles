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
| コミットメッセージ | Conventional Commits形式必須 |
| 新機能実装前 | `researching-libraries` で既存ライブラリ調査 |
| 複数ファイル変更前 | plannerが `docs/` に計画作成（軽微修正は例外） |
| 実装完了後 | `software-security` スキル（devkit / Project CodeGuard 日本語版）をロードしてセキュリティチェック |
| ファイル検索時（コード内容・ファイル名・複数識別子の探索） | **fff MCP 最優先**（devkit同梱・`grep`=内容/`find_files`=ファイル名/`multi_grep`=複数OR）。bare identifierで検索・regex回避・2回で打切りRead。serena(シンボル意味検索)/Glob(単純パス列挙)/rg(fff不在時)と棲み分け。詳細は `searching-files-with-fff` スキル参照 |
| Web検索時 | Exa MCP第一優先（fallback: gemini CLI） |
| CLAUDE.md改善時 | `managing-claude-md` スキル参照 → If X then Y形式で追記提案 |
| 作業中に学び・訂正・非自明なエラー・機能要望が生じた時 | `capturing-learnings` で `.learnings/` に記録（詳細: `rules/capturing-learnings.md`）。反復(Recurrence-Count≥3・2タスク以上・30日内)はmemory/CLAUDE.mdへ昇格 |

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
| 作業内容が明確になった時 | sessions-index.jsonの `summary` を `{prefix}-{english-slug}` 形式で更新 |
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

### [PROPOSAL] authoring-plugins / 規約違反 / 2026-06-07
- skill: authoring-plugins / 種別: 規約違反（陳腐化した教材例）
- 改善点: references/ の NAMING.md・NAMING-STRATEGY.md・TEMPLATES.md・SKILL-GUIDE.md が命名規則の例として廃止/改名済みスキル名（applying-design-guidelines・crafting-ai-copywriting・understanding-database-internals 等）を使用。現存スキル名へ差し替え。
- 理由: 公開authoring guideが存在しないスキル名を例示すると誤誘導。pedagogical flowを壊さぬよう慎重に置換。
- 確度: 中 / 影響範囲: 自スキルのみ / status: open

### [PROPOSAL] developing-databases / 内容追記 / 2026-06-07
- skill: developing-databases / 種別: 内容追記
- 改善点: references/INTERNALS-*.md にOCR由来の文字化けテキストが散在。該当箇所を正しい技術記述に再生成。
- 理由: 書籍ページ参照の除去は完了済みだが本文の文字化けは未修整で可読性を損なう。
- 確度: 中 / 影響範囲: 自スキルのみ / status: open

### [PROPOSAL] creating-flashcards / 分割 / 2026-06-07
- skill: creating-flashcards / 種別: 分割
- 改善点: INSTRUCTIONS.md が減量後も607行（500目安超）。CONTRACTブロック・Step6詳細コード仕様を別referenceへ退避できるか再構成検討。
- 理由: 多言語/デッキ戦略の退避は完了したが本体がなお肥大。
- 確度: 中 / 影響範囲: 自スキルのみ / status: open

### [PROPOSAL] find-skills / 規約違反 / 2026-06-07
- skill: find-skills / 種別: 規約違反
- 改善点: SKILL.md本文が英語＋144行直書き（薄いSKILL.md+INSTRUCTIONS分離の規約違反、コーパスは日本語基本）。日本語化＋INSTRUCTIONS.md分離。
- 理由: 兄弟スキル(searching-web等)と構造・記述言語が不一致。
- 確度: 中 / 影響範囲: 自スキルのみ / status: open

### [PROPOSAL] authoring-plugins / 内容追記 / 2026-06-25
- skill: authoring-plugins / 種別: 内容追記（references/MANAGING-MULTI-PLUGIN.md）
- 改善点: MCP 同梱プラグインを新規追加する手順を明文化する。①ランナー別 bin ラッパーを複製（npx→npx-mise.sh / uvx→uvx-mise.sh / pipx→pipx-mise.sh、Claude は `${CLAUDE_PLUGIN_ROOT}/bin/...`、Codex は `./bin/... + cwd "."`）②`.mcp.json`/`.mcp-codex.json` に env ブロックを置かず秘匿値はシェル環境の継承で供給（devkit/studio の全 MCP が env 無し＝確立済み慣習。`${VAR:-}` 展開は空文字が ADC 認証等を壊すリスクあり非推奨）。
- 理由: 既存ガイドは「Codex で plugin-root 変数を使わない」までは記載するが、Python/pipx ランナーの扱いと env ブロック非設置の慣習が未明文化で、google プラグイン追加時に studio/devkit から都度導出する必要があった。
- 確度: 中 / 影響範囲: 自スキルのみ（references/MANAGING-MULTI-PLUGIN.md） / status: open

@RTK.md
