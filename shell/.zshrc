export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin/:/sbin"

# nix
export PATH="/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:$PATH"
export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}

PROMPT="%(?.%F{green}.%F{red})λ%f %B%F{cyan}%~%f%b "
MEMEX="$HOME/www/memex"
export VISUAL=vim
export EDITOR=vim
export TERM="xterm-256color"
export GO111MODULE=on
export HISTTIMEFORMAT="%F %T "
export ZSH="$HOME/.oh-my-zsh"
export ANKI_NOHIGHDPI=1
export ANKI_WEBSCALE=1

ZSH_THEME="robbyrussell"
plugins=(git git-auto-fetch)
source $ZSH/oh-my-zsh.sh

[[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)

source "$(fzf-share)/key-bindings.zsh"
source "$(fzf-share)/completion.zsh"
export FZF_DEFAULT_COMMAND="rg --files | fzf"

export PATH="$HOME/adr-tools/src:$PATH"

export TASKWARRIOR_LOCATION_PATH="$HOME/$MEMEX/trails/tasks/.task"

eval "$(direnv hook zsh)"

# Aliases
alias r="ranger"
alias nvtop="nixGLNvidia-390.144 nvtop"
alias rgf="rg --files | rg"
alias krita="QT_XCB_GL_INTEGRATION=none krita"
alias k8s-show-ns="kubectl api-resources --verbs=list --namespaced -o name | xargs -n1 kubectl get "$@" --show-kind --ignore-not-found" 
alias k8s-delete-all-ns='kubectl delete "$(kubectl api-resources --namespaced=true --verbs=delete -o name | tr "\n" "," | sed -e 's/,$//')" --all'


# Load crontab from .crontab file
if test -z $CRONTABCMD; then export CRONTABCMD=$(which crontab)

  crontab() { if [[ $@ == "-e" ]]; then
      vim "$HOME/.crontab" && $CRONTABCMD "$HOME/.crontab"
    else $CRONTABCMD $@
    fi
  }

  $CRONTABCMD "$HOME/.crontab"
fi

# Load nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
autoload -U add-zsh-hook
load-nvmrc() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
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
		nvm use default
	fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
