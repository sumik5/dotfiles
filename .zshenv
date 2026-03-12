# anyenvのpathが２重に登録されてしまう問題への対処
# http://chieping.hatenablog.com/entry/2013/09/03/011507
if [ -x /usr/libexec/path_helper ]; then
  PATH=""
  eval `/usr/libexec/path_helper -s`
fi

# Codexのような非対話・非ログインシェルでも同じPATHを使えるようにする
typeset -gU path PATH
path=(
  /Applications/TeXLive/Library/texlive
  /Applications/TeXLive/Library/mactexaddons
  $HOME/dotfiles/bin
  $HOME/.cabal/bin
  $HOME/Dropbox/bin
  $HOME/.local/share/mise/shims
  $HOME/.local/bin
  $HOME/idea/bin
  $HOME/.lmstudio/bin
  $HOME/Library/pnpm
  /opt/homebrew/bin
  /opt/homebrew/sbin
  /usr/local/heroku/bin
  /usr/local/bin
  /usr/local/sbin
  /usr/local/share/zsh/site-functions
  /usr/local/opt/avr-gcc@7/bin
  /opt/homebrew/opt/coreutils/libexec/gnubin
  /opt/homebrew/opt/llvm/bin
  /opt/homebrew/opt/trash/bin
  /Library/TeX/texbin
  /opt/homebrew/opt/postgresql@15/bin
  $HOME/.antigravity/antigravity/bin
  $path
)

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi
