#!/usr/bin/env bash

# 呼び出し元 pane の ID（tmux.conf から渡す）
TARGET_PANE="$1"

# 一時ファイルを作成
# 注意: macOS BSD mktemp はサフィックス(.md等)があるとX展開しないため付けない
TMPFILE="$(mktemp /tmp/claude-prompt-XXXXXX)"

# tmux サーバーに接続可能か確認（run-shell 経由だと TMUX 変数が未設定の場合がある）
if ! tmux has-session 2>/dev/null; then
  echo "Error: tmux server is not running." >&2
  exit 1
fi

# popup の中で「いつものシェル環境 + nvim」を起動
# -E: コマンド(nvim)が終わったら popup を閉じる
tmux display-popup -E -w 80% -h 70% -T "Claude Prompt" \
  "$SHELL -i -c 'nvim \"$TMPFILE\"'"

# ==== ここから先は nvim を閉じたあとに実行される ====

# デバッグ：TMPFILE のパスとサイズを tmux ステータスに表示
if [ -f "$TMPFILE" ]; then
  SIZE="$(wc -c < "$TMPFILE" 2>/dev/null || echo 0)"
  tmux display-message "claude-popup: file=$TMPFILE size=${SIZE}B"
else
  tmux display-message "claude-popup: TMPFILE not found: $TMPFILE"
fi

# 一時ファイルに中身があれば貼り付け
if [ -s "$TMPFILE" ]; then
  CONTENT="$(cat "$TMPFILE")"

  # バッファに入れる
  tmux set-buffer -b claude_prompt -- "$CONTENT"

  # ★ 呼び出し元 pane に明示的に貼り付ける ★
  tmux paste-buffer -b claude_prompt -t "$TARGET_PANE"
else
  tmux display-message "claude-popup: TMPFILE is empty, skip paste"
fi

# 後片付け
rm -f "$TMPFILE"

exit 0

