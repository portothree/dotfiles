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
		echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ])" && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm"' >> "$HOME/.zshrc'
		echo '[ -s "NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >>"$HOME/.zshrc"
	elif [[ $CURRENT_SHELL == "bash" ]]; then
		echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ])" && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm"' >> "$HOME/.bashrc'
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
		ranger \
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

	# Build tools
	sudo apt install -y \
		build-essential \
		cmake \
		python3-dev \
		libxft-dev \
		libx11-dev

	# Terminal emulators
	git clone https://git.suckless.org/st $HOME/st

	# Other packages
	sudo apt install -y \
		xautolock \
		unclutter

	config
	setup_st
	setup_vim
}

config() {
	cd $(pwd)
	stow -v bspwm sxhkd compton vim tmux ranger shell st
}

setup_st() {
	cd $HOME/st
	sudo make clean install
}

setup_vim() {
	VIM_PLUGINS_DIR=${HOME}/.vim/pack/plugins/start
	mkdir -p "${VIM_PLUGINS_DIR}"

	# ALE
	git clone --depth 1 https://github.com/dense-analysis/ale.git ${VIM_PLUGINS_DIR}/

	# Vim-polyglot
	git clone --depth 1 https://github.com/sheerun/vim-polyglot.git ${VIM_PLUGINS_DIR}/

	# YouCompleteMe
	git clone https://github.com/ycm-core/YouCompleteMe.git ${VIM_PLUGINS_DIR}/YouCompleteMe
	cd ${VIM_PLUGINS_DIR}/YouCompleteMe
	git submodule update --init --recursive
	python3 install.py --ts-completer --rust-completer
}

manage() {
	while :; do
		echo -e "\n[1] List dotfiles"
		echo -e "\n[2] Install and setup dependencies"
		echo -e "\n[3] Setup dot files"
		echo -e "[q/Q] Quit session"

		read -p "Choose an option: [1]" -n 1 -r USER_INPUT
		USER_INPUT=${USER_INPUT:-1}

		case $USER_INPUT in
		[1]*) find_dotfiles ;;
		[2]*) install_dependencies ;;
		[3]*) config ;;
		[q/Q]*) exit ;;
		*) printf "\n%s\n" "Invalid input" ;;
		esac
	done
}

init_check
