# glogs 修正指示書 — hunk 連携の追加

> この文書だけで作業が完結するよう自己完結で書いてある。別ターミナル（クリーンな Claude Code セッション or 手作業）で実施すること。

## 背景・目的
`/Users/sumik/dotfiles/bin/glogs`（署名検証付き git log ラッパー・bash・**原本279行**）を改修し、fzf でコミットを選んで **Enter で確定した瞬間に、そのコミットを `hunk`（review-first な TUI diff ビューア。https://github.com/modem-dev/hunk）で全画面表示**する。hunk 未導入環境では従来の `git show` にフォールバックする。

## 前提
- `hunk` 導入済み（`hunk show <sha>` でコミット単体 diff を全画面レビュー）。
- 現在 glogs は **原本279行（未改修・クリーン）**。
- fzf の右ペイン `git show` プレビューは**維持**する（一覧→速覧→精読の3段）。
- fzf の `become` は使わない（「fzf 終了後に選択行を受けて後処理」方式。一時ヘルパーの `rm` を確実に走らせるため）。

## 修正は4箇所

---

### 修正1: 冒頭コメント（概要）に hunk 連携を追記

**変更前**（原本 8〜10行目付近）:
```bash
#   デフォルトでは fzf による対話モードで起動し、コミットを選ぶと
#   右側に詳細(git show)が表示される。
#   fzf が無い、または端末(TTY)でない場合は、自動でページャ(less)による
```

**変更後**:
```bash
#   デフォルトでは fzf による対話モードで起動し、コミットを選ぶと
#   右側に詳細(git show)がプレビュー表示される。
#   Enter で確定すると、選んだコミットを hunk(review-first な TUI diff
#   ビューア。https://github.com/modem-dev/hunk)で全画面表示する。
#   hunk が無い環境では従来どおり git show にフォールバックする。
#   fzf が無い、または端末(TTY)でない場合は、自動でページャ(less)による
```

---

### 修正2: usage の Enter 行

**変更前**（原本 82行目・usage ヒアドキュメント内、fzf キー操作セクション）:
```
  Enter                選択して終了
```

**変更後**:
```
  Enter                選択したコミットを hunk(無ければ git show)で全画面表示
```

---

### 修正3: `show_commit()` 関数を新設

**挿入位置**: `decorate()` 関数の閉じ `}`（原本169行目）と、`# --- git log を実行する共通関数 ---`（原本171行目）の**間**。つまり decorate() の直後、run_git_log() の直前。

**挿入するコード**（前後に空行を1つずつ）:
```bash
# --- 選択したコミットを詳細表示する関数 ----------------------------------
# fzf で選ばれた1行(ANSI色付き)からコミットハッシュを取り出し、hunk
# (review-first な TUI diff ビューア)があれば hunk show で全画面表示する。
# hunk が無ければ従来どおり git show(色付き)にフォールバックする。
#   1) sed で ANSI 色コードを除去
#   2) grep でコミットハッシュ(7桁以上の16進)を1つ取り出す
#      ※ ANSI コードは短く [0-9a-f]{7,} にはマッチしないので抽出は安全
#   3) hash が取れたら hunk show / git show で表示
show_commit() {
  # $1: fzf が返した選択行。未選択(Esc)なら空文字。
  line="$1"
  [ -n "$line" ] || return 0
  hash=$(printf '%s' "$line" | sed 's/\x1b\[[0-9;]*m//g' | grep -oE '[0-9a-f]{7,}' | head -1)
  [ -n "$hash" ] || return 0
  if command -v hunk >/dev/null 2>&1; then
    # hunk 0.16+: 指定コミットを全画面の対話レビューで開く
    hunk show "$hash"
  else
    # hunk が無い環境: 従来の git show を less(色付き)で表示する
    if command -v less >/dev/null 2>&1; then
      git show --color=always "$hash" | less -R
    else
      git show --color=always "$hash"
    fi
  fi
}
```

---

### 修正4: 対話モードの fzf 呼び出しを `SELECTED_LINE` 化 ＋ `show_commit` 呼び出し

**変更前**（原本 251〜262行目）:
```bash
  run_git_log | decorate | fzf \
    --ansi \
    --no-sort \
    --layout=reverse \
    --preview "sh '$PREVIEW_HELPER' {}" \
    --preview-window=right:60% \
    --bind 'ctrl-j:down,ctrl-k:up' \
    --bind 'ctrl-f:preview-half-page-down,ctrl-b:preview-half-page-up' \
    --bind 'ctrl-/:toggle-preview' || true

  # fzf が終了したのでヘルパーを削除する。
  rm -f "$PREVIEW_HELPER"
```

**変更後**（`fzf \` を `SELECTED_LINE="$(...fzf \` に変え、最終行の `|| true` を閉じ括弧の外へ。rm の後に show_commit 呼び出しを追加）:
```bash
  SELECTED_LINE="$(run_git_log | decorate | fzf \
    --ansi \
    --no-sort \
    --layout=reverse \
    --preview "sh '$PREVIEW_HELPER' {}" \
    --preview-window=right:60% \
    --bind 'ctrl-j:down,ctrl-k:up' \
    --bind 'ctrl-f:preview-half-page-down,ctrl-b:preview-half-page-up' \
    --bind 'ctrl-/:toggle-preview')" || true

  # fzf が終了したのでヘルパーを削除する。
  rm -f "$PREVIEW_HELPER"

  # 選んだコミットを hunk(無ければ git show)で全画面表示する。
  # 未選択(Esc)の場合は SELECTED_LINE が空なので show_commit は何もしない。
  show_commit "${SELECTED_LINE:-}"
```

**注意**: `set -u` 下なので参照は必ず `"${SELECTED_LINE:-}"`。`$(...)` の末尾が fzf なので、Esc キャンセル時の非0終了は `|| true` で吸収される（`show_commit` 側も空入力で `return 0` する二重防御）。

---

## 完成後の検証

```bash
# 1) 構文チェック
bash -n ~/dotfiles/bin/glogs && echo SYNTAX_OK

# 2) 実装痕跡の確認（期待: show_commit=2, SELECTED_LINE=2, hunk show=1〜2）
grep -cE 'show_commit|SELECTED_LINE|hunk show' ~/dotfiles/bin/glogs

# 3) 非対話パスの回帰（scroll モードがログ一覧を出す・エラーにならない）
bash ~/dotfiles/bin/glogs -s -3 | cat

# 4) 対話動作（手動）: リポジトリ内で `glogs` を実行 → コミットを選び Enter
#    → hunk が全画面で開けば成功。右ペインの git show プレビューは従来どおり。
```

## セキュリティ確認ポイント
- `$hash` は `grep -oE '[0-9a-f]{7,}'` で**16進のみ抽出**済み。コマンドインジェクション面は安全。この正規表現は必ず維持すること。

## コミット方針（合意済み・git 書込はユーザー承認後）
関心事の異なる変更は**別コミットに分ける**:
1. `bin/glogs` → `feat(glogs): 選択コミットを hunk で全画面表示（未導入時は git show）`
2. `claude-code/RTK.md` → `fix(claude): @RTK.md 参照をシンボリックリンクで解決`
- `.gitignore` の modified は本タスク無関係の別件。混ぜないこと。
- Conventional Commits 形式。新規作業なら `feature/glogs-hunk` ブランチを切ってもよい。
