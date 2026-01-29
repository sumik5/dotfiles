#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles/claude-code"
CLAUDE_DIR="$HOME/.claude"

# .claudeディレクトリが存在しない場合は作成
mkdir -p "$CLAUDE_DIR"

# シンボリックリンク作成関数
create_symlink_if_not_exists() {
    local source=$1
    local target=$2

    if [ -L "$target" ]; then
        echo "スキップ: $target (既にシンボリックリンクが存在します)"
    elif [ -e "$target" ]; then
        echo "警告: $target は存在しますがシンボリックリンクではありません"
        echo "  手動で確認してください: ls -l $target"
    else
        ln -sf "$source" "$target"
        echo "作成: $target -> $source"
    fi
}

echo "シンボリックリンクのセットアップを開始します..."
echo ""

# 各ファイル・ディレクトリのシンボリックリンクを作成
create_symlink_if_not_exists "$DOTFILES_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
create_symlink_if_not_exists "$DOTFILES_DIR/settings.json" "$CLAUDE_DIR/settings.json"
create_symlink_if_not_exists "$DOTFILES_DIR/hooks" "$CLAUDE_DIR/hooks"
create_symlink_if_not_exists "$DOTFILES_DIR/rules" "$CLAUDE_DIR/rules"

echo ""
echo "完了しました"
