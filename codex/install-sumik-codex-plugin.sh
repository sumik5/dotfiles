#!/usr/bin/env bash
# =============================================================================
# install-sumik-codex-plugin.sh
#
# 目的:
#   sumik-llm-plugin リポジトリの Codex プラグインを
#   git marketplace 経由で add（未登録時）/ update（登録済み時）する冪等スクリプト。
#   併せて、本スクリプトと同階層の agents/ と AGENTS.md を ~/.codex/ 配下へ
#   symlink する（既存は上書き）。何度実行しても安全。
#
# 前提:
#   - codex CLI がインストール済みであること
#   - 【重要】このスクリプト実行前に、リポジトリの marketplace.json / plugin.json
#     のリネーム・更新内容を GitHub にプッシュ済みであること。
#     git 方式のため GitHub HEAD の内容が同期される。
#
# 使い方:
#   bash install-sumik-codex-plugin.sh
#
# 環境変数（省略時はデフォルト値を使用）:
#   MARKETPLACE_NAME  登録するマーケットプレイス名（デフォルト: sumik-marketplace）
#   PLUGIN_NAMES      インストールするプラグイン名（スペース区切り・デフォルト:
#                     "devkit studio lang web cloud ai design product exam university google mobile certificate" の13プラグイン）
#   GIT_SOURCE        Git ソース URL（デフォルト: GitHub の sumik-llm-plugin）
#   GIT_REF           Git リファレンス（デフォルト: main）
#   CODEX_HOME        symlink 先の Codex ホーム（デフォルト: ~/.codex）
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# ---------------------------------------------------------------------------
# 色付きログ関数
# ---------------------------------------------------------------------------
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

err() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# ---------------------------------------------------------------------------
# 設定パラメータ（環境変数で上書き可能）
# ---------------------------------------------------------------------------
: "${MARKETPLACE_NAME:=sumik-marketplace}"
: "${GIT_SOURCE:=https://github.com/sumik5/sumik-llm-plugin.git}"
: "${GIT_REF:=main}"
: "${CODEX_HOME:=${HOME}/.codex}"

# インストール対象プラグイン一覧（bash 配列）。
# 環境変数 PLUGIN_NAMES（スペース区切り）で上書き可能。
# 注: スクリプト冒頭で IFS=$'\n\t'（スペース除外）のため、上書き時は
#     read 実行中だけ IFS をスペースに戻して安全に分割する。
if [[ -n "${PLUGIN_NAMES:-}" ]]; then
    IFS=' ' read -r -a PLUGINS <<< "${PLUGIN_NAMES}"
else
    PLUGINS=(devkit studio lang web cloud ai design product exam university google mobile certificate)
fi

# このスクリプト自身のディレクトリ（agents/ と AGENTS.md が同階層にある前提）
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# 前提チェック
# ---------------------------------------------------------------------------
check_prerequisites() {
    if ! command -v codex &>/dev/null; then
        err "codex CLI が見つかりません。インストール後に再実行してください。"
        exit 1
    fi
    info "codex CLI を確認しました: $(command -v codex)"
}

# ---------------------------------------------------------------------------
# 単一アセットを symlink（既存ファイル/ディレクトリ/symlink は上書き）
# ---------------------------------------------------------------------------
link_one_asset() {
    local src="$1" dest="$2"
    if [[ ! -e "${src}" && ! -L "${src}" ]]; then
        warn "ソースが見つかりません: ${src}（スキップ）"
        return 0
    fi
    if [[ -e "${dest}" || -L "${dest}" ]]; then
        rm -rf -- "${dest}"
        info "既存を削除（上書き）: ${dest}"
    fi
    ln -s "${src}" "${dest}"
    info "symlink作成: ${dest} -> ${src}"
}

# ---------------------------------------------------------------------------
# dotfiles の agents/ と AGENTS.md を CODEX_HOME 配下へ symlink（冪等・上書き）
# ---------------------------------------------------------------------------
link_codex_assets() {
    info "Codex アセットを ${CODEX_HOME} へ symlink します（既存は上書き）..."
    if [[ -z "${CODEX_HOME}" ]]; then
        err "CODEX_HOME が空です。安全のため中断します。"
        exit 1
    fi
    mkdir -p "${CODEX_HOME}"
    link_one_asset "${SCRIPT_DIR}/agents"    "${CODEX_HOME}/agents"
    link_one_asset "${SCRIPT_DIR}/AGENTS.md" "${CODEX_HOME}/AGENTS.md"
}

# ---------------------------------------------------------------------------
# マーケットプレイスの add または upgrade
# ---------------------------------------------------------------------------
setup_marketplace() {
    info "マーケットプレイス '${MARKETPLACE_NAME}' の確認中..."

    local registered_names
    registered_names=$(codex plugin marketplace list 2>/dev/null | awk 'NR>1{print $1}') || registered_names=""

    local marketplace_found=false
    while IFS= read -r name; do
        if [[ "${name}" == "${MARKETPLACE_NAME}" ]]; then
            marketplace_found=true
            break
        fi
    done <<< "${registered_names}"

    if [[ "${marketplace_found}" == "true" ]]; then
        info "マーケットプレイス '${MARKETPLACE_NAME}' が登録済みです。upgrade を実行します..."
        codex plugin marketplace upgrade "${MARKETPLACE_NAME}"
        info "マーケットプレイスを最新状態に更新しました。"
    else
        info "マーケットプレイス '${MARKETPLACE_NAME}' が未登録です。add を実行します..."
        codex plugin marketplace add "${GIT_SOURCE}" --ref "${GIT_REF}"
        info "マーケットプレイスを追加しました（source: ${GIT_SOURCE}, ref: ${GIT_REF}）。"
    fi
}

# ---------------------------------------------------------------------------
# プラグインのインストール / 更新
# ---------------------------------------------------------------------------
install_plugin() {
    info "プラグイン ${#PLUGINS[@]} 件を ${MARKETPLACE_NAME} からインストール / 更新中..."
    local plugin
    for plugin in "${PLUGINS[@]}"; do
        info "  -> '${plugin}@${MARKETPLACE_NAME}' を add..."
        codex plugin add "${plugin}@${MARKETPLACE_NAME}"
    done
    info "全プラグインの add コマンドが完了しました。"
}

# ---------------------------------------------------------------------------
# インストール検証
# ---------------------------------------------------------------------------
verify_installation() {
    info "インストール結果を検証中..."

    local plugin_list
    plugin_list=$(codex plugin list 2>/dev/null) || plugin_list=""

    local plugin ok_count=0
    local summary_lines=()
    for plugin in "${PLUGINS[@]}"; do
        local ref="${plugin}@${MARKETPLACE_NAME}"

        # "installed" かつ対象プラグインが含まれるか確認
        if ! echo "${plugin_list}" | grep -q "${ref}"; then
            err "検証失敗: '${ref}' が plugin list に見つかりません。"
            err "--- plugin list 出力 ---"
            echo "${plugin_list}" >&2
            exit 1
        fi

        if ! echo "${plugin_list}" | grep "${ref}" | grep -q "installed"; then
            err "検証失敗: '${ref}' のステータスが 'installed' ではありません。"
            err "--- 該当行 ---"
            echo "${plugin_list}" | grep "${ref}" >&2
            exit 1
        fi

        # バージョン抽出（VERSION 列を取得）
        local version
        version=$(echo "${plugin_list}" | grep "${ref}" | awk '{print $NF}') || version="(不明)"
        summary_lines+=("  ${plugin} : ${version}")
        ok_count=$((ok_count + 1))
    done

    info "検証成功: ${ok_count} 件のプラグインが正常にインストールされています。"
    echo ""
    echo "============================================"
    echo "  完了サマリ"
    echo "============================================"
    echo "  marketplace : ${MARKETPLACE_NAME}"
    echo "  plugins     :"
    local line
    for line in "${summary_lines[@]}"; do
        echo "  ${line}"
    done
    echo "  agents      : ${CODEX_HOME}/agents -> ${SCRIPT_DIR}/agents"
    echo "  AGENTS.md   : ${CODEX_HOME}/AGENTS.md -> ${SCRIPT_DIR}/AGENTS.md"
    echo "============================================"
}

# ---------------------------------------------------------------------------
# メイン処理
# ---------------------------------------------------------------------------
main() {
    echo ""
    info "=== sumik Codex プラグイン インストールスクリプト 開始 ==="
    echo ""

    check_prerequisites
    echo ""

    link_codex_assets
    echo ""

    setup_marketplace
    echo ""

    install_plugin
    echo ""

    verify_installation
    echo ""

    info "=== 完了 ==="
}

main "$@"
