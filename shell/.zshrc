# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Go
export PATH=$PATH:/usr/local/go/bin
 
export VISUAL=vim
export EDITOR=vim
export TERM="xterm-256color"

export HISTTIMEFORMAT="%F %T "

# Path to your oh-my-zsh installation.
export ZSH="/home/porto/.oh-my-zsh"

# Fixes anki video gliteches
export ANKI_NOHIGHDPI=1
export ANKI_WEBSCALE=1

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

alias r="ranger"
