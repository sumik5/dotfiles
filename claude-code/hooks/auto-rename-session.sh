#!/bin/bash
# hooks/auto-rename-session.sh
# UserPromptSubmit hook: セッション内容を分析してセッション名を自動命名

set -euo pipefail

INPUT=$(cat)

# JSONパース（jq優先、python3フォールバック）
if command -v jq &>/dev/null; then
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
    TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
    CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
else
    SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('session_id', ''))" 2>/dev/null || true)
    TRANSCRIPT_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('transcript_path', ''))" 2>/dev/null || true)
    CWD=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd', ''))" 2>/dev/null || true)
fi

# 早期終了チェック
if [ -z "$SESSION_ID" ] || [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
    exit 0
fi

# sessions-index.json の場所を特定
PROJECT_DIR=$(dirname "$TRANSCRIPT_PATH")
SESSIONS_INDEX="${PROJECT_DIR}/sessions-index.json"
if [ ! -f "$SESSIONS_INDEX" ]; then
    exit 0
fi

# クールダウンチェック（10分以内に命名済みならスキップ）
MARKER_FILE="/tmp/claude-rename-${SESSION_ID}"
if [ -f "$MARKER_FILE" ]; then
    MARKER_AGE=$(( $(date +%s) - $(stat -f %m "$MARKER_FILE" 2>/dev/null || stat -c %Y "$MARKER_FILE" 2>/dev/null || echo 0) ))
    if [ "$MARKER_AGE" -lt 600 ]; then
        exit 0
    fi
fi

# sessions-index.json から messageCount、firstPrompt、現在の summary を取得
# ユーザーメッセージ数が3未満ならスキップ（十分なコンテキストがない）
SESSION_DATA=$(export SESSIONS_INDEX SESSION_ID; python3 << 'PYEOF' || true
import json, os, sys

sessions_index = os.environ.get('SESSIONS_INDEX', '')
session_id = os.environ.get('SESSION_ID', '')

try:
    with open(sessions_index, 'r') as f:
        data = json.load(f)
    for e in data.get('entries', []):
        if e.get('sessionId') == session_id:
            msg_count = e.get('messageCount', 0)
            first_prompt = e.get('firstPrompt', '')
            summary = e.get('summary', '')
            # TAB区切りで出力（改行を含む可能性があるためfirstPromptは1行目のみ）
            first_prompt_oneline = first_prompt.replace('\n', ' ').replace('\t', ' ')[:200]
            print(f"{msg_count}\t{first_prompt_oneline}\t{summary}")
            sys.exit(0)
    # セッションが見つからない場合
    print("0\t\t")
except Exception:
    print("0\t\t")
PYEOF
)

# TAB区切りで分割
USER_MSG_COUNT=$(echo "$SESSION_DATA" | cut -f1)
FIRST_PROMPT=$(echo "$SESSION_DATA" | cut -f2)
CURRENT_SUMMARY=$(echo "$SESSION_DATA" | cut -f3)

# メッセージ数が3未満ならスキップ
if [ "${USER_MSG_COUNT:-0}" -lt 3 ]; then
    exit 0
fi

# git logから今日のコミットメッセージを取得
GIT_MSGS=""
if [ -n "$CWD" ] && [ -d "$CWD" ]; then
    GIT_MSGS=$(cd "$CWD" && git log --since="today" --oneline --no-decorate 2>/dev/null | head -5 || true)
fi

# === 命名ロジック ===
# 1. プレフィックスを決定
PREFIX="chore"
if echo "$FIRST_PROMPT $GIT_MSGS" | grep -qi "fix\|bug\|error\|修正\|バグ\|不具合"; then
    PREFIX="bugfix"
elif echo "$FIRST_PROMPT $GIT_MSGS" | grep -qi "refactor\|リファクタ\|整理\|簡素化\|移行"; then
    PREFIX="refactor"
elif echo "$FIRST_PROMPT $GIT_MSGS" | grep -qi "doc\|ドキュメント\|README\|説明"; then
    PREFIX="docs"
elif echo "$FIRST_PROMPT $GIT_MSGS" | grep -qi "test\|テスト\|spec"; then
    PREFIX="test"
elif echo "$FIRST_PROMPT $GIT_MSGS" | grep -qi "add\|create\|new\|implement\|feat\|追加\|作成\|新規\|実装\|機能"; then
    PREFIX="feature"
fi

# 2. サフィックスを生成（firstPromptから抽出）
SUFFIX=$(echo "$FIRST_PROMPT" | \
    tr -cs 'a-zA-Z0-9' '-' | \
    tr '[:upper:]' '[:lower:]' | \
    cut -c1-30 | sed 's/^-//;s/-$//')

# 3. 最終的なセッション名を構築
NEW_NAME="${PREFIX}-${SUFFIX:-session}"
# 最大50文字に制限、末尾ハイフン除去
NEW_NAME=$(echo "$NEW_NAME" | cut -c1-50 | sed 's/-$//')

# 同じ名前なら何もしない
if [ "$CURRENT_SUMMARY" = "$NEW_NAME" ]; then
    exit 0
fi

# sessions-index.json を更新（アトミックに）
export SESSIONS_INDEX SESSION_ID NEW_NAME
python3 << 'PYEOF' || true
import json, os, tempfile

sessions_index = os.environ.get('SESSIONS_INDEX', '')
session_id = os.environ.get('SESSION_ID', '')
new_name = os.environ.get('NEW_NAME', '')

if not sessions_index or not session_id or not new_name:
    exit(0)

try:
    with open(sessions_index, 'r') as f:
        data = json.load(f)
    updated = False
    for e in data.get('entries', []):
        if e.get('sessionId') == session_id:
            e['summary'] = new_name
            updated = True
            break

    if updated:
        # アトミック書き込み（tmpファイル→リネーム）
        dir_name = os.path.dirname(sessions_index)
        fd, tmp_path = tempfile.mkstemp(dir=dir_name, suffix='.json')
        try:
            with os.fdopen(fd, 'w') as f:
                json.dump(data, f, ensure_ascii=False)
            os.rename(tmp_path, sessions_index)
        except Exception:
            # tmpファイルのクリーンアップ
            try:
                os.unlink(tmp_path)
            except Exception:
                pass
except Exception:
    pass
PYEOF

# マーカーファイルを更新
echo "$NEW_NAME" > "$MARKER_FILE"

# 画面にリネーム結果を表示（systemMessage）+ コンテキスト注入
cat << EOF
{"systemMessage": "🏷️ Session: ${NEW_NAME}", "hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": "セッション名が自動更新されました: ${NEW_NAME}"}}
EOF

exit 0
