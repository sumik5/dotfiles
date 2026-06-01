# .zprofile - ログインシェルのみ読まれる
# 責務: ログイン時にのみ実行される初期化処理

# -------------------------------------------------
# デフォルトパーミッション
umask 022

# -------------------------------------------------
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# -------------------------------------------------
# macOS path_helper（/etc/paths, /etc/paths.d を処理）
if [ -f /usr/libexec/path_helper ]; then
  eval `/usr/libexec/path_helper -s`
fi

# -------------------------------------------------
# WezTerm tmux shim を本物 tmux より優先
# brew shellenv / path_helper が PATH を再構築し $HOME/dotfiles/bin を
# /opt/homebrew/bin の後ろへ押しやるため、ここで先頭へ再宣言する。
# （typeset -gU path により重複は自動排除される）
path=("$HOME/dotfiles/bin" $path)

# -------------------------------------------------
# 一時ディレクトリ
if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$LOGNAME"
  mkdir -p -m 700 "$TMPDIR"
fi
TMPPREFIX="${TMPDIR%/}/zsh"

# -------------------------------------------------
# macOS固有
if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
  export HOMEBREW_CASK_OPTS="--appdir=/Applications"
  export ANDROID_HOME='/usr/local/opt/android-sdk'
fi
export HOMEBREW_NO_ANALYTICS=1

# -------------------------------------------------
# Less前処理（lesspipe）
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi
