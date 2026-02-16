#!/bin/bash
set -euo pipefail

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty')
trigger=$(echo "$input" | jq -r '.trigger // "unknown"')
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')

if [ -z "$cwd" ]; then
  cwd="$CLAUDE_PROJECT_DIR"
fi

output_file="$cwd/HANDOVER.md"
timestamp=$(date '+%Y-%m-%d %H:%M')

if [ -f "$output_file" ]; then
  cp "$output_file" "$output_file.bak"
fi

cat > "$output_file" <<EOF
◯ 自動生成メモ

- 生成日時: $timestamp
- トリガー: $trigger
- セッション: $session_id
- このファイルは PreCompact hook により自動生成された
- 詳細な引き継ぎノートは /handover コマンドで生成すること

◯ 注意

- コンテキスト圧縮の直前に生成されたスナップショット
- 次のセッション開始時にこのファイルを確認すること
EOF

exit 0
