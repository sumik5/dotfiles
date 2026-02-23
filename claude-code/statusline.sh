#!/bin/bash

set -euo pipefail

# Environment detection
detect_os() {
  case "$OSTYPE" in
    darwin*)  echo "macos" ;;
    linux*)   echo "linux" ;;
    msys*|mingw*|cygwin*) echo "windows" ;;
    *)        echo "unknown" ;;
  esac
}

OS_TYPE=$(detect_os)

# Cross-platform math calculation
safe_math() {
  local expression=$1

  if command -v bc &> /dev/null; then
    echo "$expression" | bc -l 2>/dev/null || echo "0"
  elif command -v powershell.exe &> /dev/null; then
    powershell.exe -Command "($expression)" 2>/dev/null || echo "0"
  elif command -v awk &> /dev/null; then
    echo "" | awk "BEGIN {print $expression}" 2>/dev/null || echo "0"
  else
    echo "0"
  fi
}

# Cross-platform number formatting
format_number_with_commas() {
  local number=$1

  if command -v numfmt &> /dev/null; then
    numfmt --grouping "$number" 2>/dev/null || echo "$number"
  elif command -v powershell.exe &> /dev/null; then
    powershell.exe -Command "[int]$number | ForEach-Object { '{0:N0}' -f \$_ }" 2>/dev/null || echo "$number"
  elif printf "%'d" "$number" &>/dev/null; then
    printf "%'d" "$number"
  elif command -v sed &> /dev/null; then
    echo "$number" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'
  else
    echo "$number"
  fi
}

# Cross-platform time calculation
calculate_reset_time() {
  local minutes=$1

  case "$OS_TYPE" in
    "macos")
      date -v +"$minutes"M "+%H:%M" 2>/dev/null || echo "N/A"
      ;;
    "linux")
      date -d "+$minutes minutes" "+%H:%M" 2>/dev/null || echo "N/A"
      ;;
    "windows")
      powershell.exe -Command "(Get-Date).AddMinutes($minutes).ToString('HH:mm')" 2>/dev/null || echo "N/A"
      ;;
    *)
      echo "N/A"
      ;;
  esac
}

# Dependency check
check_dependencies() {
  local missing_deps=()

  if ! command -v ccusage &> /dev/null; then
    missing_deps+=("ccusage")
  fi

  if ! command -v jq &> /dev/null; then
    missing_deps+=("jq")
  fi

  if ! command -v bc &> /dev/null && ! command -v powershell.exe &> /dev/null && ! command -v awk &> /dev/null; then
    missing_deps+=("bc or PowerShell or awk")
  fi

  if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "Error: Missing dependencies: ${missing_deps[*]}"
    echo "Please install the required tools for your platform."
    exit 1
  fi
}

# $1: remaining minutes
# Output: formatted remaining time (e.g., "1h 3m left") or "N/A"
format_remaining_time() {
  local minutes=$1
  if [ "$minutes" != "null" ]; then
    local h=$((minutes / 60))
    local m=$((minutes % 60))
    printf "%dh %dm left" "$h" "$m"
  else
    echo "N/A"
  fi
}

# $1: UTC time string
# $2: desired output format (e.g., "%H:%M")
# Output: formatted local time or "N/A"
format_time_local() {
  local utc_time=$1
  local format_str=$2

  if [ "$utc_time" != "null" ] && [ -n "$utc_time" ]; then
    case "$OS_TYPE" in
      "macos")
        date -j -f "%Y-%m-%dT%H:%M:%S" "${utc_time%.*}" "+$format_str" 2>/dev/null || echo "N/A"
        ;;
      "linux")
        date -d "$utc_time" "+$format_str" 2>/dev/null || echo "N/A"
        ;;
      "windows")
        powershell.exe -Command "Get-Date '$utc_time' -Format '$format_str'" 2>/dev/null || echo "N/A"
        ;;
      *)
        echo "N/A"
        ;;
    esac
  else
    echo "N/A"
  fi
}


# Check dependencies first
check_dependencies

# セッション名を取得（マーカーファイル → sessions-index.json → session_id短縮）
get_session_name() {
    local session_id=$1
    local transcript_path=$2

    # 方法1: マーカーファイルから（高速）
    local marker_file="/tmp/claude-rename-${session_id}"
    if [ -f "$marker_file" ]; then
        cat "$marker_file"
        return
    fi

    # 方法2: sessions-index.json から
    if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
        local project_dir
        project_dir=$(dirname "$transcript_path")
        local sessions_index="${project_dir}/sessions-index.json"
        if [ -f "$sessions_index" ]; then
            local name
            name=$(jq -r --arg sid "$session_id" '.entries[] | select(.sessionId == $sid) | .summary // empty' "$sessions_index" 2>/dev/null || true)
            if [ -n "$name" ]; then
                echo "$name"
                return
            fi
        fi
    fi

    # フォールバック: session_id をそのまま全表示
    echo "${session_id}"
}

# Read Claude input from stdin first
claude_input=$(cat)

# セッション名を取得
session_id=$(echo "$claude_input" | jq -r '.session_id // empty')
transcript_path=$(echo "$claude_input" | jq -r '.transcript_path // empty')
session_name=$(get_session_name "$session_id" "$transcript_path")

# キャッシュ設定
CCUSAGE_CACHE_JSON="/tmp/ccusage-cache.json"
CCUSAGE_CACHE_TTL=120  # seconds (active block data)
TOKEN_LIMIT_CACHE="/tmp/ccusage-token-limit"
TOKEN_LIMIT_TTL=3600  # seconds (token limit changes rarely)

# キャッシュ有効性チェック（macOS/Linux対応）
cache_is_valid() {
  local cache_file=$1
  local ttl=$2
  if [ ! -f "$cache_file" ]; then
    return 1
  fi
  local now mtime
  now=$(date +%s)
  mtime=$(stat -c "%Y" "$cache_file" 2>/dev/null || stat -f "%m" "$cache_file" 2>/dev/null || echo 0)
  [ $((now - mtime)) -lt "$ttl" ]
}

# 1. Active block data (fast: --active --offline, TTL=120s)
if cache_is_valid "$CCUSAGE_CACHE_JSON" "$CCUSAGE_CACHE_TTL"; then
  ccusage=$(cat "$CCUSAGE_CACHE_JSON")
else
  ccusage=$(ccusage blocks --active --offline --json 2>/dev/null)
  if [ -n "$ccusage" ]; then
    printf '%s' "$ccusage" > "$CCUSAGE_CACHE_JSON"
  fi
fi

if [ -z "$ccusage" ]; then
  echo "Error: Failed to fetch data from 'ccusage blocks --active --offline --json'."
  echo "Please ensure ccusage is installed and functioning correctly."
  exit 1
fi

# 2. Token limit (slow: full blocks scan, TTL=3600s — limit changes rarely)
if cache_is_valid "$TOKEN_LIMIT_CACHE" "$TOKEN_LIMIT_TTL"; then
  assumed_limit=$(cat "$TOKEN_LIMIT_CACHE")
else
  # バックグラウンドで取得（statusline表示をブロックしない）
  # NOTE: "Using max tokens" メッセージはstdoutに出力される
  (
    set +euo pipefail
    limit=$(ccusage blocks --offline 2>/dev/null | grep -m1 "Using max tokens from previous sessions" | grep -o "[0-9,]*" | tr -d ',')
    if [ -z "$limit" ]; then
      limit=$(ccusage blocks --offline 2>/dev/null | grep -m1 "assuming .* token limit" | grep -o "[0-9,]*" | tr -d ',')
    fi
    if [ -n "$limit" ]; then
      printf '%s' "$limit" > "$TOKEN_LIMIT_CACHE"
    fi
  ) &disown 2>/dev/null
  # キャッシュがあれば古い値を使用、なければnull
  assumed_limit=$(cat "$TOKEN_LIMIT_CACHE" 2>/dev/null || echo "null")
fi
if [ -z "$assumed_limit" ]; then
  assumed_limit="null"
fi


active_block=$(echo "$ccusage" | jq '.blocks[] | select(.isActive == true)')
if [ -z "$active_block" ]; then
  echo "No active usage block found."
  exit 0
fi

# Now Model
model_name=$(echo "$claude_input" | jq -r '.model.display_name')                  # e.g: Sonnet 4

# Information
id=$(echo "$active_block" | jq -r '.id')                                          # e.g: 2025-09-21T00:00:00.000Z
start_time=$(echo "$active_block" | jq -r '.startTime')                           # e.g: 2025-09-21T00:00:00.000Z
end_time=$(echo "$active_block" | jq -r '.endTime')                               # e.g: 2025-09-21T05:00:00.000Z
actual_end_time=$(echo "$active_block" | jq -r '.actualEndTime')                  # e.g: 2025-09-21T03:33:17.285Z
entries=$(echo "$active_block" | jq -r '.entries')                                # e.g: 166

# Used tokens
input_tokens=$(echo "$active_block" | jq -r '.tokenCounts.inputTokens')           # e.g: 503
output_tokens=$(echo "$active_block" | jq -r '.tokenCounts.outputTokens')         # e.g: 22814
cache_creation_tokens=$(echo "$active_block" | jq -r '.tokenCounts.cacheCreationInputTokens') # e.g: 404511
cache_read_tokens=$(echo "$active_block" | jq -r '.tokenCounts.cacheReadInputTokens')     # e.g: 10004316
total_tokens=$(echo "$active_block" | jq -r '.totalTokens')                             # e.g: 10432144

# Now Cost (USD)
cost=$(echo "$active_block" | jq -r '.costUSD')                                   # e.g: 8.285881650000004

# Burn rate
tokens_per_minute=$(echo "$active_block" | jq -r '.burnRate.tokensPerMinute')     # e.g: 54098.75843023459
tokens_per_minute_for_indicator=$(echo "$active_block" | jq -r '.burnRate.tokensPerMinuteForIndicator') # e.g: 120.91673104951197
cost_per_hour=$(echo "$active_block" | jq -r '.burnRate.costPerHour')             # e.g: 2.5781234026190427

# Projection
projected_tokens=$(echo "$active_block" | jq -r '.projection.totalTokens')        # e.g: 13845592
projected_cost=$(echo "$active_block" | jq -r '.projection.totalCost')            # e.g: 11
remaining_minutes=$(echo "$active_block" | jq -r '.projection.remainingMinutes')  # e.g: 63

# Calculate usage percentage using assumed limit
if [ "$assumed_limit" != "null" ] && [ "$assumed_limit" != "0" ]; then
  usage_percent=$(safe_math "$total_tokens / $assumed_limit * 100")
  usage_percent=$(printf "%.1f" "$usage_percent")
else
  usage_percent="N/A"
fi


# Reset Time
remaining_time_str=$(format_remaining_time "$remaining_minutes")                  # e.g: 1h 3m left

# Calculate reset time (current time + remaining minutes)
if [ "$remaining_minutes" != "null" ]; then
  reset_time=$(calculate_reset_time "$remaining_minutes")
  if [ "$reset_time" != "N/A" ]; then
    reset_time_str="$remaining_time_str ($reset_time)"
  else
    reset_time_str="$remaining_time_str"
  fi
else
  reset_time_str="$remaining_time_str"
fi

# Output formatting
model_str=$(printf "🤖 %s" "$model_name")
cost_str=$(printf "💵 \$%.2f" "$cost")

# Token with limit
if [ "$assumed_limit" != "null" ] && [ "$assumed_limit" != "0" ]; then
  token_str=$(printf "🔢 %s / %s (assuming)" "$(format_number_with_commas "$total_tokens")" "$(format_number_with_commas "$assumed_limit")")
else
  token_str=$(printf "🔢 %s" "$(format_number_with_commas "$total_tokens")")
fi

# Usage percentage with color indicator
if [ "$usage_percent" != "N/A" ]; then
  usage_float=$(printf "%.0f" "$usage_percent" 2>/dev/null || echo "0")
  if [ "$usage_float" -le 25 ]; then
    usage_indicator="🟢"
  elif [ "$usage_float" -le 50 ]; then
    usage_indicator="🟡"
  elif [ "$usage_float" -le 75 ]; then
    usage_indicator="🟠"
  else
    usage_indicator="🔴"
  fi
  using_str=$(printf "%s %s%%" "$usage_indicator" "$usage_percent")
else
  using_str="📊 N/A"
fi

reset_str=$(printf "⏱️  %s" "$reset_time_str")

# Burn rate indicator with percentage
if [ "$tokens_per_minute_for_indicator" != "null" ]; then
  burn_percentage=$(printf "%.0f" "$tokens_per_minute_for_indicator" 2>/dev/null || echo "0")

  if [ "$burn_percentage" -gt 100 ]; then
    burn_str=$(printf "🔥 %s%%" "$burn_percentage")
  else
    burn_str=$(printf "🔥 %s%%" "$burn_percentage")
  fi
else
  burn_str="🔥 N/A"
fi

# Output the status line
session_str=$(printf "📋 %s" "$session_name")
printf "%s │ %s │ %s │ %s │ %s │ %s │ %s" "$session_str" "$model_str" "$cost_str" "$token_str" "$using_str" "$burn_str" "$reset_str"

