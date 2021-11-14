# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Go
export GO111MODULE=on
 
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

# NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use

autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# Python poetry 
export PATH="$HOME/.poetry/bin:$PATH"

# K8S kubectl 
[[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)

# Load crontab from .crontab file
if test -z $CRONTABCMD; then
  export CRONTABCMD=$(which crontab)

  crontab() {
    if [[ $@ == "-e" ]]; then
      vim "$HOME/.crontab" && $CRONTABCMD "$HOME/.crontab"
    else
      $CRONTABCMD $@
    fi
  }

  $CRONTABCMD "$HOME/.crontab"
fi
  

export DOT_REPO=https://github.com/portothree/dotfiles
export DOT_DEST=/home/porto/dotfiles
export DOT_REPO=https://github.com/portothree/dotfiles
export DOT_DEST=/home/porto/dotfiles
