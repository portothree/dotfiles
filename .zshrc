# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
 
export VISUAL=vim
export EDITOR=vim
export TERM="xterm-256color"

export HISTTIMEFORMAT="%F %T "

# Homebrew
export PATH="$HOME/.linuxbrew/bin:$HOME/.linuxbrew/sbin:$PATH"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"

# Lazy load nvm
start_nvm() {
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}
 
# Path to your oh-my-zsh installation.
export ZSH="/home/porto/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

alias r="ranger"
