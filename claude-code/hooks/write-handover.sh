#!/bin/bash
# hooks/write-handover.sh
# SessionEnd hook: セッション終了時にgitデータ・トランスクリプトからhandoverファイルを自動生成

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
DATETIME="${TODAY} ${NOW}"

# 保存先ディレクトリを決定
# CLAUDE_PROJECT_DIR 環境変数が設定されていればそちらを優先
if [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -d "$CLAUDE_PROJECT_DIR" ]; then
    HANDOVER_DIR="${CLAUDE_PROJECT_DIR}/.claude/handovers"
elif [ -n "$CWD" ] && [ -d "$CWD" ]; then
    HANDOVER_DIR="${CWD}/.claude/handovers"
else
    HANDOVER_DIR="${HOME}/.claude/handovers"
fi
mkdir -p "$HANDOVER_DIR"

# ファイル名を決定（同名ファイルが存在する場合は連番付与）
BASE_NAME="${TODAY}_$(date +%H%M)"
FILEPATH="${HANDOVER_DIR}/${BASE_NAME}.md"
if [ -f "$FILEPATH" ]; then
    COUNTER=2
    while [ -f "${HANDOVER_DIR}/${BASE_NAME}_${COUNTER}.md" ]; do
        COUNTER=$((COUNTER + 1))
    done
    FILEPATH="${HANDOVER_DIR}/${BASE_NAME}_${COUNTER}.md"
fi

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

# 意味あるデータがない場合はファイルを生成しない
if [ -z "$GIT_LOG" ] && [ -z "$FILES_TOUCHED" ]; then
    exit 0
fi

# 「今回のコミット」セクション用にgit logを箇条書きに変換
GIT_LOG_BULLETS=""
if [ -n "$GIT_LOG" ]; then
    while IFS= read -r line; do
        GIT_LOG_BULLETS="${GIT_LOG_BULLETS}- ${line}"$'\n'
    done <<< "$GIT_LOG"
fi

# 「関連ファイル」セクション用に箇条書きに変換
FILES_BULLETS=""
if [ -n "$FILES_TOUCHED" ]; then
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        FILES_BULLETS="${FILES_BULLETS}- ${line}"$'\n'
    done <<< "$FILES_TOUCHED"
fi

# handoverファイルを生成
{
    printf '# セッション引き継ぎノート（自動生成） - %s\n' "${DATETIME}"

    if [ -n "$GIT_LOG_BULLETS" ]; then
        printf '\n## 今回のコミット\n'
        printf '%s' "${GIT_LOG_BULLETS}"
    fi

    if [ -n "$FILES_BULLETS" ]; then
        printf '\n## 関連ファイル\n'
        printf '%s' "${FILES_BULLETS}"
    fi

    printf '\n---\n'
    printf '*このファイルはSessionEnd/PreCompact hookによる自動生成です。詳細な引き継ぎは `/handover` コマンドで生成してください。*\n'
} > "$FILEPATH"

exit 0
