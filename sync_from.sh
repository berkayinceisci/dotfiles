#!/bin/zsh

yellow='\e[33m'
reset='\e[0m'

echo "${yellow}home directory contents${reset}"
rsync -v ~/.zshrc home-dir/
# ask if .gitconfig is desired to be synchronized
while true; do
    echo "Do you want to sync .gitconfig? (y/n) "
    read yn

    case $yn in
        [yY] ) rsync -v ~/.gitconfig home-dir/;
            break ;;
        [nN] ) ;
            break ;;
        * ) echo invalid response ;;
    esac
done

echo ""

echo "${yellow}lazygit${reset}"
rsync -va ~/.config/lazygit/config.yml lazygit/

echo ""

echo "${yellow}nvim${reset}"
mkdir -p nvim/after nvim/lua  # rsync creates folders for just one depth
rsync -va --delete ~/.config/nvim/after/ nvim/after/
rsync -va --delete ~/.config/nvim/lua/ nvim/lua/
rsync -va ~/.config/nvim/init.lua nvim/

echo ""

echo "${yellow}tmux${reset}"
rsync -va ~/.config/tmux/tmux.conf tmux/

