#!/usr/bin/env bash
# describe: Debian porto setup

DOT_REPO="https://github.com/portothree/dotfiles"
DOT_DEST="$PWD"
CURRENT_SHELL=$(basename "$SHELL")

init_check() {
	add_env
	manage
}

add_env() {
	echo -e "\nExporting env variables DOT_DEST & DOT_REPO"

	if [[ $CURRENT_SHELL == "zsh" ]]; then
		echo "export DOT_REPO=$DOT_REPO" >>"$HOME/.zshrc"
		echo "export DOT_DEST=$DOT_DEST" >>"$HOME/.zshrc"
	elif [[ $CURRENT_SHELL == "bash" ]]; then
		echo "export DOT_REPO=$DOT_REPO" >>"$HOME/.bashrc"
		echo "export DOT_DEST=$DOT_DEST" >>"$HOME/.bashrc"
	else
		echo "Couldn't export DOT_DEST and DOT_REPO"
		echo "Consider exporting them manually"
		exit 1
	fi
	echo -e "Configuration for SHELL: $current_shell has been updated"
}

find_dotfiles() {
	printf "\n"
	readarray -t dotfiles < <(find "${HOME}" -maxdepth 1 -name ".*" -type f)
	printf "%s\n" "${dotfiles[@]}"
}

install_dependencies() {
	# NVM
	echo -e "\nInstalling NVM, NODE and NPM"
	curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh" | bash

	if [[ $CURRENT_SHELL == "zsh" ]]; then
		echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ])" && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm"" >> "$HOME/.zshrc'
		echo '[ -s "NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >>"$HOME/.zshrc"
	elif [[ $CURRENT_SHELL == "bash" ]]; then
		echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ])" && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm"" >> "$HOME/.bashrc'
		echo '[ -s "NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >>"$HOME/.bashrc"
	else
		echo "Couldn't start NVM"
		echo "Consider configuring it manually"
		exit 1
	fi

	# BSPWM and related core components
	sudo apt install -y \
		bspwm \
		sxhkd \
		rofi \
		compton \
		dunst \
		libnotify-bin \
		unifont \
		suckless-tools

	# Fonts
	sudo apt install -y \
		fonts-firacode \
		fonts-hack \
		fonts-noto-color-emoji \
		fonts-symbola

	# Terminal tools
	sudo apt install -y \
		vim \
		git \
		tmux \
		stow

	# Multimedia
	sudo apt install -y \
		pavucontrol

	# Other packages
	sudo apt install -y \
		xautolock
}

config() {
	cd $(pwd)
	stow -v bspwm sxhkd compton vim tmux ranger
}

manage() {
	while :; do
		echo -e "\n[1] List dotfiles"
		echo -e "\n[2] Install dependencies"
		echo -e "[q/Q] Quit session"

		read -p "Choose an option: [1]" -n 1 -r USER_INPUT
		USER_INPUT=${USER_INPUT:-1}

		case $USER_INPUT in
		[1]*) find_dotfiles ;;
		[2]*) install_dependencies ;;
		[q/Q]*) exit ;;
		*) printf "\n%s\n" "Invalid input" ;;
		esac
	done
}

init_check
