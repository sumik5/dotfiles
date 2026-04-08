#!/bin/bash
set -euo pipefail

# stdinからStop hookデータを読み込む
HOOK_JSON=$(cat)

# JSONパース（jq優先、python3フォールバック）
if command -v jq &>/dev/null; then
    STOP_HOOK_ACTIVE=$(echo "$HOOK_JSON" | jq -r '.stop_hook_active // false')
    LAST_MESSAGE=$(echo "$HOOK_JSON" | jq -r '.last_assistant_message // ""')
else
    STOP_HOOK_ACTIVE=$(echo "$HOOK_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('stop_hook_active', False))" 2>/dev/null || echo "False")
    LAST_MESSAGE=$(echo "$HOOK_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('last_assistant_message', ''))" 2>/dev/null || echo "")
fi

# stop_hook_active が true の場合はスキップ（無限ループ防止）
if [ "$STOP_HOOK_ACTIVE" = "true" ] || [ "$STOP_HOOK_ACTIVE" = "True" ]; then
    exit 0
fi

# プロジェクト名
PROJECT_NAME=$(basename "$PWD")

# last_assistant_message の先頭の非空行を取得し、100文字に切り詰め
if [ -n "$LAST_MESSAGE" ]; then
    FIRST_LINE=$(echo "$LAST_MESSAGE" | grep -m1 -v '^[[:space:]]*$' || true)
    if [ -n "$FIRST_LINE" ]; then
        BODY="${FIRST_LINE:0:100}"
    else
        BODY="作業完了"
    fi
else
    BODY="作業完了"
fi

# サニタイズ関数（ダブルクォート・バックスラッシュ・改行を除去）
sanitize() {
    echo "$1" | tr -d '"\\' | tr '\n\r' ' '
}

# 通知設定
ICON_BASE="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources"
TITLE_SAFE=$(sanitize "Claude Code")
SUBTITLE_SAFE=$(sanitize "$PROJECT_NAME")
MESSAGE_SAFE=$(sanitize "$BODY")
SOUND="Glass"
ICON="${ICON_BASE}/ToolbarInfo.icns"
GROUP="claude-code-stop"

# terminal-notifier（優先）
if command -v terminal-notifier &>/dev/null; then
    terminal-notifier \
        -title "$TITLE_SAFE" \
        -subtitle "$SUBTITLE_SAFE" \
        -message "$MESSAGE_SAFE" \
        -sound "$SOUND" \
        -contentImage "$ICON" \
        -group "$GROUP" \
    || osascript <<EOF 2>/dev/null || true
display notification "${MESSAGE_SAFE}" \
    with title "${TITLE_SAFE}" \
    subtitle "${SUBTITLE_SAFE}" \
    sound name "${SOUND}"
EOF
else
    # osascriptフォールバック
    osascript <<EOF 2>/dev/null || true
display notification "${MESSAGE_SAFE}" \
    with title "${TITLE_SAFE}" \
    subtitle "${SUBTITLE_SAFE}" \
    sound name "${SOUND}"
EOF
fi

echo "通知完了: ${PROJECT_NAME}"
