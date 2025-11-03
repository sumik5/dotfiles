#!/bin/bash
set -euo pipefail

# プロジェクト名を取得
PROJECT_NAME=$(basename "$PWD")
MESSAGE="${PROJECT_NAME}、完了"

# 設定
NOTIFICATION_SOUND="Glass"  # 通知音を変更する場合はここを編集
DISPLAY_DURATION=5          # 通知の表示時間（秒）

# === 利用可能な通知音 ===
# Basso      - 低音
# Blow       - 風の音
# Bottle     - ボトル音
# Frog       - カエルの鳴き声
# Funk       - ファンキーな音
# Glass      - ガラス音（デフォルト）
# Hero       - ヒーロー音
# Morse      - モールス信号
# Ping       - シンプルなピン音
# Pop        - ポップ音
# Purr       - 猫の喉鳴らし
# Sosumi     - クラシックなMac音
# Submarine  - 潜水艦音
# Tink       - 金属音
# ※ 通知音を無効にする場合は NOTIFICATION_SOUND="" に設定

# 音声通知（バックグラウンドで実行）
#say -v Victoria "${MESSAGE}" &

# 通知センターに表示（表示時間付き）
if ! osascript <<EOF 2>/dev/null
display notification "${MESSAGE}" \
    with title "Claude Code" \
    subtitle "プロジェクト: ${PROJECT_NAME}" \
    sound name "${NOTIFICATION_SOUND}"

-- 指定秒数待機（通知を表示し続ける）
delay ${DISPLAY_DURATION}
EOF
then
    # osascriptが失敗した場合は音声のみ
    echo "通知の表示に失敗しましたが、音声通知は実行されました" >&2
fi

# 音声通知の完了を待つ
wait

echo "通知完了: ${PROJECT_NAME}"
