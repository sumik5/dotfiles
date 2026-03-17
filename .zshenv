# .zshenv - 全シェルで読まれる（非対話・非ログインシェル含む）
# 責務: 非対話・非ログインシェル（Codex等）でも使える環境の基盤

# -------------------------------------------------
# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# -------------------------------------------------
# 重複排除
typeset -gU cdpath fpath mailpath path

# -------------------------------------------------
# PATH（一元管理）
# (N-/): 存在しないディレクトリは登録しない
path=(
  /Applications/TeXLive/Library/texlive(N-/)
  /Applications/TeXLive/Library/mactexaddons(N-/)
  $HOME/dotfiles/bin(N-/)            # original dotfiles bin
  $HOME/.cabal/bin(N-/)              # haskell package manager
  $HOME/Dropbox/bin(N-/)
  $HOME/.local/share/mise/shims(N-/)
  $HOME/.local/bin(N-/)
  $HOME/idea/bin(N-/)
  $HOME/.lmstudio/bin(N-/)
  $HOME/Library/pnpm(N-/)
  $HOME/.antigravity/antigravity/bin(N-/)
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  /usr/local/heroku/bin(N-/)         # heroku toolbelt
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /usr/local/opt/avr-gcc@7/bin(N-/)
  /opt/homebrew/opt/coreutils/libexec/gnubin(N-/)
  /opt/homebrew/opt/llvm/bin(N-/)
  /opt/homebrew/opt/trash/bin(N-/)
  /Library/TeX/texbin(N-/)
  /opt/homebrew/opt/postgresql@15/bin(N-/)
  $path
)

# -------------------------------------------------
# エディタ・ページャ
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

# GPG（git commit署名用）
export GPG_TTY=$(tty)

# -------------------------------------------------
# 言語
if [[ -z "$LANG" ]]; then
  export LANG='ja_JP.UTF-8'
fi

# -------------------------------------------------
# Less
export LESS='-F -g -i -M -R -S -w -X -z-4'

# -------------------------------------------------
# コンパイラフラグ（llvm）
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

# -------------------------------------------------
# 各種ツール設定
export GITHUB_URL=https://github.com/
export PNPM_HOME="$HOME/Library/pnpm"
export STARSHIP_CONFIG="$HOME/.starship.toml"
export OBSIDIAN='~/Dropbox/obsidian/'
export ENABLE_LSP_TOOL=1
export COPILOT_MODEL=gpt-5
export CLICOLOR=1
export ZPLUG_HOME=$HOME/.zplug
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
