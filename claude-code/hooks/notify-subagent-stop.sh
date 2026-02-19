#!/bin/bash
set -euo pipefail

# stdinからSubagentStop hookデータを読み込む
HOOK_JSON=$(cat)

# JSONパース（jq優先、python3フォールバック）
if command -v jq &>/dev/null; then
    AGENT_TYPE=$(echo "$HOOK_JSON" | jq -r '.agent_type // ""')
    LAST_MESSAGE=$(echo "$HOOK_JSON" | jq -r '.last_assistant_message // ""')
else
    AGENT_TYPE=$(echo "$HOOK_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('agent_type', ''))" 2>/dev/null || echo "")
    LAST_MESSAGE=$(echo "$HOOK_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('last_assistant_message', ''))" 2>/dev/null || echo "")
fi

# last_assistant_message の先頭の非空行を取得し、100文字に切り詰め
if [ -n "$LAST_MESSAGE" ]; then
    FIRST_LINE=$(echo "$LAST_MESSAGE" | grep -m1 -v '^[[:space:]]*$' || true)
    if [ -n "$FIRST_LINE" ]; then
        BODY="${FIRST_LINE:0:100}"
    else
        BODY="完了"
    fi
else
    BODY="完了"
fi

# サニタイズ関数（ダブルクォート・バックスラッシュ・改行を除去）
sanitize() {
    echo "$1" | tr -d '"\\' | tr '\n\r' ' '
}

# 通知設定
ICON_BASE="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources"
TITLE_SAFE=$(sanitize "Claude Code")
SUBTITLE_SAFE=$(sanitize "$AGENT_TYPE")
MESSAGE_SAFE=$(sanitize "$BODY")
SOUND="Pop"
ICON="${ICON_BASE}/ToolbarAdvanced.icns"
GROUP="claude-code-subagent"

# terminal-notifier（優先）
if command -v terminal-notifier &>/dev/null; then
    terminal-notifier \
        -title "$TITLE_SAFE" \
        -subtitle "$SUBTITLE_SAFE" \
        -message "$MESSAGE_SAFE" \
        -sound "$SOUND" \
        -contentImage "$ICON" \
        -group "$GROUP"
else
    # osascriptフォールバック
    osascript <<EOF 2>/dev/null || true
display notification "${MESSAGE_SAFE}" \
    with title "${TITLE_SAFE}" \
    subtitle "${SUBTITLE_SAFE}" \
    sound name "${SOUND}"
EOF
fi

echo "通知完了: ${AGENT_TYPE}"
