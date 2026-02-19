#!/bin/bash
set -euo pipefail

# stdinからTeammateIdle hookデータを読み込む
HOOK_JSON=$(cat)

# JSONパース（jq優先、python3フォールバック）
if command -v jq &>/dev/null; then
    TEAMMATE_NAME=$(echo "$HOOK_JSON" | jq -r '.teammate_name // ""')
    TEAM_NAME=$(echo "$HOOK_JSON" | jq -r '.team_name // ""')
else
    TEAMMATE_NAME=$(echo "$HOOK_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('teammate_name', ''))" 2>/dev/null || echo "")
    TEAM_NAME=$(echo "$HOOK_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('team_name', ''))" 2>/dev/null || echo "")
fi

# サニタイズ関数（ダブルクォート・バックスラッシュ・改行を除去）
sanitize() {
    echo "$1" | tr -d '"\\' | tr '\n\r' ' '
}

# 通知設定
ICON_BASE="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources"
TITLE_SAFE=$(sanitize "Claude Code")
SUBTITLE_SAFE=$(sanitize "$TEAM_NAME")
MESSAGE_SAFE=$(sanitize "${TEAMMATE_NAME} が待機中")
SOUND="Tink"
ICON="${ICON_BASE}/GroupIcon.icns"
GROUP="claude-code-teammate"

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

echo "通知完了: ${TEAMMATE_NAME} (${TEAM_NAME})"
