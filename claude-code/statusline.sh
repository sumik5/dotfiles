#!/bin/bash

set -euo pipefail

command -v jq &>/dev/null || { echo "Missing: jq"; exit 1; }

# ─── Config ───

OAUTH_CACHE="/tmp/oauth-usage-cache.json"
OAUTH_TTL=60  # 60 seconds
CCUSAGE_CACHE="/tmp/ccusage-cache.json"
CCUSAGE_TTL=300  # 5 minutes (fallback)
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

# ─── OAuth Usage API ───

# Get access token from macOS Keychain (handles both plain JSON and hex-encoded formats)
_get_access_token() {
  local raw
  raw=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null) || return 1
  [ -z "$raw" ] && return 1

  local json
  if [[ "$raw" == "{"* ]]; then
    # Plain JSON format (post re-login)
    json="$raw"
  else
    # Hex-encoded format (legacy)
    json=$(echo "$raw" | xxd -r -p 2>/dev/null) || return 1
  fi

  echo "$json" \
    | grep -o '"accessToken":"[^"]*"' \
    | head -1 \
    | sed 's/"accessToken":"//;s/"$//'
}

# Fetch OAuth usage and write to cache file
_fetch_oauth_usage() {
  local access_token
  access_token=$(_get_access_token) || return 1
  [ -z "$access_token" ] && return 1

  curl --silent --max-time 5 \
    --header "Authorization: Bearer ${access_token}" \
    --header "anthropic-beta: oauth-2025-04-20" \
    "https://api.anthropic.com/api/oauth/usage" 2>/dev/null
}

# Check if cache is fresh
_oauth_cache_fresh() {
  [ -f "$OAUTH_CACHE" ] || return 1
  local now mtime
  now=$(date +%s)
  mtime=$(stat -f "%m" "$OAUTH_CACHE" 2>/dev/null) \
    || mtime=$(stat -c "%Y" "$OAUTH_CACHE" 2>/dev/null) \
    || return 1
  [ $((now - mtime)) -lt "$OAUTH_TTL" ]
}

# Parse ISO8601 timestamp to epoch seconds (macOS + Linux compatible)
_iso8601_to_epoch() {
  local ts="$1"
  # Remove fractional seconds and Z, then convert
  local normalized
  normalized=$(echo "$ts" | sed 's/\.[0-9]*Z$/Z/; s/Z$/+00:00/')
  date -j -f "%Y-%m-%dT%H:%M:%S%z" "${normalized/+00:00/+0000}" "+%s" 2>/dev/null \
    || date -d "$ts" "+%s" 2>/dev/null \
    || echo ""
}

# Build rate indicator emoji based on remaining percentage
_rate_indicator() {
  local pct_int="$1"
  if [ "$pct_int" -ge 80 ]; then echo "🟢"
  elif [ "$pct_int" -ge 60 ]; then echo "🟡"
  elif [ "$pct_int" -ge 40 ]; then echo "🟠"
  else echo "🔴"
  fi
}

# Build rate limit string from OAuth cache
_build_oauth_rate_str() {
  [ -f "$OAUTH_CACHE" ] || return 1

  local five_util resets_at
  IFS='|' read -r five_util resets_at <<< \
    "$(jq -r '[
      (.five_hour.utilization // ""),
      (.five_hour.resets_at // "")
    ] | join("|")' "$OAUTH_CACHE" 2>/dev/null || echo "|")"

  [ -z "$five_util" ] && return 1

  # Remaining percentage = 100 - utilization
  local remaining_pct
  remaining_pct=$(awk "BEGIN { printf \"%.1f\", 100 - ${five_util} }")
  local remaining_int=${remaining_pct%%.*}
  local rate_ind
  rate_ind=$(_rate_indicator "$remaining_int")

  # Time remaining from resets_at
  local rate_time=""
  if [ -n "$resets_at" ]; then
    local reset_epoch now_epoch diff_sec
    reset_epoch=$(_iso8601_to_epoch "$resets_at")
    now_epoch=$(date +%s)
    if [ -n "$reset_epoch" ] && [ "$reset_epoch" -gt "$now_epoch" ]; then
      diff_sec=$((reset_epoch - now_epoch))
      local h=$((diff_sec / 3600))
      local m=$(((diff_sec % 3600) / 60))
      rate_time=$(printf "(%dh %dm left)" "$h" "$m")
    fi
  fi

  # 7-day segment
  local seven_util seven_str=""
  seven_util=$(jq -r '.seven_day.utilization // ""' "$OAUTH_CACHE" 2>/dev/null || echo "")
  if [ -n "$seven_util" ]; then
    local seven_remaining
    seven_remaining=$(awk "BEGIN { printf \"%.1f\", 100 - ${seven_util} }")
    seven_str=" │ 7d:残${seven_remaining}%"
  fi

  echo "${rate_ind} 残${remaining_pct}%${rate_time}${seven_str}"
}

# ─── Rate limit remaining (OAuth API with ccusage fallback) ───

session_str_rate=""

if [ "${CLAUDE_CODE_USE_BEDROCK:-0}" = "0" ]; then
  # Try OAuth API path
  if _oauth_cache_fresh; then
    # Cache is fresh: use it
    session_str_rate=$(_build_oauth_rate_str 2>/dev/null || echo "")
  else
    # Cache is stale or missing: use existing cache for display, refresh in background
    if [ -f "$OAUTH_CACHE" ]; then
      session_str_rate=$(_build_oauth_rate_str 2>/dev/null || echo "")
    fi
    # Background refresh (non-blocking)
    (
      result=$(_fetch_oauth_usage 2>/dev/null) || exit 0
      # Validate it looks like a usage response
      echo "$result" | jq -e '.five_hour' &>/dev/null || exit 0
      echo "$result" > "${OAUTH_CACHE}.tmp" \
        && mv "${OAUTH_CACHE}.tmp" "$OAUTH_CACHE"
    ) & disown 2>/dev/null
  fi

  # Fallback to ccusage if OAuth produced no output
  if [ -z "$session_str_rate" ] && command -v ccusage &>/dev/null; then
    cache_age_ok=false
    if [ -f "$CCUSAGE_CACHE" ]; then
      now=$(date +%s)
      mtime=$(stat -f "%m" "$CCUSAGE_CACHE" 2>/dev/null) \
        || mtime=$(stat -c "%Y" "$CCUSAGE_CACHE" 2>/dev/null) \
        || mtime=0
      has_data=$(jq -r '.blocks | length > 0' "$CCUSAGE_CACHE" 2>/dev/null || echo "false")
      local_ttl=$CCUSAGE_TTL
      [ "$has_data" = "true" ] || local_ttl=30
      [ $((now - mtime)) -lt "$local_ttl" ] && cache_age_ok=true
    fi

    if [ -f "$CCUSAGE_CACHE" ]; then
      IFS='|' read -r total_tokens remaining_minutes <<< \
        "$(jq -r '([.blocks[] | select(.isActive == true)][0] // null) | if . == null then "|" else [(.totalTokens // 0 | tostring), (.projection.remainingMinutes // "" | tostring)] | join("|") end' "$CCUSAGE_CACHE" 2>/dev/null || echo "|")"

      if [ -n "$total_tokens" ] && [ "$total_tokens" != "0" ] && [ "$total_tokens" != "null" ]; then
        remaining_pct=$(awk "BEGIN { printf \"%.1f\", (1 - $total_tokens / $TOKEN_LIMIT) * 100 }")
        rate_int=${remaining_pct%%.*}
        rate_ind=$(_rate_indicator "$rate_int")

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

    if ! $cache_age_ok; then
      (ccusage blocks --active --offline --json > "${CCUSAGE_CACHE}.tmp" 2>/dev/null \
        && mv "${CCUSAGE_CACHE}.tmp" "$CCUSAGE_CACHE") & disown 2>/dev/null
    fi
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
  rate_segment=""
  [ -n "$session_str_rate" ] && rate_segment=" │ $session_str_rate"

  printf "%s🤖 %s │ 💵 \$%.2f%s │ %s │ 📂 %s" \
    "$session_str" "$model_name" "$cost" "$rate_segment" "$ctx_str" "$cwd_str"
fi
