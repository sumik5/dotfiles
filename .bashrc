# -------------------------------------------------
# Source global definitions
if [ -f /etc/bashrc ]; then
  source /etc/bashrc
fi

# -------------------------------------------------
# prompt color set
RESET=$(tput sgr0)
DARK_GRAY=$(tput setaf 0)
GREEN=$(tput setaf 2)
ORANGE=$(tput setaf 3)
MAGENTA=$(tput setaf 5)

# -------------------------------------------------
# common os environment settings
TERM=xterm-color
PS1='[\u@\h \W]\$ '
OSTYPE=`uname`
HISTTIMEFORMAT='%Y-%m-%d %T '
HISTSIZE=10000
TERM=xterm-256color

# -------------------------------------------------
# set alias
alias grep='grep -E --color=auto'
alias vi='vim'

# -------------------------------------------------
# import

# add git repository name in PS1
if [ -a $HOME/.git-completion.bash ]; then
  source $HOME/.git-completion.bash
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/sumik/.lmstudio/bin"
export PATH="$HOME/.local/share/mise/shims:$PATH"
# End of LM Studio CLI section

# =================================================
# 環境別設定ファイルの読み込み（最後に読み込んで最優先）
# =================================================
# 優先順位（後から読み込まれるものが優先）:
# 1. .bashrc.local   - ローカル環境固有の設定
# 2. .bashrc.work    - 仕事環境用の設定
# 3. .bashrc.home    - 自宅環境用の設定
# 4. .bashrc.private - プライベートな設定（gitignoreに追加推奨）
# 5. .bashrc.$(hostname -s) - ホスト名固有の設定

# ベースとなる環境別設定
for env_file in local work home private; do
  if [ -f "$HOME/.bashrc.$env_file" ]; then
    source "$HOME/.bashrc.$env_file"
    # デバッグ用（必要に応じてコメントアウト）
    # echo "Loaded: .bashrc.$env_file"
  fi
done

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

alias claude-mem='bun "$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
