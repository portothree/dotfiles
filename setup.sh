#!/usr/bin/env bash

DOT_REPO="https://github.com/portothree/dotfiles"
DOT_DEST="$PWD"

init_check() {
	add_env
}

add_env() {
	echo -e "\nExporting env variables DOT_DEST & DOT_REPO"

	current_shell=$(basename "$SHELL")

	if [[ $current_shell == "zsh" ]]; then
		echo "export DOT_REPO=$DOT_REPO" >> "$HOME/.zshrc"
		echo "export DOT_DEST=$DOT_DEST" >> "$HOME/.zshrc"
	elif [[ $current_shell == "bash" ]]; then
		echo "export DOT_REPO=$DOT_REPO" >> "$HOME/.bashrc"
		echo "export DOT_DEST=$DOT_DEST" >> "$HOME/.bashrc"
	else
		echo "Couldn't export DOT_DEST and DOT_REPO"
		echo "Consider exporting them manually"
		exit 1
	fi
	echo -e "Configuration for SHELL: $current_shell has been updated"
}

init_check
