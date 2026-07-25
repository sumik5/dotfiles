#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
umask 077
BASE_URL=
LOGIN_URL=
if test "${1:-}" = -h || test "${1:-}" = --help; then
  printf '%s\n' 'Usage: collect.sh' >&2
  printf '%s\n' 'username、password、取得対象URLを順番に対話入力します。' >&2
  exit 0
fi
[[ "${1:-}" == "--download-one" || "$#" -eq 0 ]] || { printf '%s\n' '引数は指定せずに実行してください' >&2; exit 1; }

if [[ "${1:-}" == "--download-one" ]]; then
  parent="$2"; name="$3"; url="$4"; destination="$5"; group_number="${6:-1}"; lesson_number="${7:-1}"; lesson_url="${8:-$url}"
  status_file="$destination/video-download-status.tsv"
  if [[ -f "$status_file" ]] && awk -F '\t' -v target="$lesson_url" '$2 == target && $4 == "done" { found=1 } END { exit found ? 0 : 1 }' "$status_file"; then
    printf '[skip] 取得済み: %s\n' "$name" >&2
    exit 0
  fi
  clean_name() { printf '%s' "$1" | tr '\n\r\t' '   ' | sed -E 's#[/\\:*?"<>|]+#_#g; s/[[:space:]]+/_/g; s/_+/_/g; s/^_+//; s/_+$//'; }
  parent=$(clean_name "$parent"); name=$(clean_name "$name"); [[ -n "$parent" ]] || parent=video; [[ -n "$name" ]] || name=video
  group_prefix=$(printf '%02d.' "$group_number")
  lesson_prefix=$(printf '%02d.' "$lesson_number")
  mkdir -p -- "$destination/$group_prefix$parent"
  output="$destination/$group_prefix$parent/$lesson_prefix$name.mp4"
  [[ ! -e "$output" ]] || { printf '[skip] 保存済み: %s\n' "$output" >&2; exit 0; }
  temp=$(mktemp "$output.part.XXXXXX"); rm -f -- "$temp"
  if ffmpeg -nostdin -hide_banner -loglevel error -y \
    -user_agent 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36' \
    -i "$url" -c copy -f mp4 "$temp"; then
    mv -- "$temp" "$output"
    printf '%s\t%s\t%s\tdone\n' "$name" "$lesson_url" "$output" >> "$status_file"
    printf '[saved] %s\n' "$output" >&2
  else rm -f -- "$temp"; printf '[failed] %s\n' "$name" >&2; exit 1; fi
  exit 0
fi

printf '%s' 'ビデオのダウンロード先（空欄でカレントフォルダ）: ' >&2
IFS= read -r OUTPUT_DIR
OUTPUT_DIR="${OUTPUT_DIR:-$(pwd)}"
mkdir -p -- "$OUTPUT_DIR"
OUTPUT_DIR="$(cd -- "$OUTPUT_DIR" && pwd)"

CONFIG_FILE="$OUTPUT_DIR/.collect-config"
STATUS_FILE="$OUTPUT_DIR/video-download-status.tsv"
if [[ -f "$CONFIG_FILE" ]]; then
  log_config='保存先の設定ファイルを使用します'
  printf '[config] %s\n' "$log_config" >&2
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
  COLLECT_USERNAME="$CONFIG_USERNAME"
  COLLECT_PASSWORD=$(printf '%s' "$CONFIG_PASSWORD_B64" | base64 --decode)
  COURSE_URL="$CONFIG_COURSE_URL"
else
  printf '%s' 'username: ' >&2
  IFS= read -r COLLECT_USERNAME
  printf '%s' 'password: ' >&2
  IFS= read -r -s COLLECT_PASSWORD
  printf '\n' >&2
  printf '%s' '取得対象URL: ' >&2
  IFS= read -r COURSE_URL
  printf 'CONFIG_USERNAME=%q\nCONFIG_PASSWORD_B64=%q\nCONFIG_COURSE_URL=%q\n' \
    "$COLLECT_USERNAME" "$(printf '%s' "$COLLECT_PASSWORD" | base64)" "$COURSE_URL" > "$CONFIG_FILE"
  chmod 600 "$CONFIG_FILE"
fi

printf '%s' '終了時刻（HH:MM）: ' >&2
IFS= read -r END_CLOCK
[[ "$END_CLOCK" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]] || { printf '%s\n' 'エラー: HH:MM形式で指定してください' >&2; exit 1; }
END_EPOCH=$(date -j -f '%Y-%m-%d %H:%M:%S' "$(date +%Y-%m-%d) ${END_CLOCK}:00" '+%s')
(( END_EPOCH <= $(date +%s) )) && END_EPOCH=$((END_EPOCH + 24 * 60 * 60))
runtime_remaining(){ printf '%s' $((END_EPOCH - $(date +%s))); }

test -n "$COLLECT_USERNAME" || { printf '%s\n' 'エラー: usernameが空です' >&2; exit 1; }
test -n "$COLLECT_PASSWORD" || { printf '%s\n' 'エラー: passwordが空です' >&2; exit 1; }
test -n "$COURSE_URL" || { printf '%s\n' 'エラー: 取得対象URLが空です' >&2; exit 1; }
[[ $COURSE_URL =~ ^https://[A-Za-z0-9.-]+/course/id/[0-9]+/?$ ]] || { printf '%s\n' 'エラー: URL形式が不正です' >&2; exit 1; }
BASE_URL=$(printf '%s' "$COURSE_URL" | sed -E 's#^(https://[^/]+).*#\1#')
LOGIN_URL=$BASE_URL/login/
COURSE_ID=$(printf '%s' "$COURSE_URL" | sed -E 's|.*/course/id/([0-9]+)/?|\1|')
AGENT_BROWSER=${AGENT_BROWSER:-$(command -v agent-browser || true)}
command -v jq >/dev/null || { printf '%s\n' 'エラー: jq が見つかりません' >&2; exit 1; }
test -n "$AGENT_BROWSER" || { printf '%s\n' 'エラー: agent-browser が見つかりません' >&2; exit 1; }
COLLECT_AUTH_PROFILE=${COLLECT_AUTH_PROFILE:-default}; COLLECT_STATE_FILE=${COLLECT_STATE_FILE:-}
COLLECT_MAX_N=${COLLECT_MAX_N:-0}; COLLECT_WAIT_MIN_MS=${COLLECT_WAIT_MIN_MS:-15000}; COLLECT_WAIT_MAX_MS=${COLLECT_WAIT_MAX_MS:-30000}
COLLECT_LOGIN_TIMEOUT_MS=${COLLECT_LOGIN_TIMEOUT_MS:-60000}; COLLECT_MEDIA_TIMEOUT_MS=${COLLECT_MEDIA_TIMEOUT_MS:-15000}; COLLECT_MEDIA_POLL_MS=${COLLECT_MEDIA_POLL_MS:-250}
COLLECT_SESSION=${COLLECT_SESSION:-video-url-$COURSE_ID-$$}
for value in "$COLLECT_MAX_N" "$COLLECT_WAIT_MIN_MS" "$COLLECT_WAIT_MAX_MS" "$COLLECT_LOGIN_TIMEOUT_MS" "$COLLECT_MEDIA_TIMEOUT_MS" "$COLLECT_MEDIA_POLL_MS"; do [[ $value =~ ^[0-9]+$ ]] || { printf '%s\n' 'エラー: 数値環境変数が不正です' >&2; exit 1; }; done
((COLLECT_WAIT_MAX_MS>=COLLECT_WAIT_MIN_MS)) || { printf '%s\n' 'エラー: 待機範囲が不正です' >&2; exit 1; }
[[ $COLLECT_AUTH_PROFILE =~ ^[A-Za-z0-9._-]+$ && $COLLECT_SESSION =~ ^[A-Za-z0-9._-]+$ ]] || { printf '%s\n' 'エラー: 名前が不正です' >&2; exit 1; }
[[ -z $COLLECT_STATE_FILE || ! -L $COLLECT_STATE_FILE ]] || { printf '%s\n' 'エラー: stateにシンボリックリンクは指定できません' >&2; exit 1; }
TMP_DIR=$(mktemp -d /tmp/collect-urls.XXXXXX); TEMP_AUTH_PROFILE=
if [[ ! -f "$STATUS_FILE" ]]; then printf '%s\n' $'name\turl\tpath\tstatus' > "$STATUS_FILE"; chmod 600 "$STATUS_FILE"; fi
URL_COUNT=0
DOWNLOAD_COUNT=0
log(){ printf '%s\n' "$*" >&2; }
cleanup(){ trap - EXIT INT TERM; test -z "$TEMP_AUTH_PROFILE" || "$AGENT_BROWSER" auth delete "$TEMP_AUTH_PROFILE" >/dev/null 2>&1 || true; "$AGENT_BROWSER" --session "$COLLECT_SESSION" close >/dev/null 2>&1 || true; rm -rf -- "$TMP_DIR"; }
trap cleanup EXIT; trap 'exit 130' INT; trap 'exit 143' TERM
cat >"$TMP_DIR/check.js" <<'JS'
(()=>{const c=/^\/course\/id\/\d+\/?$/.test(location.pathname);return{loggedIn:Boolean(c&&!location.pathname.startsWith('/login')),loginPage:location.pathname.startsWith('/login')}})()
JS
cat >"$TMP_DIR/links.js" <<'JS'
(async()=>{const ts=[...document.querySelectorAll('div[onclick*="open_detail(\'lesson\'"]')],out=[],seen=new Set(),wait=m=>new Promise(r=>setTimeout(r,m)),norm=h=>{try{const u=new URL(h,document.baseURI);return u.origin===location.origin&&/^\/course\/lesson\/index\/id\/\d+\//.test(u.pathname)?u.href:null}catch(_){return null}},clean=v=>(v||'').replace(/[\s\t\r\n]+/g,' ').trim(),nameOf=l=>{const attr=['title','aria-label','data-title','data-name'].map(k=>clean(l.getAttribute(k))).find(Boolean);if(attr)return attr;const child=[...l.querySelectorAll('[title],[aria-label],[data-title],[data-name]')].map(e=>['title','aria-label','data-title','data-name'].map(k=>clean(e.getAttribute(k))).find(Boolean)).find(Boolean);return child||clean(l.textContent)||'video'};for(const t of ts){const m=(t.getAttribute('onclick')||'').match(/open_detail\(\s*['"]lesson['"]\s*,\s*(\d+)/);if(!m||seen.has(m[1]))continue;seen.add(m[1]);const b=document.getElementById('lesson_detail'+m[1])||t.closest('li')||t.parentElement;if(!b)continue;let ls=[...b.querySelectorAll('a[href*="/course/lesson/index/id/"]')];if(!ls.length){t.click();for(let i=0;i<40&&!ls.length;i++){await wait(250);ls=[...b.querySelectorAll('a[href*="/course/lesson/index/id/"]')]}}for(const l of ls){const u=norm(l.getAttribute('href')||'');if(u)out.push({parent:nameOf(t),name:nameOf(l),url:u})}}const unique=[];for(const item of out){if(!unique.some(x=>x.url===item.url))unique.push(item)}return{urls:unique}})()
JS
cat >"$TMP_DIR/media.js" <<'JS'
(()=>{const o=[],add=v=>{if(!v||v.startsWith('blob:'))return;try{const u=new URL(v,document.baseURI);if(u.protocol==='https:'&&/\.(m3u8|mp4)([?#]|$)/i.test(u.href))o.push(u.href)}catch(_){}};for(const v of document.querySelectorAll('video')){add(v.currentSrc);add(v.src);for(const s of v.querySelectorAll('source[src]'))add(s.src)}for(const e of performance.getEntriesByType('resource'))add(e.name);return{hasVideo:!!document.querySelector('video'),loginPage:location.pathname.startsWith('/login'),urls:[...new Set(o)]}})()
JS
cat >"$TMP_DIR/pause.js" <<'JS'
(()=>{for(const m of document.querySelectorAll('video,audio'))try{m.pause()}catch(_){}return true})()
JS
ab(){ "$AGENT_BROWSER" --session "$COLLECT_SESSION" "$@"; }
wait_login(){ elapsed=0; last_report=-5000; while ((elapsed<=COLLECT_LOGIN_TIMEOUT_MS)); do r=$(ab eval --stdin <"$TMP_DIR/check.js" 2>/dev/null||printf '{"loggedIn":false,"loginPage":false}'); printf '%s' "$r"|jq -e '.loggedIn==true' >/dev/null 2>&1&&return 0; printf '%s' "$r"|jq -e '.loginPage==true' >/dev/null 2>&1&&{ log "ログインページを検出しました（${elapsed}ms）"; return 1; }; if ((elapsed-last_report>=5000)); then log "ログイン状態を確認中...（${elapsed}/${COLLECT_LOGIN_TIMEOUT_MS}ms）"; last_report=$elapsed; fi; sleep "$(awk -v m="$COLLECT_MEDIA_POLL_MS" 'BEGIN{printf "%.3f",m/1000}')"; elapsed=$((elapsed+COLLECT_MEDIA_POLL_MS)); done; log "ログイン確認がタイムアウトしました"; return 1; }
log '[1/4] コースページを開いています'
if [[ -n $COLLECT_STATE_FILE && -f $COLLECT_STATE_FILE ]];then "$AGENT_BROWSER" --session "$COLLECT_SESSION" --state "$COLLECT_STATE_FILE" open "$COURSE_URL" >/dev/null;else ab open "$COURSE_URL" >/dev/null;fi
log '[2/4] ログイン状態を確認しています'
if ! wait_login;then log '[2/4] ログイン処理を開始します'; profile=$COLLECT_AUTH_PROFILE;if [[ -n $COLLECT_USERNAME || -n $COLLECT_PASSWORD ]];then [[ -n $COLLECT_USERNAME && -n $COLLECT_PASSWORD ]]||{ printf '%s\n' 'エラー: 資格情報は両方指定してください' >&2; exit 1; };TEMP_AUTH_PROFILE=video-url-$COURSE_ID-$$;printf '%s' "$COLLECT_PASSWORD"|"$AGENT_BROWSER" auth save "$TEMP_AUTH_PROFILE" --url "$LOGIN_URL" --username "$COLLECT_USERNAME" --password-stdin --username-selector 'input[type="email"]' --password-selector 'input[type="password"]' --submit-selector 'a.text_submit' >/dev/null;unset COLLECT_PASSWORD;profile=$TEMP_AUTH_PROFILE;else "$AGENT_BROWSER" auth show "$profile" >/dev/null 2>&1||{ printf '%s\n' "エラー: Auth Vaultプロファイルが見つかりません: $profile" >&2; exit 1; };fi;ab auth login "$profile" --username-selector 'input[type="email"]' --password-selector 'input[type="password"]' --submit-selector 'a.text_submit' >/dev/null;ab wait 1000 >/dev/null;ab open "$COURSE_URL" >/dev/null;wait_login||{ printf '%s\n' 'エラー: ログイン後にコースページを確認できませんでした' >&2; exit 1; };fi
log '[3/4] レッスン一覧を取得しています'
ab open "$COURSE_URL" >/dev/null;wait_login||{ printf '%s\n' 'エラー: コースページの読み込みを確認できませんでした' >&2; exit 1; }
links='{"urls":[]}'; count=0; elapsed=0
while ((elapsed<=COLLECT_MEDIA_TIMEOUT_MS)); do
  links=$(ab eval --stdin <"$TMP_DIR/links.js" 2>/dev/null || printf '{"urls":[]}')
  count=$(printf '%s' "$links" | jq '.urls|length')
  ((count>0)) && break
  log "レッスン一覧を待機中...（${elapsed}/${COLLECT_MEDIA_TIMEOUT_MS}ms）"
  sleep "$(awk -v m="$COLLECT_MEDIA_POLL_MS" 'BEGIN{printf "%.3f",m/1000}')"
  elapsed=$((elapsed+COLLECT_MEDIA_POLL_MS))
done
((count>0))||{ printf '%s\n' 'エラー: レッスンリンクを検出できませんでした' >&2; exit 1; };total=$count;((COLLECT_MAX_N>0&&COLLECT_MAX_N<total))&&total=$COLLECT_MAX_N;log "[3/4] ${total}件のレッスンを検出しました。順次処理します";n=0
while IFS=$'\t' read -r _ waiting_name waiting_url; do
  [[ -n "$waiting_url" ]] || continue
  if ! awk -F '\t' -v target="$waiting_url" '$2 == target { found=1 } END { exit found ? 0 : 1 }' "$STATUS_FILE"; then
    printf '%s\t%s\t\twaiting\n' "$waiting_name" "$waiting_url" >> "$STATUS_FILE"
  fi
done < <(printf '%s' "$links" | jq -r '.urls[] | [(.parent // ""), (.name // ""), .url] | @tsv')
current_parent=''
next_parent_number=0
current_parent_count=0
while IFS=$'\t' read -r parent link_name url; do
  (( $(runtime_remaining) > 0 )) || { printf '[終了] 指定した終了時刻になりました\n' >&2; break; }
  ((n<total)) || break
  n=$((n+1))
  if [[ "$link_name" == *-* ]]; then
    parent="${link_name%%-*}"
    parent=$(printf '%s' "$parent" | sed -E 's/[0-9]+$//')
  fi
  if [[ "$parent" != "$current_parent" ]]; then
    existing_group_number=''
    for existing_dir in "$OUTPUT_DIR"/??."$parent"; do
      if [[ -d "$existing_dir" ]]; then
        existing_group_number=$(basename "$existing_dir" | sed -E 's/^([0-9]{2})\..*/\1/')
        break
      fi
    done
    if [[ -n "$existing_group_number" ]]; then
      next_parent_number=$((10#$existing_group_number))
    else
      next_parent_number=$((next_parent_number+1))
    fi
    current_parent="$parent"
    current_parent_count=0
  fi
  current_parent_count=$((current_parent_count+1))
  group_number=$next_parent_number
  lesson_number=$current_parent_count
  if awk -F '\t' -v target="$url" '$2 == target && $4 == "done" { found=1 } END { exit found ? 0 : 1 }' "$STATUS_FILE" 2>/dev/null; then
    printf '[skip] レッスン取得済み: %s\n' "$link_name" >&2
    continue
  fi
  log "[info] レッスン $n/$total"
  ab network requests --clear >/dev/null 2>&1 || true
  printf '[browser] レッスンページへ移動: %s\n' "$url" >&2
  ab open "$url" >/dev/null || continue
  ab wait 1000 >/dev/null
  printf '[browser] ページ移動完了。動画URLを確認します\n' >&2
  lesson_name=$(printf '%s' '(()=>{const e=document.querySelector("h1,h2,.lesson-title,.title");return (e?.textContent||"").replace(/[\s\t\r\n]+/g," ").trim()})()' | ab eval --stdin 2>/dev/null | jq -r 'if type=="string" then . else (.value // "") end' 2>/dev/null || true)
  [[ -n "$lesson_name" && "$lesson_name" != *"マイページ"* ]] && link_name="$lesson_name"
  if [[ "$link_name" == *-* ]]; then
    parent="${link_name%%-*}"
    parent=$(printf '%s' "$parent" | sed -E 's/[0-9]+$//')
  fi
  elapsed=0
  sel='[]'
  while ((elapsed<=COLLECT_MEDIA_TIMEOUT_MS)); do
    d=$(ab eval --stdin <"$TMP_DIR/media.js" 2>/dev/null || printf '{"hasVideo":false,"loginPage":false,"urls":[]}')
    q=$(ab network requests --json 2>/dev/null || printf '{"data":{"requests":[]}}')
    [[ $(printf '%s' "$d" | jq -r '.loginPage//false') != true ]] || { printf '%s\n' 'エラー: ログイン状態が失われました' >&2; exit 1; }
    sel=$(jq -cn --argjson d "$d" --argjson q "$q" '[ $d.urls[]?,(($q.data.requests? // [])[]?|.url?|select(type=="string")|select(test("\\.(m3u8|mp4)([?#]|$)";"i")))]|map(select(test("^https://";"i")))|unique as $a|($a|map(select(test("(?:^|/)(playlist|master|manifest)\\.m3u8([?#]|$)";"i")))) as $m|($a|map(select(test("\\.m3u8([?#]|$)";"i")))) as $h|($a|map(select(test("\\.mp4([?#]|$)";"i")))) as $p|if($m|length)>0 then $m elif($h|length)>0 then($h|sort_by(length)|.[0:1])else($p|sort_by(length)|.[0:1])end')
    [[ $(printf '%s' "$sel" | jq length) -gt 0 ]] && break
    [[ $(printf '%s' "$d" | jq -r '.hasVideo//false') == true ]] || break
    sleep "$(awk -v m="$COLLECT_MEDIA_POLL_MS" 'BEGIN{printf "%.3f",m/1000}')"
    elapsed=$((elapsed+COLLECT_MEDIA_POLL_MS))
  done
  while IFS= read -r media_url; do
    [[ -n "$media_url" ]] || continue
    URL_COUNT=$((URL_COUNT + 1))
    printf '[url] %d件目を取得: %s\n' "$URL_COUNT" "$media_url" >&2
    printf '[download-start] %s/%s\n' "$parent" "$link_name" >&2
    "$0" --download-one "$parent" "$link_name" "$media_url" "$OUTPUT_DIR" "$group_number" "$lesson_number" "$url"
    DOWNLOAD_COUNT=$((DOWNLOAD_COUNT + 1))
    printf '[download-count] 累計%d件\n' "$DOWNLOAD_COUNT" >&2
    downloaded_path=$(awk -F '\t' -v target="$url" '$2 == target && $4 == "done" { path=$3 } END { print path }' "$STATUS_FILE")
    if [[ -n "$downloaded_path" ]] && command -v ffprobe >/dev/null 2>&1; then
      media_seconds=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$downloaded_path" 2>/dev/null | awk '{ printf "%.0f", $1 }')
      [[ "$media_seconds" =~ ^[0-9]+$ ]] || media_seconds=0
    else
      media_seconds=0
    fi
    random_wait=$(awk 'BEGIN { srand(); printf "%.0f", 15 + rand() * 15 }')
    sleep_seconds=$((media_seconds + random_wait))
    printf '[wait] 動画時間%d秒 + ランダム待機%d秒、次のレッスンまで%d秒待機します\n' "$media_seconds" "$random_wait" "$sleep_seconds" >&2
    remaining_seconds=$(runtime_remaining)
    (( remaining_seconds <= 0 )) && { printf '[終了] 指定した終了時刻になりました\n' >&2; break 2; }
    if awk -v requested="$sleep_seconds" -v remaining="$remaining_seconds" 'BEGIN { exit !(requested > remaining) }'; then sleep_seconds="$remaining_seconds"; fi
    [[ "$sleep_seconds" == "0.000" ]] || sleep "$sleep_seconds"
  done < <(printf '%s' "$sel" | jq -r '.[]')
  ab eval --stdin <"$TMP_DIR/pause.js" >/dev/null 2>&1 || true
  done < <(printf '%s' "$links" | jq -r '.urls[] | [(.parent // ""), (.name // ""), .url] | @tsv')
