#!/bin/bash
set -euo pipefail

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty' 2>/dev/null || true)

if [ -z "$cwd" ]; then
  cwd="${CLAUDE_PROJECT_DIR:-$HOME}"
fi

# 1. レガシー: プロジェクトルートの HANDOVER.md を読む
handover="$cwd/HANDOVER.md"
if [ -f "$handover" ]; then
  echo "## HANDOVER.md (前回セッションの引き継ぎ)"
  echo ""
  cat "$handover"
  echo ""
fi

# 2. .claude/handovers/ ディレクトリから最新のhandoverを読む
HANDOVER_DIR="$cwd/.claude/handovers"
if [ -d "$HANDOVER_DIR" ]; then
  # ファイル名でソートして最新を取得（YYYY-MM-DD_HHmm.md形式なのでソートで最新がわかる）
  LATEST=$(find "$HANDOVER_DIR" -maxdepth 1 -type f -name '*.md' 2>/dev/null | sort | tail -1)
  if [ -n "$LATEST" ] && [ -f "$LATEST" ]; then
    echo "## 最新セッション引き継ぎノート ($(basename "$LATEST"))"
    echo ""
    cat "$LATEST"
  fi
fi

exit 0
