#!/bin/bash
set -euo pipefail

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty')

if [ -z "$cwd" ]; then
  cwd="$CLAUDE_PROJECT_DIR"
fi

handover="$cwd/HANDOVER.md"

if [ -f "$handover" ]; then
  echo "## HANDOVER.md (前回セッションの引き継ぎ)"
  echo ""
  cat "$handover"
fi

exit 0
