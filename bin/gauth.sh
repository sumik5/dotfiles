#!/bin/bash
set -uo pipefail

# 色付き出力用の関数
print_status() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# ─────────────────────────────────────────────
# 汎用メニュー選択関数（アカウント/組織/プロジェクト共通）
#   Usage : printf '%s\n' "${items[@]}" | pick_one "プロンプト > "
#   入力  : メニュー項目を標準入力から1行ずつ
#   引数  : $1 = peco 用プロンプト文字列
#   出力  : 選択結果を標準出力へ。キャンセル/空/項目0件時は空文字
#   終了   : 常に 0（キャンセルは呼び出し側で空判定）
#   備考  : ログ類は標準エラーへ出し stdout を汚さない。
#           select はメニューを stdin から受けたため、ユーザー入力は
#           /dev/tty から読む（peco は内部で /dev/tty を使用）。
# ─────────────────────────────────────────────
pick_one() {
    local prompt="$1"
    local items=()
    local line
    while IFS= read -r line; do
        [[ -n "$line" ]] && items+=("$line")
    done

    # 候補が無ければ何も出力せず終了
    if [[ ${#items[@]} -eq 0 ]]; then
        return 0
    fi

    local selected=""
    if command -v peco >/dev/null 2>&1; then
        # peco: キャンセル (ESC) 時は空文字・終了コード非0 を返す
        selected=$(printf '%s\n' "${items[@]}" | peco --prompt "$prompt" 2>/dev/null || true)
    else
        print_status "peco が見つかりません。select メニューを使用します。" >&2
        local PS3="番号を入力してください: "
        local item
        select item in "${items[@]}"; do
            if [[ -n "$item" ]]; then
                selected="$item"
                break
            fi
            print_error "無効な番号です。再度入力してください。" >&2
        done </dev/tty
    fi

    printf '%s' "$selected"
}

# 新規追加エントリのラベル
NEW_ACCOUNT_LABEL="➕ 新しいアカウントを追加 (ブラウザ認証)"
# 手動入力エントリのラベル
MANUAL_ORG_LABEL="✏️ 組織IDを手動入力 / 組織を指定しない"
MANUAL_PROJECT_LABEL="✏️ プロジェクトIDを手動入力"

# 現在の選択を示す目印（メニュー表示用）
# 注意: bash 3.2 ではリテラルのマルチバイトパターン ${var% (現在)} が
#       ロケール環境により一致しないことがあるため、必ずこの変数を
#       無クォートで参照して除去する（${var%$CURRENT_MARKER}）。
CURRENT_MARKER=" (現在)"

# 現在のアクティブアカウントを取得
CURRENT_ACCOUNT=$(gcloud config get-value account 2>/dev/null || true)

# 認証済みアカウント一覧を取得（macOS bash 3.2 対応: mapfile/readarray 不使用）
print_status "認証済みアカウントを確認中..."
accounts=()
while IFS= read -r line; do
    [[ -n "$line" ]] && accounts+=("$line")
done < <(gcloud auth list --format="value(account)" 2>/dev/null || true)

# ─────────────────────────────────────────────
# 認証済みアカウントが 0 件 → 新規認証へフォールバック
# ─────────────────────────────────────────────
if [[ ${#accounts[@]} -eq 0 ]]; then
    print_status "認証済みアカウントがありません。新規認証を開始します..."
    if gcloud auth login; then
        print_success "GCloud CLI 認証成功"
        CURRENT_ACCOUNT=$(gcloud config get-value account 2>/dev/null || true)
    else
        print_error "GCloud CLI 認証に失敗しました"
        exit 1
    fi
else
    # ─────────────────────────────────────────────
    # メニュー候補を構築（現在アカウントに目印を付与）
    # ─────────────────────────────────────────────
    menu_items=()
    for account in "${accounts[@]}"; do
        if [[ "$account" == "$CURRENT_ACCOUNT" ]]; then
            menu_items+=("${account}${CURRENT_MARKER}")
        else
            menu_items+=("$account")
        fi
    done
    menu_items+=("$NEW_ACCOUNT_LABEL")

    # ─────────────────────────────────────────────
    # peco または select でアカウント選択（共通関数 pick_one）
    # ─────────────────────────────────────────────
    selected=$(printf '%s\n' "${menu_items[@]}" | pick_one "アカウントを選択 > ")

    # 選択がキャンセル / 空の場合は安全に終了
    if [[ -z "$selected" ]]; then
        print_status "選択がキャンセルされました。"
        exit 0
    fi

    # ─────────────────────────────────────────────
    # 選択結果に応じて分岐
    # ─────────────────────────────────────────────
    if [[ "$selected" == "$NEW_ACCOUNT_LABEL" ]]; then
        # 新しいアカウントを追加
        print_status "新しいアカウントのブラウザ認証を開始します..."
        if gcloud auth login; then
            print_success "GCloud CLI 認証成功"
            CURRENT_ACCOUNT=$(gcloud config get-value account 2>/dev/null || true)
        else
            print_error "GCloud CLI 認証に失敗しました"
            exit 1
        fi
    else
        # 既存アカウントへ切り替え（目印文字列を除去 / bash 3.2 対策で無クォート変数）
        # shellcheck disable=SC2295 # bash 3.2 ではクォートするとマルチバイト目印が除去できないため意図的に無クォート
        account_email="${selected%$CURRENT_MARKER}"
        print_status "アカウントを切り替え中: ${account_email}"
        if gcloud config set account "${account_email}"; then
            print_success "アカウントを切り替えました: ${account_email}"
            CURRENT_ACCOUNT="${account_email}"
        else
            print_error "アカウントの切り替えに失敗しました"
            exit 1
        fi
    fi
fi

# ─────────────────────────────────────────────
# CLIトークン検証 + 自動 reauth
# アカウント確定後（新規追加・既存切替どちらの経路でも）に
# print-access-token でトークン有効性を確認する。
# 失敗（非0終了）= トークン切れ/reauth 要求とみなして再認証を実行。
# ─────────────────────────────────────────────
echo
print_status "CLIトークンの有効性を確認中..."
if ! gcloud auth print-access-token "${CURRENT_ACCOUNT}" >/dev/null 2>&1; then
    print_status "CLIトークンの再認証が必要です。ブラウザ認証を開始します..."
    if gcloud auth login "${CURRENT_ACCOUNT}"; then
        print_success "CLI再認証成功"
    else
        print_error "CLI再認証に失敗しました"
        exit 1
    fi
else
    print_success "CLIトークンは有効です"
fi

# ─────────────────────────────────────────────
# ADC (Application Default Credentials) を実行
# ─────────────────────────────────────────────
echo
print_status "Application Default 認証を実行中..."
if gcloud auth application-default login; then
    print_success "Application Default 認証成功"
else
    print_error "Application Default 認証に失敗しました"
    exit 1
fi

# ─────────────────────────────────────────────
# 組織選択（NEW）
# stderrを握り潰さず、終了コードと出力内容でエラーを検知する。
# reauth系エラーを検知した場合は明示してから手動入力フォールバックへ。
# ─────────────────────────────────────────────
echo
print_status "アクセス可能な組織一覧を取得中..."
org_id=""
org_list_output=""
org_list_exit=0
org_list_output=$(gcloud organizations list --format="value(ID,displayName)" 2>&1) || org_list_exit=$?

if [[ $org_list_exit -ne 0 ]] || echo "$org_list_output" | grep -q -i "reauthentication\|invalid_grant\|credentials"; then
    # reauth/認証失敗を検知 → 握り潰さず明示してフォールバック
    print_error "組織一覧の取得に失敗しました（認証エラーの可能性）:"
    print_error "${org_list_output}"
    print_status "組織IDを手動入力してください（空Enterでスキップ）"
    echo -n "組織ID: " >&2
    read -r org_id </dev/tty || true
    org_id="${org_id:-}"
elif [[ -z "$org_list_output" ]]; then
    # 一覧が空（組織なし、または権限なし）→ 手動入力
    print_status "アクセス可能な組織が見つかりません。手動入力またはスキップします。"
    echo -n "組織ID（空Enterでスキップ）: " >&2
    read -r org_id </dev/tty || true
    org_id="${org_id:-}"
else
    # 組織一覧を配列化してメニューに変換
    org_items=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && org_items+=("$line")
    done <<< "$org_list_output"
    org_items+=("$MANUAL_ORG_LABEL")

    selected_org=$(printf '%s\n' "${org_items[@]}" | pick_one "組織を選択 > ")

    if [[ -z "$selected_org" ]] || [[ "$selected_org" == "$MANUAL_ORG_LABEL" ]]; then
        # キャンセルまたは手動入力選択
        echo -n "組織ID（空Enterでスキップ）: " >&2
        read -r org_id </dev/tty || true
        org_id="${org_id:-}"
    else
        # 先頭トークン（組織ID）を抽出（組織名にスペースが含まれるため末尾を捨てる）
        org_id="${selected_org%%[[:space:]]*}"
    fi
fi

if [[ -n "$org_id" ]]; then
    print_success "選択された組織ID: ${org_id}"
else
    print_status "組織指定なしで続行します"
fi

# ─────────────────────────────────────────────
# プロジェクト選択（CLI + ADC quota project の両方へ設定）
# 組織が選ばれている場合は当該組織配下のプロジェクトのみ取得。
# stderrを握り潰さず、reauth/失敗を検知して手動入力フォールバックへ。
# ─────────────────────────────────────────────
echo
print_status "アクセス可能なプロジェクト一覧を取得中..."
project_id=""
project_list_output=""
project_list_exit=0

if [[ -n "$org_id" ]]; then
    project_list_output=$(gcloud projects list \
        --filter="parent.id=${org_id} AND parent.type=organization" \
        --format="value(projectId)" 2>&1) || project_list_exit=$?
else
    project_list_output=$(gcloud projects list --format="value(projectId)" 2>&1) || project_list_exit=$?
fi

if [[ $project_list_exit -ne 0 ]] || echo "$project_list_output" | grep -q -i "reauthentication\|invalid_grant\|credentials"; then
    # reauth/認証失敗を検知 → 握り潰さず明示してフォールバック
    print_error "プロジェクト一覧の取得に失敗しました（認証エラーの可能性）:"
    print_error "${project_list_output}"
    print_status "プロジェクトIDを手動入力してください（空Enterでスキップ）"
    echo -n "プロジェクトID: " >&2
    read -r project_id </dev/tty || true
    project_id="${project_id:-}"
else
    projects=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && projects+=("$line")
    done <<< "$project_list_output"

    if [[ ${#projects[@]} -eq 0 ]]; then
        # プロジェクト0件: 致命的終了せず手動入力へ
        print_error "アクセス可能なプロジェクトが見つかりません。手動入力またはスキップします。"
        echo -n "プロジェクトID（空Enterでスキップ）: " >&2
        read -r project_id </dev/tty || true
        project_id="${project_id:-}"
    else
        CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || true)

        # メニュー候補を構築（現在プロジェクトに目印を付与）
        project_menu=()
        for project in "${projects[@]}"; do
            if [[ "$project" == "$CURRENT_PROJECT" ]]; then
                project_menu+=("${project}${CURRENT_MARKER}")
            else
                project_menu+=("$project")
            fi
        done
        project_menu+=("$MANUAL_PROJECT_LABEL")

        # 共通関数 pick_one でプロジェクト選択
        selected_project=$(printf '%s\n' "${project_menu[@]}" | pick_one "プロジェクトを選択 > ")

        if [[ -z "$selected_project" ]]; then
            # キャンセル/空: プロジェクトは変更せず処理続行
            print_status "プロジェクトは変更しません。"
        elif [[ "$selected_project" == "$MANUAL_PROJECT_LABEL" ]]; then
            # 手動入力選択
            echo -n "プロジェクトID（空Enterでスキップ）: " >&2
            read -r project_id </dev/tty || true
            project_id="${project_id:-}"
        else
            # 目印文字列を除去して実プロジェクトIDを取得（bash 3.2 対策で無クォート変数）
            # shellcheck disable=SC2295 # bash 3.2 ではクォートするとマルチバイト目印が除去できないため意図的に無クォート
            project_id="${selected_project%$CURRENT_MARKER}"
        fi
    fi
fi

# ─────────────────────────────────────────────
# プロジェクト設定（project_id が確定している場合のみ）
# ─────────────────────────────────────────────
if [[ -n "${project_id:-}" ]]; then
    # CLI 側プロジェクト設定（失敗は致命的）
    print_status "プロジェクトを設定中: ${project_id}"
    if gcloud config set project "${project_id}"; then
        print_success "プロジェクトを設定しました: ${project_id}"
    else
        print_error "プロジェクトの設定に失敗しました"
        exit 1
    fi

    # ADC quota project 設定（失敗しても致命的にしない）
    print_status "ADC quota project を設定中: ${project_id}"
    if gcloud auth application-default set-quota-project "${project_id}"; then
        print_success "ADC quota project を設定しました: ${project_id}"
    else
        print_error "ADC quota project の設定に失敗しました（対象プロジェクトで cloudresourcemanager API の有効化が必要な場合があります）。処理を続行します。"
    fi
else
    print_status "プロジェクト設定をスキップします。"
fi

# ─────────────────────────────────────────────
# 最終確認表示
# ─────────────────────────────────────────────
# ADC quota project は ADC 認証情報ファイルから best-effort で取得
ADC_FILE="${HOME}/.config/gcloud/application_default_credentials.json"
adc_quota_project=""
if [[ -f "$ADC_FILE" ]]; then
    adc_quota_project=$(grep -o '"quota_project_id"[: ]*"[^"]*"' "$ADC_FILE" 2>/dev/null | sed -E 's/.*: *"([^"]*)"/\1/' || true)
fi

print_success "認証完了！"
echo "----------------------------------------"
echo "アクティブアカウント: $(gcloud config get-value account 2>/dev/null)"
echo "プロジェクト (CLI)  : $(gcloud config get-value project 2>/dev/null)"
echo "ADC quota project   : ${adc_quota_project:-（未設定）}"
echo "----------------------------------------"
