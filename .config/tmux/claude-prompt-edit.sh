#!/usr/bin/env bash
#
# claude-prompt-edit.sh - Neovim/vi エディタで Claude Code 入力を編集
#
# 概要:
#   エディタで書いたテキストを呼び出し元の tmux pane にペーストする。
#   nvim がなければ vi にフォールバック。
#
# 動作モード:
#   1. tmux keybinding（通常 tmux）
#      → display-popup でオーバーレイエディタを開く
#   2. iTerm2 coprocess（tmux -CC モード）
#      → -CC では display-popup が使えないため split-window で下部にエディタを開く
#      → coprocess 環境では tmux バイナリとソケットを明示指定して接続
#
# セットアップ:
#   ── 通常 tmux の場合 ──
#   .tmux.conf に追加（TPM より前に記述）:
#     bind-key -n C-e run-shell "bash ~/.config/tmux/claude-prompt-edit.sh '#{pane_id}'"
#
#   ── iTerm2 + tmux -CC の場合 ──
#   -CC モードでは tmux keybinding が発火しないため iTerm2 側で設定:
#     iTerm2 → Settings → Profiles → Keys → Key Mappings
#     Shortcut: Ctrl+E  /  Action: Run Coprocess
#     Command:  bash ~/.config/tmux/claude-prompt-edit.sh
#
# 注意:
#   - macOS では M-e (Alt+E) は dead key として OS に消費されるため使用不可
#   - split-window / coprocess は最小限の PATH で起動されるため
#     nvim, tmux 等は絶対パスのフォールバック検索を行う

# stderr をログに退避（coprocess 経由のエラーダイアログ防止）
LOGFILE="/tmp/claude-prompt-debug.log"
exec 2>>"$LOGFILE"

# ── ユーティリティ ─────────────────────────────────

# コマンドを PATH → 既知パスの順で探す
find_cmd() {
  local cmd="$1"; shift
  local found
  found="$(command -v "$cmd" 2>/dev/null)"
  if [ -n "$found" ] && [ -x "$found" ]; then
    echo "$found"; return
  fi
  for p in "$@"; do
    [ -x "$p" ] && echo "$p" && return
  done
}

# tmux 接続: $TMUX があれば直接、なければソケット明示指定
run_tmux() {
  if [ -n "$TMUX" ]; then
    "$TMUX_CMD" "$@"
  else
    "$TMUX_CMD" -S "/tmp/tmux-$(id -u)/default" "$@"
  fi
}

# ── エディタモード（split-window 内で呼ばれる） ────

if [ "$1" = "--editor" ]; then
  TMPFILE="$2"
  TARGET_PANE="$3"

  NVIM_CMD="$(find_cmd nvim /opt/homebrew/bin/nvim /usr/local/bin/nvim /usr/bin/nvim)"
  EDITOR_CMD="${NVIM_CMD:-$(find_cmd vi /usr/bin/vi)}"
  TMUX_CMD="$(find_cmd tmux /opt/homebrew/bin/tmux /usr/local/bin/tmux /usr/bin/tmux)"

  "$EDITOR_CMD" "$TMPFILE"

  if [ -s "$TMPFILE" ]; then
    "$TMUX_CMD" set-buffer -b claude_prompt -- "$(cat "$TMPFILE")"
    "$TMUX_CMD" paste-buffer -b claude_prompt -t "$TARGET_PANE"
  fi

  rm -f "$TMPFILE"
  exit 0
fi

# ── ランチャーモード ───────────────────────────────

TMUX_CMD="$(find_cmd tmux /opt/homebrew/bin/tmux /usr/local/bin/tmux /usr/bin/tmux)"
[ -z "$TMUX_CMD" ] && exit 1

run_tmux has-session 2>/dev/null || exit 1

# ターゲットペインの決定
TARGET_PANE="${1:-$(run_tmux display-message -p '#{pane_id}' 2>/dev/null)}"
if [ -z "$TARGET_PANE" ]; then
  TARGET_PANE="$(run_tmux list-panes -a \
    -F '#{pane_active} #{pane_id} #{window_active} #{session_attached}' 2>/dev/null \
    | awk '$1==1 && $3==1 && $4==1 {print $2; exit}')"
fi
[ -z "$TARGET_PANE" ] && exit 1

# 一時ファイル作成
TMPFILE="$(mktemp /tmp/claude-prompt-XXXXXX)" || exit 1

# スクリプトの絶対パス（--editor で再帰呼び出し用）
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

# display-popup を試行 → 失敗時は split-window にフォールバック
if [ -n "$TMUX" ] && run_tmux display-popup -E -w 80% -h 70% -T "Claude Prompt" \
    "$SHELL -i -c 'nvim \"$TMPFILE\"'" 2>/dev/null; then
  if [ -s "$TMPFILE" ]; then
    run_tmux set-buffer -b claude_prompt -- "$(cat "$TMPFILE")"
    run_tmux paste-buffer -b claude_prompt -t "$TARGET_PANE"
  fi
  rm -f "$TMPFILE"
else
  run_tmux split-window -t "$TARGET_PANE" -v -l 70% \
    "bash '$SCRIPT_PATH' --editor '$TMPFILE' '$TARGET_PANE'"
fi

exit 0
