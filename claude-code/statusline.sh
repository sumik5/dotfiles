#!/bin/bash

set -euo pipefail

command -v jq &>/dev/null || { echo "Missing: jq"; exit 1; }

# ─── Config ───

CCUSAGE_CACHE="/tmp/ccusage-cache.json"
CCUSAGE_TTL=300  # 5 minutes
TOKEN_LIMIT=43000000

# ─── Parse Claude input (single jq call) ───

claude_input=$(cat)
IFS='|' read -r session_name model_name cwd cost ctx_remaining <<< \
  "$(echo "$claude_input" | jq -r '[
    (.session_name // .session_id // ""),
    (.model.display_name // ""),
    (.cwd // ""),
    (.cost.total_cost_usd // 0 | tostring),
    (.context_window.remaining_percentage // 0 | tostring)
  ] | join("|")')"

cwd_str="${cwd/#$HOME/~}"

# ─── Rate limit remaining (non-blocking ccusage) ───

session_str_rate=""
if command -v ccusage &>/dev/null; then
  cache_age_ok=false
  if [ -f "$CCUSAGE_CACHE" ]; then
    now=$(date +%s)
    mtime=$(stat -c "%Y" "$CCUSAGE_CACHE" 2>/dev/null) && [ -n "$mtime" ] \
      || mtime=$(stat -f "%m" "$CCUSAGE_CACHE" 2>/dev/null) || mtime=0
    [ $((now - mtime)) -lt "$CCUSAGE_TTL" ] && cache_age_ok=true
  fi

  if [ -f "$CCUSAGE_CACHE" ]; then
    IFS='|' read -r total_tokens remaining_minutes <<< \
      "$(jq -r '([.blocks[] | select(.isActive == true)][0] // null) | if . == null then "|" else [(.totalTokens // 0 | tostring), (.projection.remainingMinutes // "" | tostring)] | join("|") end' "$CCUSAGE_CACHE" 2>/dev/null || echo "|")"

    if [ -n "$total_tokens" ] && [ "$total_tokens" != "0" ] && [ "$total_tokens" != "null" ]; then
      # Calculate remaining percentage: (1 - totalTokens/TOKEN_LIMIT) * 100
      remaining_pct=$(awk "BEGIN { printf \"%.1f\", (1 - $total_tokens / $TOKEN_LIMIT) * 100 }")
      rate_int=${remaining_pct%%.*}

      # Color indicator based on rate limit remaining
      if [ "$rate_int" -le 20 ]; then rate_ind="🔴"
      elif [ "$rate_int" -le 40 ]; then rate_ind="🟠"
      elif [ "$rate_int" -le 60 ]; then rate_ind="🟡"
      else rate_ind="🟢"
      fi

      rate_time=""
      if [ -n "$remaining_minutes" ] && [ "$remaining_minutes" != "null" ]; then
        int_min=${remaining_minutes%%.*}
        h=$((int_min / 60))
        m=$((int_min % 60))
        rate_time=$(printf "(%dh %dm left)" "$h" "$m")
      fi

      session_str_rate="${rate_ind} 残${remaining_pct}%${rate_time}"
    fi
  fi

  # Background refresh if cache missing or expired (never blocks)
  if ! $cache_age_ok; then
    (ccusage blocks --active --offline --json > "${CCUSAGE_CACHE}.tmp" 2>/dev/null \
      && mv "${CCUSAGE_CACHE}.tmp" "$CCUSAGE_CACHE") & disown 2>/dev/null
  fi
fi

# ─── Context window indicator ───

ctx_int=${ctx_remaining%%.*}
if [ "$ctx_int" -le 20 ]; then ctx_ind="🔴"
elif [ "$ctx_int" -le 40 ]; then ctx_ind="🟠"
elif [ "$ctx_int" -le 60 ]; then ctx_ind="🟡"
else ctx_ind="🟢"
fi
ctx_str="${ctx_ind} CTX残${ctx_remaining}%"

# ─── Output ───

# Session name: only show if still a UUID (reminder to rename)
session_str=""
if [[ "$session_name" =~ ^[0-9a-f]{8}-[0-9a-f]{4}- ]]; then
  session_str="📋 ${session_name:0:8}… │ "
fi

if [ "${CLAUDE_CODE_USE_BEDROCK:-0}" != "0" ]; then
  printf "%s🤖 %s │ %s │ 📂 %s" \
    "$session_str" "$model_name" "$ctx_str" "$cwd_str"
else
  # Build rate limit segment (only for non-Bedrock)
  rate_segment=""
  [ -n "$session_str_rate" ] && rate_segment=" │ $session_str_rate"

  printf "%s🤖 %s │ 💵 \$%.2f%s │ %s │ 📂 %s" \
    "$session_str" "$model_name" "$cost" "$rate_segment" "$ctx_str" "$cwd_str"
fi
