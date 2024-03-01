#!/bin/zsh

yellow='\e[33m'
reset='\e[0m'

echo "${yellow}home directory contents${reset}"
rsync -v home-dir/.zshrc ~/.zshrc
# ask if .gitconfig is desired to be synchronized
while true; do
    echo "Do you want to sync .gitconfig? (y/n) "
    read yn

    case $yn in
        [yY] ) rsync -v home-dir/.gitconfig ~/.gitconfig
            break ;;
        [nN] ) ;
            break ;;
        * ) echo invalid response ;;
    esac
done

echo ""

echo "${yellow}alacritty${reset}"
rsync -vaR --delete alacritty/ ~/.config/

echo ""

echo "${yellow}lazygit${reset}"
rsync -vaR lazygit/config.yml ~/.config/

echo ""

echo "${yellow}neofetch${reset}"
rsync -vaR --delete neofetch/ ~/.config/

echo ""

echo "${yellow}nvim${reset}"
rsync -vaR --delete nvim/after/ ~/.config/
rsync -vaR --delete nvim/lua/ ~/.config/
rsync -vaR nvim/init.lua ~/.config/

echo ""

echo "${yellow}tmux${reset}"
rsync -vaR tmux/tmux.conf ~/.config/
