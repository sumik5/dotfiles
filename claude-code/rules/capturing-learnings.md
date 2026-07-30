# 継続的学習（capturing-learnings）

作業中に得た学び・エラー・ユーザー訂正・機能要望を `.learnings/` に構造化記録し、反復パターンを検出してプロジェクトメモリや新スキルへ昇格する**常時オンの最小トリガー＆ルーティング集**。エントリ書式（`[LRN/ERR/FEAT-YYYYMMDD-XXX]`）・ID規則・解決フロー・昇格手順の詳細は `capturing-learnings` スキル本体を参照（本ファイルは「いつ・どこへ」を素早く判断するインデックス）。

## always-on 機構

| エージェント | 自動発火 | 仕組み |
|------------|---------|--------|
| Claude Code | ✅ 自動 | devkit の hook（`learnings-reminder.sh`=UserPromptSubmit / `learnings-error-detector.sh`=PostToolUse）が登録済み |
| Codex CLI | opt-in | hook は experimental。`~/dotfiles/codex/AGENTS.md` の記述が主機構。`config.toml` の `codex_hooks=true` + `.codex/hooks.json` で同一スクリプトを有効化可 |

## 検出トリガー（If X then Y）

| If X（トリガー） | then Y（行動） |
|----------------|--------------|
| ユーザーが訂正・誤りを指摘（「いや違う」「正しくは…」「それは古い」） | `.learnings/LEARNINGS.md` に `correction` で記録 |
| 知らなかった情報の提供／参照ドキュメントが古い／APIの挙動が想定と異なる | `.learnings/LEARNINGS.md` に `knowledge_gap` で記録 |
| 非自明なエラーを調査して解決（再発しうる） | `.learnings/ERRORS.md` に `[ERR-YYYYMMDD-XXX]` で記録 |
| 存在しない機能を要望された（「〜もできる?」「〜できたらいいのに」） | `.learnings/FEATURE_REQUESTS.md` に記録 |
| 反復タスクでより良い方法を発見 | `.learnings/LEARNINGS.md` に `best_practice` で記録 |
| 大きな作業を始める前 | `.learnings/` を振り返り関連する過去の学びを確認 |

記録は context が新鮮なうちに即実施。本体が直接行ってよい（軽量な reflexive Write・タチコマ委譲不要）。

## ルーティング（学びをどこへ流すか）

| 学びの性質 | 行き先 |
|-----------|--------|
| 一過性・そのプロジェクト限定の作業メモ | `.learnings/`（留置） |
| プロジェクト固有の事実・規約・落とし穴 | そのプロジェクトの `CLAUDE.md` |
| ユーザー横断・複数セッションに渡る事実 | Claude Code memory（配置先の memory 規約に従う・1ファイル1事実＋`MEMORY.md`索引） |
| sumik-claude-plugin 自身のスキル改善 | `~/.claude/.learnings/SKILL-IMPROVEMENTS.md` へ（実行中プロジェクトの `.learnings/` ではない・CWD非依存の単一グローバルキュー・`authoring-plugins` の IMPROVEMENT-INTAKE が消費） |
| 汎用で再利用価値が高い | `authoring-plugins` で新スキル抽出を検討 |

## 昇格ルール（反復パターン）

次の3条件をすべて満たす反復学びは memory / CLAUDE.md へ昇格する: ①Recurrence-Count ≥ 3 ②2つ以上の異なるタスクで観測 ③30日以内の窓で発生。昇格文は「コーディング前/中に何をすべきか」の短い予防ルールで書く（長い事後検証録にしない）。

## 既存機構との棲み分け（重複回避）

| 機構 | 対象 |
|------|------|
| `capturing-learnings`（本ルール） | **あらゆるプロジェクトの作業全般**の学び（汎用 `.learnings/` キャプチャ） |
| `~/.claude/.learnings/SKILL-IMPROVEMENTS.md` → `authoring-plugins` IMPROVEMENT-INTAKE | **sumik-claude-plugin 自身のスキル**の改善（[PROPOSAL] 捕捉→消費・CWD非依存） |
| `authoring-plugins` USAGE-REVIEW | スキルポートフォリオの定期棚卸し（月次/四半期） |
| `managing-claude-md` | CLAUDE.md という生きたドキュメントの整備 |

取り違え禁止: 「プラグインのスキルを直す学び」は `~/.claude/.learnings/SKILL-IMPROVEMENTS.md`、それ以外の学びは実行中プロジェクトの `.learnings/`。
