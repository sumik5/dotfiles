#!/bin/bash
set -euo pipefail

# PostToolUse hook: ファイル編集後に自動フォーマット
# - TypeScript/JavaScript: prettier + eslint --fix
# - Terraform: terraform fmt

# mise環境をロード（存在する場合）
if [[ -d "$HOME/.local/share/mise/shims" ]]; then
    export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

# stdinからJSONを読み込む
INPUT=$(cat)

# file_pathを取得（tool_inputから）
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# ファイルパスが取得できない場合は終了
if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# ファイルが存在しない場合は終了
if [[ ! -f "$FILE_PATH" ]]; then
    exit 0
fi

# ファイルのディレクトリを取得
FILE_DIR=$(dirname "$FILE_PATH")

# 拡張子を取得
EXT="${FILE_PATH##*.}"

# プロジェクトルートを探す（package.jsonがある場所）
find_project_root() {
    local dir="$1"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/package.json" ]]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

# prettier実行
run_prettier() {
    local file="$1"
    local project_root="$2"

    if command -v npx &> /dev/null && [[ -n "$project_root" ]]; then
        (cd "$project_root" && npx prettier --write "$file" 2>/dev/null) || true
    elif command -v prettier &> /dev/null; then
        prettier --write "$file" 2>/dev/null || true
    fi
}

# eslint --fix実行
run_eslint() {
    local file="$1"
    local project_root="$2"

    # eslint設定ファイルが存在するか確認
    if [[ -n "$project_root" ]]; then
        local has_eslint_config=false
        for config in ".eslintrc" ".eslintrc.js" ".eslintrc.cjs" ".eslintrc.json" ".eslintrc.yml" ".eslintrc.yaml" "eslint.config.js" "eslint.config.mjs" "eslint.config.cjs"; do
            if [[ -f "$project_root/$config" ]]; then
                has_eslint_config=true
                break
            fi
        done

        # package.jsonにeslintConfigがあるかも確認
        if [[ "$has_eslint_config" == "false" ]] && [[ -f "$project_root/package.json" ]]; then
            if jq -e '.eslintConfig' "$project_root/package.json" &>/dev/null; then
                has_eslint_config=true
            fi
        fi

        if [[ "$has_eslint_config" == "true" ]] && command -v npx &> /dev/null; then
            (cd "$project_root" && npx eslint --fix "$file" 2>/dev/null) || true
        fi
    fi
}

# メイン処理
case "$EXT" in
    # JavaScript/TypeScriptファイル: prettier + eslint --fix
    ts|tsx|js|jsx|mjs|cjs)
        PROJECT_ROOT=$(find_project_root "$FILE_DIR") || PROJECT_ROOT=""
        run_prettier "$FILE_PATH" "$PROJECT_ROOT"
        run_eslint "$FILE_PATH" "$PROJECT_ROOT"
        ;;

    # その他のprettier対象ファイル（eslintは不要）
    json|css|scss|less|md|mdx|yaml|yml|html)
        PROJECT_ROOT=$(find_project_root "$FILE_DIR") || PROJECT_ROOT=""
        run_prettier "$FILE_PATH" "$PROJECT_ROOT"
        ;;

    # Terraformファイルの場合
    tf|tfvars)
        if command -v terraform &> /dev/null; then
            terraform fmt "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
esac

exit 0
