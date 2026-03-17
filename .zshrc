# .zshrc - 対話シェルのみ読まれる
# 責務: 補完・プラグイン・キーバインド・プロンプト・関数・エイリアス

# -------------------------------------------------
# シェルオプション
setopt auto_cd
unsetopt correct
setopt list_packed

# -------------------------------------------------
# ヒストリ
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=$HISTSIZE
# コマンドラインだけでなく実行時刻と実行時間も保存する
setopt extended_history
# 同じコマンドラインを連続で実行した場合はヒストリに登録しない
setopt hist_ignore_dups
# スペースで始まるコマンドラインはヒストリに追加しない
setopt hist_ignore_space
# すぐにヒストリファイルに追記する
setopt inc_append_history
# zshプロセス間でヒストリを共有する
setopt share_history
# C-sでのヒストリ検索が潰されてしまうため使わない
setopt no_flow_control

# -------------------------------------------------
# fpath設定（compinit前に設定する必要がある）
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  FPATH=$HOME/.docker/completions:$FPATH
  FPATH=$(brew --prefix)/share/zsh-abbr:$FPATH
fi
fpath+=~/.zfunc

# -------------------------------------------------
# 補完・autoload
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
# URLをエスケープする
autoload -Uz url-quote-magic
# VCS情報・cdrを有効にする
autoload -Uz add-zsh-hook
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook

setopt prompt_subst

# 文字入力時にURLをエスケープする
zle -N self-insert url-quote-magic

# コマンド補完定義
add-zsh-hook chpwd chpwd_recent_dirs

# -------------------------------------------------
# zstyle補完設定
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:*:cdr:*:*' menu selection
zstyle ':completion:*' recent-dirs-insert both
zstyle ':chpwd:*' recent-dirs-max 500
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-pushd true
zstyle ':filter-select:highlight' matched fg=yellow,standout
zstyle ':filter-select' case-insensitive yes
zstyle ':filter-select' extended-search yes
zstyle ':completion:*' menu select

# -------------------------------------------------
# brew api token
if [ -f ~/.brew_api_token ]; then
  source ~/.brew_api_token
fi

# -------------------------------------------------
# brew-file wrapper
if (( ${+commands[brew]} )); then
  if [ -f $(brew --prefix)/etc/brew-wrap ]; then
    source $(brew --prefix)/etc/brew-wrap
  fi
fi

###################################################
# zplug プラグイン
###################################################

source $ZPLUG_HOME/init.zsh

zplug 'zsh-users/zsh-autosuggestions'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=5'

zplug 'zsh-users/zsh-syntax-highlighting', defer:2
zplug 'mollifier/anyframe'
zplug "mollifier/cd-gitroot"
zplug "mrowa44/emojify", as:command
zplug "b4b4r07/emoji-cli"
zplug "sorin-ionescu/prezto"
zplug "b4b4r07/enhancd", use:enhancd.sh
zplug "rupa/z", use:"*.sh"
zplug "plugins/git", from:oh-my-zsh
zplug "woefe/git-prompt.zsh"
zplug "mafredri/zsh-async", from:github
# for MacOS
zplug "modules/osx", from:prezto, if:"[[ $OSTYPE == *darwin* ]]"
zplug "lib/clipboard", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"

if ! zplug check; then
  zplug install
fi

zplug load

# -------------------------------------------------
# キーバインド
bindkey -e

bindkey '^j^j' anyframe-widget-cdr
bindkey '^j^r' anyframe-widget-execute-history
bindkey '^j^g' anyframe-widget-cd-ghq-repository
bindkey '^j^t' anyframe-widget-tmux-attach

bindkey '^f' forward-word
bindkey '^b' backward-word
bindkey '^d' kill-word

# -------------------------------------------------
# iterm2 shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# -------------------------------------------------
# Google Cloud SDK completion
[ -f /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc ] && source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc

# -------------------------------------------------
# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# -------------------------------------------------
# terraform補完
autoload -U +X bashcompinit && bashcompinit
if [ -f /opt/homebrew/bin/terraform ]; then
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
fi

# -------------------------------------------------
# mise
eval "$(mise activate zsh)"

# -------------------------------------------------
# starship
if command -v starship &> /dev/null; then
  eval "$(starship completions zsh)"
  eval "$(starship init zsh)"
fi

# -------------------------------------------------
# direnv
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# -------------------------------------------------
# colima
if command -v colima &> /dev/null; then
  eval "$(colima completion zsh)"
fi

# -------------------------------------------------
# codex
if command -v codex &> /dev/null; then
  eval "$(codex completion zsh)"
fi

#############################################
# git auto status
#############################################

gitPreAutoStatusCommands=(
  'add'
  'rm'
  'reset'
  'commit'
  'checkout'
  'mv'
  'init'
)

function elementInArray() {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

function git() {
  command git $@

  if (elementInArray $1 $gitPreAutoStatusCommands); then
    command git status
  fi
}

#############################################
# Homebrew 版 trash を優先
#############################################

# rm: -r がある時だけディレクトリ許可、ない時はファイル限定
rm () {
  local recursive=false
  local targets=()

  # 引数を解析
  for arg in "$@"; do
    case "$arg" in
      -r|-rf|-fr) recursive=true ;;               # 再帰フラグ
      --) shift; targets+=("$@"); break ;;        # -- 以降は全部パス
      -*) echo "rm: 未対応オプション $arg" >&2; return 1 ;;
      *)  targets+=("$arg") ;;
    esac
  done

  [[ ${#targets[@]} -eq 0 ]] && {
    echo "rm: 削除対象が指定されていません" >&2
    return 1
  }

  # 判定と実行
  if $recursive; then
    # -r 付き → すべてディレクトリ想定
    for p in "${targets[@]}"; do
      [[ -d "$p" ]] || {
        echo "⚠️  '$p' はディレクトリではありません (-r 不要)" >&2
        return 1
      }
    done
    /opt/homebrew/opt/trash/bin/trash -F -- "${targets[@]}"
  else
    # -r なし → すべてファイル想定
    for p in "${targets[@]}"; do
      [[ -f "$p" ]] || {
        echo "⚠️  '$p' はファイルではありません。フォルダを消す場合は -r を付けてください。" >&2
        return 1
      }
    done
    /opt/homebrew/opt/trash/bin/trash -- "${targets[@]}"
  fi
}

# =================================================
# ghq + peco
# =================================================

peco-cd () {
  cd "$( ghq list --full-path | peco)"
}

# =================================================
# AWS プロファイル選択
# =================================================

function set_aws_profile() {
  # Select AWS PROFILE
  local selected_profile=$(aws configure list-profiles |
    grep -v "default" |
    sort |
    fzf --prompt "Select PROFILE. If press Ctrl-C, unset PROFILE. > " \
        --height 50% --layout=reverse --border --preview-window 'right:50%' \
        --preview "grep {} -A5 ~/.aws/config")

  # If the profile is not selected, unset the environment variable 'AWS_PROFILE', etc.
  if [ -z "$selected_profile" ]; then
    echo "Unset env 'AWS_PROFILE'!"
    unset AWS_PROFILE
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    return
  fi

  # If a profile is selected, set the environment variable 'AWS_PROFILE'.
  echo "Set the environment variable 'AWS_PROFILE' to '${selected_profile}'!"
  export AWS_PROFILE="$selected_profile"
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY

  # Check sso-session
  local AWS_SSO_SESSION_NAME="your 'sso-session' name"  # sso-sessionの名称に変更

  check_sso_session=$(aws sts get-caller-identity 2>&1)
  if [[ "$check_sso_session" == *"Token has expired"* ]]; then
    # If the session has expired, log in again.
    echo -e "\n----------------------------\nYour Session has expired! Please login...\n----------------------------\n"
    aws sso login --sso-session "${AWS_SSO_SESSION_NAME}"
    aws sts get-caller-identity
  else
    # Display account information upon successful login, and show an error message upon login failure.
    echo ${check_sso_session}
  fi
}

# =================================================
# 環境別設定ファイルの読み込み（最後に読み込んで最優先）
# =================================================
# 優先順位（後から読み込まれるものが優先）:
# 1. .zshrc.local   - ローカル環境固有の設定
# 2. .zshrc.work    - 仕事環境用の設定
# 3. .zshrc.home    - 自宅環境用の設定
# 4. .zshrc.private - プライベートな設定（gitignoreに追加推奨）
# 5. .zshrc.$(hostname -s) - ホスト名固有の設定

# ベースとなる環境別設定
for env_file in local work home private; do
  if [ -f "$HOME/.zshrc.$env_file" ]; then
    source "$HOME/.zshrc.$env_file"
  fi
done

# ホスト名ベースの設定（最優先）
HOST_CONFIG="$HOME/.zshrc.$(hostname -s)"
if [ -f "$HOST_CONFIG" ]; then
  source "$HOST_CONFIG"
fi

# =================================================
# abbr
# =================================================
ABBR_QUIET=1
source /opt/homebrew/share/zsh-abbr/zsh-abbr.zsh

{
  abbr -S -f ll='ls -vl'
  abbr -S -f greps='rg --hidden -p'
  abbr -S -f gcautog="gcauto -m gemini"
  abbr -S -f vi="nvim"
  abbr -S -f vim="nvim"
  abbr -S -f code-review="coderabbit review --prompt-only"
  abbr -S -f claude="claude --teammate-mode tmux --dangerously-skip-permissions"
  abbr -S -f codex="codex --dangerously-bypass-approvals-and-sandbox"
  abbr -S -f docker="podman"
  abbr -S -f docker-comopse="podman-compose"
  abbr -S -f htop='sudo htop'
  abbr -S -f ghq='peco-cd'
  abbr -S -f gcauto='gcauto -m codex'
} &>/dev/null

