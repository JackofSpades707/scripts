#!/usr/bin/env bash

function upgrade(){
    apt-get update -y
    apt-get upgrade -y
    apt-get dist-upgrade -y
}

function _install(){
    apt-get install "${@}" -y
}

function locale(){
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
    locale-gen
}

function install(){
pkgs=(echo curl wget sudo tmux build-essential zsh git python3 python3-pip xclip)
for pkg in $pkgs; do
    echo "[+] Installing $pkg"
    _install $pkg
done
echo '[+] Installing oh-my-zsh'
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
cat<<EOF > ~/.zshrc
export ZSH=/root/.oh-my-zsh
ZSH_THEME="agnoster"
plugins=(git)
source $ZSH/oh-my-zsh.sh
EOF
}

function Main(){
    upgrade
    locale
    install
}
