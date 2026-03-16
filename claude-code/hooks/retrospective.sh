#!/bin/bash
# hooks/retrospective.sh
# SessionEnd hook: セッション終了時にgitデータを自動収集してデイリーレトロスペクティブに追記

set -euo pipefail

# stdinからhook入力を読み込む
INPUT=$(cat)

# JSONパース（jq優先、python3フォールバック）
if command -v jq &>/dev/null; then
    TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
    CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
else
    TRANSCRIPT_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('transcript_path', ''))" 2>/dev/null || true)
    CWD=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd', ''))" 2>/dev/null || true)
    SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('session_id', ''))" 2>/dev/null || true)
fi

TODAY=$(date +%Y-%m-%d)
NOW=$(date +%H:%M)

# 保存先ディレクトリを決定
SAVE_DIR="/Users/sumik/Dropbox/claude-code/retrospective"
if [ ! -d "/Users/sumik/Dropbox/claude-code" ]; then
    SAVE_DIR="$HOME/.claude/retrospective"
fi
mkdir -p "$SAVE_DIR"

FILEPATH="${SAVE_DIR}/retrospective_${TODAY}.md"

# 作業ディレクトリからVCSデータを収集
VCS_LOG=""
DIFF_STAT=""
if [ -n "$CWD" ] && [ -d "$CWD" ]; then
    VCS_LOG=$(cd "$CWD" && git log --since="today" --oneline --no-decorate 2>/dev/null || true)
    DIFF_STAT=$(cd "$CWD" && git diff --stat 2>/dev/null || true)
fi

# トランスクリプト（JSONL形式）から編集ファイル一覧を抽出
FILES_TOUCHED=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    if command -v jq &>/dev/null; then
        FILES_TOUCHED=$(cat "$TRANSCRIPT_PATH" 2>/dev/null | \
            jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "tool_use") | select(.name == "Edit" or .name == "Write") | .input.file_path // empty' 2>/dev/null | \
            sort -u | head -30 || true)
    fi
fi

# セッションエントリブロックを構築
SESSION_BLOCK="
---
### セッション ${NOW} (${CWD:-unknown})

**VCS commits (today):**
\`\`\`
${VCS_LOG:-（コミットなし）}
\`\`\`

**変更統計:**
\`\`\`
${DIFF_STAT:-（差分なし）}
\`\`\`

**変更ファイル:**
${FILES_TOUCHED:-（データなし）}
"

# ファイルが存在しない場合は新規作成、存在する場合は追記
if [ ! -f "$FILEPATH" ]; then
    cat > "$FILEPATH" << EOF
# 🔄 Daily Retrospective - ${TODAY}

## 📋 作業実績
${SESSION_BLOCK}

## 🧠 技術的な学び
<!-- /retrospective コマンドで追記 -->

## ⚠️ 詰まったポイント
<!-- /retrospective コマンドで追記 -->

## 🔮 翌日への引き継ぎ
<!-- /retrospective コマンドで追記 -->

## 💡 改善アイデア
<!-- /retrospective コマンドで追記 -->
EOF
else
    # 作業実績セクション（🧠セクションの直前）にセッションデータを挿入
    # NOTE: awk -v は改行を含む文字列を扱えないため head/tail で分割挿入
    TMPFILE=$(mktemp)
    LINE_NUM=$(grep -n "^## 🧠" "$FILEPATH" | head -1 | cut -d: -f1)
    if [ -n "$LINE_NUM" ]; then
        head -n $((LINE_NUM - 1)) "$FILEPATH" > "$TMPFILE"
        printf '%s\n\n' "$SESSION_BLOCK" >> "$TMPFILE"
        tail -n +"$LINE_NUM" "$FILEPATH" >> "$TMPFILE"
        mv "$TMPFILE" "$FILEPATH"
    else
        printf '%s\n' "$SESSION_BLOCK" >> "$FILEPATH"
        rm -f "$TMPFILE"
    fi
fi

exit 0
