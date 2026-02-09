#!/bin/bash
# Claude Code Enhanced Status Line
# Model | Context | In/Out | Remaining | ETA | Compression | Burn Rate | D/W/M

CLAUDE_DIR="$HOME/.claude"
SESSION_FILE="$CLAUDE_DIR/.sl_session.json"
LAST_STATE_FILE="$CLAUDE_DIR/.sl_last_state.json"
USAGE_LOG="$CLAUDE_DIR/.sl_usage_log.csv"
COMPRESS_FILE="$CLAUDE_DIR/.sl_compress.json"

input=$(cat)

# Extract data
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')

used_tokens=$((total_input + total_output))
current_used=$(awk "BEGIN {printf \"%.0f\", ($used_pct * $context_size) / 100}")
remaining_tokens=$((context_size - current_used))
[ "$remaining_tokens" -lt 0 ] && remaining_tokens=0
current_time=$(date +%s)

# Format number with k/M suffix
fmt() {
  local n=$1
  if [ "$n" -ge 1000000 ] 2>/dev/null; then
    awk "BEGIN {printf \"%.1fM\", $n/1000000}"
  elif [ "$n" -ge 1000 ] 2>/dev/null; then
    awk "BEGIN {printf \"%.1fk\", $n/1000}"
  else
    echo "${n:-0}"
  fi
}

# Initialize usage log
[ ! -f "$USAGE_LOG" ] && echo "ts,sid,tokens" > "$USAGE_LOG"

# Session & burn rate tracking
burn_rate_str="--"
eta_str="--"
br_val=0
new_session=0

if [ -f "$LAST_STATE_FILE" ]; then
  last_sid=$(jq -r '.sid // ""' "$LAST_STATE_FILE" 2>/dev/null)
  last_tok=$(jq -r '.tok // 0' "$LAST_STATE_FILE" 2>/dev/null)

  if [ "$session_id" != "$last_sid" ] || [ "$current_used" -lt "${last_tok:-0}" ]; then
    new_session=1
    if [ -n "$last_sid" ] && [ "${last_tok:-0}" -gt 0 ]; then
      echo "$current_time,$last_sid,$last_tok" >> "$USAGE_LOG"
    fi
    printf '{"ts":%d,"tok":0}' "$current_time" > "$SESSION_FILE"
    printf '{"sid":"%s","count":0,"last_used":%d}' "$session_id" "$current_used" > "$COMPRESS_FILE"
  fi
else
  new_session=1
  printf '{"ts":%d,"tok":0}' "$current_time" > "$SESSION_FILE"
  printf '{"sid":"%s","count":0,"last_used":%d}' "$session_id" "$current_used" > "$COMPRESS_FILE"
fi

# Detect context compression (used_tokens drops significantly within same session)
compress_count=0
if [ -f "$COMPRESS_FILE" ]; then
  c_sid=$(jq -r '.sid // ""' "$COMPRESS_FILE" 2>/dev/null)
  c_count=$(jq -r '.count // 0' "$COMPRESS_FILE" 2>/dev/null)
  c_last=$(jq -r '.last_used // 0' "$COMPRESS_FILE" 2>/dev/null)

  if [ "$session_id" = "$c_sid" ]; then
    compress_count=$c_count
    if [ "$c_last" -gt 0 ] && [ "$current_used" -gt 0 ]; then
      drop=$((c_last - current_used))
      threshold=$((c_last / 5))
      if [ "$drop" -gt "$threshold" ] && [ "$drop" -gt 10000 ]; then
        compress_count=$((compress_count + 1))
      fi
    fi
    printf '{"sid":"%s","count":%d,"last_used":%d}' "$session_id" "$compress_count" "$current_used" > "$COMPRESS_FILE"
  fi
fi

# Update last state
printf '{"sid":"%s","tok":%d,"ts":%d}' "$session_id" "$current_used" "$current_time" > "$LAST_STATE_FILE"

# Calculate burn rate & ETA
if [ -f "$SESSION_FILE" ]; then
  s_start=$(jq -r '.ts' "$SESSION_FILE" 2>/dev/null || echo "$current_time")
  elapsed=$((current_time - s_start))
  if [ "$elapsed" -gt 10 ] && [ "$current_used" -gt 0 ]; then
    br_val=$(awk "BEGIN {v=($current_used * 60.0) / $elapsed; printf \"%.0f\", v}")
    burn_rate_str="$(fmt "$br_val")/min"

    if [ "$br_val" -gt 0 ] 2>/dev/null; then
      eta_sec=$(awk "BEGIN {printf \"%.0f\", ($remaining_tokens * 60.0) / $br_val}")
      if [ "$eta_sec" -ge 3600 ] 2>/dev/null; then
        eta_str="$(awk "BEGIN {printf \"%.1f\", $eta_sec/3600}")h"
      elif [ "$eta_sec" -ge 60 ] 2>/dev/null; then
        eta_str="$(awk "BEGIN {printf \"%.0f\", $eta_sec/60}")min"
      else
        eta_str="${eta_sec}s"
      fi
    fi
  fi
fi

# Aggregate daily/weekly/monthly
day_start=$(date -j -v0H -v0M -v0S +%s 2>/dev/null || echo $((current_time - 86400)))
week_ago=$((current_time - 604800))
month_ago=$((current_time - 2592000))

d_total=0; w_total=0; m_total=0
if [ -f "$USAGE_LOG" ]; then
  while IFS=, read -r ts sid tok; do
    [ "$ts" = "ts" ] && continue
    [[ "$tok" =~ ^[0-9]+$ ]] || continue
    [ "${ts:-0}" -ge "$day_start" ] 2>/dev/null && d_total=$((d_total + tok))
    [ "${ts:-0}" -ge "$week_ago" ] 2>/dev/null && w_total=$((w_total + tok))
    [ "${ts:-0}" -ge "$month_ago" ] 2>/dev/null && m_total=$((m_total + tok))
  done < "$USAGE_LOG"
fi

d_total=$((d_total + used_tokens))
w_total=$((w_total + used_tokens))
m_total=$((m_total + used_tokens))

# Prune old entries occasionally
if [ $((RANDOM % 50)) -eq 0 ] && [ -f "$USAGE_LOG" ]; then
  cutoff=$((current_time - 7776000))
  tmp="$USAGE_LOG.tmp"
  head -1 "$USAGE_LOG" > "$tmp"
  tail -n +2 "$USAGE_LOG" | awk -F, -v c="$cutoff" '$1 >= c' >> "$tmp"
  mv "$tmp" "$USAGE_LOG"
fi

# Build progress bar
pct_int=$(awk "BEGIN {printf \"%.0f\", ${used_pct:-0}}" 2>/dev/null || echo "0")
filled=$((pct_int / 10))
[ "$filled" -gt 10 ] && filled=10
empty=$((10 - filled))
bar=""
for ((i=0; i<filled; i++)); do bar+="█"; done
for ((i=0; i<empty; i++)); do bar+="░"; done

# Performance zone indicator
if [ "$pct_int" -ge 90 ]; then
  perf="🔴 Critical"
elif [ "$pct_int" -ge 70 ]; then
  perf="🟠 Warning"
elif [ "$pct_int" -ge 50 ]; then
  perf="🟡 Caution"
else
  perf="🟢 Good"
fi

# Output (2 lines)
# Line 1: Session context status
# Line 2: Burn rate + Usage history
printf "🤖 %s │ 📊 %s/%s %s %d%% %s │ ⬇%s ⬆%s │ 💡残%s │ ⏳~%s │ 🔄%d回\n🔥 %s │ 🕐 Daily:%s  🗓 Weekly:%s  📊 Monthly:%s" \
  "$model" \
  "$(fmt $current_used)" \
  "$(fmt $context_size)" \
  "$bar" \
  "$pct_int" \
  "$perf" \
  "$(fmt $total_input)" \
  "$(fmt $total_output)" \
  "$(fmt $remaining_tokens)" \
  "$eta_str" \
  "$compress_count" \
  "$burn_rate_str" \
  "$(fmt $d_total)" \
  "$(fmt $w_total)" \
  "$(fmt $m_total)"

