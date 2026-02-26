#!/bin/sh

# 色定義
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# シンボリックリンク作成ヘルパー関数
create_symlink() {
  src="$1"
  dest="$2"

  # リンク先が既に存在するかチェック（-e: 存在, -L: シンボリックリンク）
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    printf "${YELLOW}スキップ:${NC} %s (既に存在)\n" "$dest"
  else
    ln -s "$src" "$dest"
    printf "${GREEN}作成:${NC} %s -> %s\n" "$dest" "$src"
  fi
}

# シンボリックリンクを作成
create_symlink "$HOME/dotfiles/.config/gitui" "$HOME/.config/gitui"
create_symlink "$HOME/dotfiles/.config/nvim" "$HOME/.config/nvim"
create_symlink "$HOME/dotfiles/.config/tmux" "$HOME/.config/tmux"
create_symlink "$HOME/dotfiles/.config/ccstatusline" "$HOME/.config/ccstatusline"
create_symlink "$HOME/dotfiles/.config/ghostty" "$HOME/.config/ghostty"
