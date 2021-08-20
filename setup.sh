#!/usr/bin/env bash

DOT_REPO="https://github.com/portothree/dotfiles"
DOT_DEST="$PWD"

init_check() {
	add_env
	manage
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

find_dotfiles() {
	printf "\n"
	readarray -t dotfiles < <( find "${HOME}" -maxdepth 1 -name ".*" -type f)
	printf "%s\n" "${dotfiles[@]}"
}

manage() {
	while :
	do
		echo -e "\n[1] List dotfiles"
		echo -e "[q/Q] Quit session"
		
		read -p "Choose an option: [1]" -n 1 -r USER_INPUT
		USER_INPUT=${USER_INPUT:-1}

		case $USER_INPUT in
			[1]* ) find_dotfiles;;
			[q/Q]* ) exit;;
			* ) printf "\n%s\n" "Invalid input"
		esac
	done
}

init_check
