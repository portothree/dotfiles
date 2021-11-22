# Setup fzf
# ---------
if [[ ! "$PATH" == */home/porto/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/porto/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/porto/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/porto/.fzf/shell/key-bindings.zsh"
