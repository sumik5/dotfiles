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

# 作業ディレクトリからgitデータを収集
GIT_LOG=""
GIT_DIFF_STAT=""
if [ -n "$CWD" ] && [ -d "$CWD" ]; then
    GIT_LOG=$(cd "$CWD" && git log --since="today" --oneline --no-decorate 2>/dev/null || true)
    GIT_DIFF_STAT=$(cd "$CWD" && git diff --stat 2>/dev/null || true)
fi

# トランスクリプト（JSONL形式）から編集ファイル一覧を抽出
FILES_TOUCHED=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    if command -v jq &>/dev/null; then
        FILES_TOUCHED=$(cat "$TRANSCRIPT_PATH" 2>/dev/null | \
            jq -r 'select(.type == "tool_use") |
            select(.name == "Edit" or .name == "Write") |
            .input.file_path // empty' 2>/dev/null | \
            sort -u | head -30 || true)
    fi
fi

# セッションエントリブロックを構築
SESSION_BLOCK="
---
### セッション ${NOW} (${CWD:-unknown})

**Git commits (today):**
\`\`\`
${GIT_LOG:-（コミットなし）}
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
    TMPFILE=$(mktemp)
    awk -v block="$SESSION_BLOCK" '
        /^## 🧠/ { print block; print "" }
        { print }
    ' "$FILEPATH" > "$TMPFILE"
    mv "$TMPFILE" "$FILEPATH"
fi

exit 0
