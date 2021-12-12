# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Go
export GO111MODULE=on
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

plugins=(git git-auto-fetch)

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

# Pyenv
export PYTHON_CONFIGURE_OPTS="--enable-shared"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
	eval "$(pyenv init -)"
	eval "$(pyenv init --path)"
fi

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

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Fix GLX in nix
export QT_XCB_GL_INTEGRATION=none

# ADR
export PATH="$HOME/adr-tools/src:$PATH"

# Taskwarrior
export TASKWARRIOR_LOCATION_PATH="$HOME/www/memex/trails/tasks/.task"

# Llama
function llm {
  llama "$@" 2> /tmp/path && cd "$(cat /tmp/path)"
}
