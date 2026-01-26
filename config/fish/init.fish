source ~/.nix-profile/share/asdf-vm/asdf.fish

export SSH_AUTH_SOCK=/Users/gustavoporto/.bitwarden-ssh-agent.sock
/Users/gustavoporto/.local/bin/mise activate fish | source
status --is-interactive; and rbenv init - fish | source
