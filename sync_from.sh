#!/bin/zsh

echo "home directory contents"
rsync -v ~/.zshrc home-dir/
rsync -v ~/.gitconfig home-dir/

echo ""

echo "alacritty"
rsync -va --delete ~/.config/alacritty/ alacritty/

echo ""

echo "lazygit"
rsync -va --delete ~/.config/lazygit/config.yml lazygit/

echo ""

echo "neofetch"
rsync -va --delete ~/.config/neofetch/ neofetch/

echo ""

echo "nvim"
mkdir -p nvim/after nvim/lua  # rsync creates folders for just one depth
rsync -va --delete ~/.config/nvim/after/ nvim/after/
rsync -va --delete ~/.config/nvim/lua/ nvim/lua/
rsync -va --delete ~/.config/nvim/init.lua nvim/

echo ""

echo "tmux"
rsync -va --delete ~/.config/tmux/tmux.conf tmux/

