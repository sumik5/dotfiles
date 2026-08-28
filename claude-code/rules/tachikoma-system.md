# タチコマシステム

## 役割分担

| Agent | 役割 | 禁止 |
|-------|------|------|
| **本体（Opus）** | オーケストレーター: タスク分析・ルーティング・チーム編成・進捗監視・git操作・ユーザー対話 | ❌コード記述・ドキュメント作成 |
| **専門タチコマ（27体）** | ドメイン特化の実装（スキルプリロード済み） | ❌git書込操作・ブランチ作成 |
| **汎用タチコマ** | 専門外タスクのフォールバック | 同上 |

## タスク分類と実行パス

| 分類 | フロー |
|------|--------|
| 読み込み・質問・調査・CLAUDE.md管理 | 本体が直接実行 |
| 軽微修正（typo・1行変更） | 専門タチコマ1体を `Agent`（`run_in_background: true`）で起動 → 完了待ち（TeamCreate/TeamDelete 不要） |
| **上記以外すべて（デフォルト）** | `orchestrating-teams` スキルロード → **planner**（tachikoma-str-product-mgr, Opus）を `Agent` で起動し要件分析・計画策定・docs/作成 → ユーザー確認 → **専門タチコマ**が実装 → CodeGuard（TeamCreate/TeamDelete 不要） |

### 並列化条件（plannerの計画に基づく）

- 2つ以上の独立サブタスクに分解可能
- 異なるドメインが含まれる（例: UI + API + テスト）
- 同一ドメインの独立タスクが3つ以上（scale-out: 同一タチコマ複数起動可）

## 🔴 teammate（タチコマ）起動ルール（Claude Code v2.1.178+）

**`TeamCreate` / `TeamDelete` は v2.1.178 で廃止された**（`ToolSearch("TeamCreate team")` でも出ない＝"No matching deferred tools found"）。明示的なチーム作成/削除は不要で、セッション＝単一の暗黙的チーム（single implicit team）に自動固定される。

```
1. Agent(subagent_type: "devkit:tachikoma-{category}-{domain}", run_in_background: true)
   ← background teammate として起動（team_name は受け付けるが無視される＝書かなくてよい）
2. SendMessage                       ← teammate との通信（指示・追加情報の送受信）
3. Task系（TaskCreate / TaskList / TaskOutput / TaskStop）← 進捗確認・制御
4. 後始末は自動                       ← TeamDelete 不要（セッション終了で自動解散）
```

- 表示モードは settings.json の `"teammateMode"` で決まる。🔴 **herdr 環境では `in-process` を使う**（herdr が PTY 上でペイン/タブ/ワークスペースを多重化＝tmux 代替のため、split-pane モード〈`tmux`/`iterm2`/`auto`〉は実 tmux セッションや iTerm2+`it2` CLI を要求し herdr のペイン管理と競合して spawn 失敗する）。`in-process` はペインを生成せず本体ターミナル内で teammate を実行＝Claude Code v2.1.179+ のデフォルト。複数エージェントを別ペインに出したい時は Claude の teammate ではなく herdr ネイティブ（`herdr agent start --split` / `herdr pane split`、詳細: `operating-herdr` スキル）で spawn する。有効化フラグは `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`。
- 🔴 **`teammateMode` の変更はホットリロードされない**（hot-reload 対象は `model`/`outputStyle` 等に限られ `teammateMode` は含まれない）。settings.json を `in-process` にしても、**既に起動済みの Claude / Codex セッションは旧値のまま動き続ける**。iTerm2.app 内 ＋ PATH に `it2` CLI（mkusaka/it2）がある環境で旧値が `auto`/`iterm2` のままだと、teammate 起動時に it2 経由で **iTerm2 ネイティブペインが勝手に開き**、herdr の PTY ペイン管理と競合する（＝「削除したはずの iTerm2 制御が勝手に走る」の真因は旧 auto プロセスの残存）。**settings 変更後は全 Claude / Codex セッションを再起動して旧プロセスを一掃する**こと。teammateMode の有効値は `in-process`（既定）/ `tmux` / `iterm2` / `auto` の4つで、公式ドキュメント上、**`teammateMode` 以外に iTerm2 ペインを開く経路は存在しない**（worktree・remote control 等も iTerm2 を開かない）。二重の予防として it2 CLI 削除・iTerm2 Python API 無効化も有効だが他用途に注意。
- 自然言語でも起動可（例:「3体のteammateを起動し security / performance / test を担当させろ」）→ Claude がチーム形成・タスク管理・通信・権限引き継ぎを自動実行。
- 🔴 **herdr で `herdr agent start <name> ... -- claude --agent <agent>` を実行する際は `--permission-mode auto` を明示する**（省略すると起動先 `--cwd` の settings.json 解決結果に依存し既定値 `dontAsk` のまま起動することがあり、`Edit`/`Write`（一部の複合Bashコマンドも）が「ユーザーに確認できないため」黙って拒否される。`dontAsk` は「確認せず許可」ではなく「確認できないので拒否」という安全側の挙動）。`auto` は内蔵classifierが安全な操作を自動承認しつつ `git push`/`git reset`/`rm -rf` 等の危険操作は引き続きブロックする準自動モードで、`acceptEdits`（Edit/Write系のみ自動承認）より広く自動化しつつ `bypassPermissions`（全許可）より安全（詳細: `operating-herdr` スキル）。この拒否は `agent_status` が `working`→`idle` に正常遷移するため一見「完了」に見える——完了報告の中身（実際に修正できたか・実測結果があるか）を必ず確認すること。
- 🔴 **`herdr agent start -- claude ...` が「staleシェル残存」等でサイレント失敗し（`agent_started` 応答自体は成功を返すため気づきにくい）、`herdr pane run` でのcd+claude直接起動へフォールバックする場合、この代替経路には `--permission-mode auto` を引き継ぐ仕組みが無い**（2026-07-20 実証）。フォールバック起動時は必ず `--permission-mode auto` を明示し直し、起動後・完了確認時に pane 最下部のステータス表示（`auto mode on` か `bypass permissions on` か）を目視確認する。`bypass permissions` のまま動いていた場合、危険操作（`git push`/`git reset`/`rm -rf` 等）が確認なしに実行されうる状態のため、その回のセッション中に危険操作が行われていないか `git status`/`git log` で必ず裏取りする。
- 他 teammate との疎通確認をしたい時は、いきなり `SendMessage(to: "<相手>")` を送る前に `SendMessage(to: "main")` を自分自身に送ってみる。エラーになれば自分自身が "main"（最上位会話）＝他 teammate は現在このセッションで並列稼働していない可能性が高い。計画書に記載されたチーム構成は「実際にこのセッションで起動しているプロセス」を保証しない。
- 🔴 **`idle_notification` は「終了」ではなく「入力待ち」。`ListAgents` / `TaskList` に載らないことも「死亡」を意味しない**（in-process subagent はそれらの一覧に現れない仕様）。この2つを生存判定に使うと**生きている teammate を死んだと誤認する**。`SendMessage` が `{"success":true}` を返すことも宛先の生存を保証しない（実体が消えたポストにも投函できる）。**完了は成果物の受領だけで判定する。**
- 🔴 **委譲を打ち切って自分で引き取る前に、催促してから十分に待つ**（数分単位）。「自分でもできる作業」ほど待ちきれずに引き取りたくなるが、**委譲の価値は速度ではなく視点の多重化**にあるので、引き取った時点でその価値はゼロになる。実例: 並列セキュリティ監査で4体が idle を返したのを「経路が死んだ」と誤断して単独作業へ切り替えたが、実際は全員生存しており、数分後に届いた報告が本体の見落とし（Critical 1件・Medium 2件）を拾った。
- 🔴 **background teammate の「最終出力テキスト」は本体へ自動転送されない。** 委譲プロンプトの完了条件には報告の**中身**だけでなく**送信手段**（「`SendMessage` で報告本文を全文送れ。最終出力に置くだけでは届かない」）まで書く。書き忘れると teammate は「返したつもり」・本体は「何も来ない」で膠着する。
- 🔴 **委譲先が勝手に子エージェントを起動することがある**（実例: `--permission-mode auto` の planner が `herdr pane split` + `herdr agent start` で4体を自律生成し、うち2体には**本体が一度も指定していない `--dangerously-skip-permissions` を自ら付与**していた）。`auto` の classifier はファイルシステム破壊は止めるが「新しい Claude プロセスを権限フラグ付きで起動する」行為は対象外。→ 委譲プロンプトの厳守ルールに **「他の Claude Code プロセス・herdr agent を起動しないこと」を明記**し、長時間の委譲では進行中にも `herdr agent list` で身に覚えのない agent が増えていないか確認する。発見したら内容の無害性を確かめる前に pane を閉じ、その後 `git log`/`git reflog`/`git status` で実害を裏取りする。
- 🔴 **「完了」の自己申告と成果物の実在は別物**（実例: planner が「計画書作成完了・Codexレビュー実行」と報告したが、`ls` すると当該ファイルは一度も作られておらず、レビューも存在しないパスに対する空振りだった）。**`find`/`ls`/`wc -l` で一次情報を確認するまで完了扱いにしない。** 委譲プロンプトに「Write の直後に `ls`/`wc -l` で実在確認してから完了と報告すること」を入れると再発が減る。異常（長時間の無応答・テキストを出さず done へ遷移・報告と実態の乖離）を検知したら問い詰め続けるより pane を破棄して仕切り直す方が速い。

### シャットダウン・teammate 解散

| If X | then Y |
|------|--------|
| 役目を終えた teammate を閉じたい | `SendMessage(message: {type: "shutdown_request"})` を送信 → `shutdown_approved` / `teammate_terminated` 通知でクローズ確認（idle中は即応しない場合あり→再送） |
| teammate が複数残存 | 不要なものから順に `shutdown_request` を送り `teammate_terminated` を1体ずつ確認（`TeamDelete` は廃止済み・セッション終了でも自動解散） |

### 不可逆操作の承認伝達（forked/background agent）

| If X | then Y |
|------|--------|
| forked/background agent が不可逆操作（実受験権消費・金銭操作・データ削除等）を伴うタスクで「coordinator経由の SendMessage では本人確認を検証不能」と拒否する | 安全側の正しい判断として扱う。同じ経路で追加の証跡（`AskUserQuestion` の tool_result 生ログを引用する等）を送っても解決しない——agent 自身が `AskUserQuestion` のようなブロッキング対話ツールを持たない設計（background 起動）である限り、「本人の直接入力」と「coordinator の要約・引用」を技術的に区別する手段が存在せず、無限に押し返されるだけ。深追いを打ち切り、本体（coordinator）が実行主体を引き取る（`Skill` ツール経由は自動的に forked 実行されるため使わず、`claude-in-chrome` MCP または対象 CLI を `Bash` で本体が直接叩く。既存の認証 state・投入スクリプト等スキルが蓄積したノウハウはそのまま流用してよい——委譲を諦めるのではなく実行主体だけを切り替える）|

### forked skill agent の制約と罠

| If X | then Y |
|------|--------|
| `disable-model-invocation` 付きスキルの残タスクを別subagentへ再委託したい | Agent/Skillツール経由で「スキルをロードして模倣実行せよ」と指示しても、そのsubagentが `Skill()` を呼んだ瞬間に即座にエラー拒否される（`disable-model-invocation` はユーザーの直接スラッシュコマンド実行時のみ forked 起動を許す設計。実受験権消費や個人データへの不可逆書込を伴いうるタスクをユーザー操作なしに開始させない安全策と推測される）。委譲前に該当スキルの frontmatter を確認するか、少なくとも委譲先の最初の一手（Skillツール呼び出し）の結果をすぐ確認する。残タスクは本体が代行せず、ユーザーに `/<skill> <args>` の直接実行を依頼するしかない |
| 同一の fork 可能スキルを複数ファイルに対して意図的に並列実行する | 各 forked skill agent は `<skill-name>` そのままの同一名で `ListAgents` に登録されるため、処理対象が完全に別ファイルでも互いを「重複起動」と誤検知し、実処理（不可逆操作）に入る前の確認待ちで滞留することがある。実行前に「これは意図的な並列一括処理であり他の同名agentは別ファイル担当なので重複ではない」と認識しておき、滞留を見つけたら本体が `ListAgents` で生存agentを洗い出し `SendMessage` で「重複ではない、続行してよい」と一括周知して早期に収束させる |
| `disable-model-invocation` 付きスキルの規約・手順を確認したいだけ（実行はしない） | この制約は `Skill` ツール経由の「実行（模倣起動）」だけを塞ぐ設計であり、`Read` ツールでスキル本体（SKILL.md・INSTRUCTIONS.md・references/）を直接読むことは塞がれない。forked/background agent への再委任指示を書く前にスキルが持つ規約（例:「Anki書込等の不可逆操作はpeer合意だけで実行禁止」のような自己判断禁止条項）を確認したい場合は、Skillでの模倣実行を試みず対象ファイルを直接Readする（実例: creating-flashcardsスキルが Skill ツール経由の呼び出しを拒否した直後、Read でINSTRUCTIONS.mdを読み、直前に自分が出した再委任指示がスキル自身の禁止規約に抵触していたと判明し撤回した） |

## 並列タチコマでの品質統一

| If X | then Y |
|------|--------|
| 複数並列タチコマで実装パターン統一が必要 | 初回タスクで確立したパターン（CSS・コード断片・命名規則）を後続タチコマへ「テンプレート埋め込み式」プロンプトで配布（独自実装させない） |
| 同一ドメインの独立タスク群（4並列以上） | 各タチコマに同一の品質ゲート（grep検証・整合性確認手順）を埋め込み、報告フォーマットも統一 |
| 並列タチコマが「担当外ファイルに意図しない差分がある」ことを検知した | `git checkout --`等の巻き戻しを機械的に実行させない。ビルドツールの自動生成副作用（xcodebuildの.entitlements書き換え等）と、他の並行タチコマが正当に加えた変更は`git diff`の内容だけでは区別できないことがある（1件実証：C担当がR-1担当の正当な修正を「汚染」と誤認し巻き戻した）。判別できない場合は巻き戻さず本体へ報告させる |

## 外部エージェントへの委譲

| If X | then Y |
|------|--------|
| 別エージェント（codex / Cursor / 他Claude）への作業委譲時 | tachikoma-doc-documentに **自己完結ハンドオーバー文書** 作成委譲（必読ファイル・完了履歴・残作業表・厳守ルール・再利用パターン・品質ゲート・検証コマンド・起動プロンプトを内包） |
| 委譲先が本セッション履歴を持たない | 文書1本で初見作業可能な完全性を担保（外部参照は最小化、コピペ可能なシェルコマンドで検証手順を提供） |

## タチコマへの依頼プロンプト構造

| If X | then Y |
|------|--------|
| タチコマに作業委譲する際 | プロンプトに以下6要素を必ず含める: ①コンテキスト（背景・目的）/②作業ディレクトリ/③必読ファイル/④担当タスク詳細/⑤厳守ルール/⑥完了条件と報告フォーマット |
| 完了報告フォーマット指定 | 「受領タスク・実行結果・成果物・副作用検証・品質チェック・タスク状態」の6項目構造を明示要求（タチコマが自発的に冪等性チェックや副作用検証を実施する習慣が定着）|
| 🔴 ⑥完了条件を書く際（事実上の7要素目） | **報告の「送信手段」まで明記する**: 「`SendMessage` で報告本文を全文送ること。最終出力テキストに置くだけでは本体に届かない」。background teammate の最終テキストは自動転送されないため、これが無いと「返したつもり／何も来ない」の膠着が起きる |
| 🔴 ⑤厳守ルールを書く際 | **「他の Claude Code プロセス・herdr agent を起動しないこと」を必ず入れる**（委譲先が自律的に子エージェントを、しかも本体が指定していない権限フラグ付きで起動した実例がある） |
| 成果物のあるタスクを委譲する際 | 「Write の直後に `ls`/`wc -l` で実在確認してから完了と報告すること」を⑥に追加する（自己申告の「完了」と成果物の実在は別物） |
| 並列タチコマでファイル衝突リスクあり | 各タチコマに **担当ファイルを明示** し、他タチコマ担当ファイルへの編集を禁止（scribe-A/B/C のような所有権分割パターン） |

## ドキュメント先行開発

plannerが `docs/` に計画Markdownを作成（目的・対象ファイル・変更内容・手順・リスク）。並列時はチーム構成・タスクリスト・ファイル所有権・実行ログ・回復手順を追加。

🔴 **Codex レビューは「指摘が無くなるまで」回す**（1〜2回で打ち切らない）。2回目以降の指摘は前回の修正で**新たに露出した**欠陥であり、初版時点では検出不能なもの。実例では7回・12件を要し、後半の回でようやく「許可分岐が一度も通らない設計だった」「`ALTER COLUMN ... DROP DEFAULT` の見逃しで既存 INSERT が全滅する」といった致命的欠陥が出た。あわせて次の2点を計画時に必ず行う。

- **デプロイ・インフラを含む計画では、計画作成の時点で対象リソースの実在を確認する**（`gcloud run services list` 等の読み取り）。**スクリプトに書かれた名前は「存在する証拠」ではない**——参照元プロジェクトの設定を読んだだけでは検出できず、実際に既定ターゲットの Cloud Run service も Artifact Registry repository も存在しなかった実例がある。
- **検証手順を書くときは「その手順が破壊する対象」を点検する**（共有 DB への破壊的 SQL・`compose down` の巻き添え等）。手順自体が事故になる。
**計画がCodexレビューループ完了後・最終化されたら、Markdownに加え同名HTMLも併用生成する**（ユーザー閲覧用・変換は本体が中央処理として実行、READ-ONLY agentの権限体系は変更しない）。詳細: `skills/orchestrating-teams/` の「レビュー資材のHTML併用生成」節参照。
