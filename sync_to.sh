#!/bin/zsh

echo "home directory contents"
rsync -v home-dir/.zshrc ~/.zshrc
rsync -v home-dir/.gitconfig ~/.gitconfig

echo ""

echo "alacritty"
rsync -vaR alacritty/ ~/.config/

echo ""

echo "lazygit"
rsync -vaR lazygit/config.yml ~/.config/

echo ""

echo "neofetch"
rsync -vaR neofetch/ ~/.config/

echo ""

echo "nvim"
rsync -vaR nvim/after/ ~/.config/
rsync -vaR nvim/lua/ ~/.config/
rsync -vaR nvim/init.lua ~/.config/

echo ""

echo "tmux"
rsync -vaR tmux/tmux.conf ~/.config/
