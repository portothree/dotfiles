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
	curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh" | bash

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
		checkinstall \
		cmake \
		python2-dev \
		python3-dev \
		libxft-dev \
		libx11-dev \
		libncurses5-dev \
		libgtk2.0-dev \
		libatk1.0-dev \
		libcairo2-dev \
		libx11-dev \
		libxpm-dev \
		libxt-dev \
		ruby-dev \
		lua5.2 \
		liblua5.2-dev \
		libperl-dev

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

setup_node() {
	echo -e "\nInstalling NVM, NODE and NPM"

	if [[ $CURRENT_SHELL == "zsh" ]]; then
		echo 'export NVM_DIR="$HOME/.nvm"' >> "$HOME/.zshrc"
		echo '[ -s "NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >>"$HOME/.zshrc"
		echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >>"$HOME/.zshrc"
		nvm install --lts
	elif [[ $CURRENT_SHELL == "bash" ]]; then
		echo 'export NVM_DIR="$HOME/.nvm"' >> "$HOME/.bashrc"
		echo '[ -s "NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >>"$HOME/.bashrc"
		echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >>"$HOME/.bashrc"
		nvm install --lts
	else
		echo "Couldn't start NVM"
		echo "Consider configuring it manually"
		exit 1
	fi
}

setup_st() {
	cd $HOME/st
	sudo make clean install
}

setup_vim() {
	sudo apt remove \
		vim \
		vim-runtime \
		gvim \
		vim-tiny \
		vim-common \
		vim-gui-common \
		vim-nox

	cd /usr/src
	git clone https://github.com/vim/vim.git
	cd vim
	sudo ./configure --with-features=huge \
		--enable-multibyte \
		--enable-rubyinterp=yes \
		--enable-python3interp=yes \
		--with-python3-config-dir=$(python3-config --configdir) \
		--enable-perlinterp=yes \
		--enable-luainterp=yes \
		--enable-gui=gtk2 \
		--enable-cscope \
		--prefix=/usr/local
	make VIMRUNTIMEDIR=/usr/local/share/vim/vim82
	sudo checkinstall

	# Set vim as default editor with update-alternatives
	sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
	sudo update-alternatives --set editor /usr/local/bin/vim
	sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
	sudo update-alternatives --set vi /usr/local/bin/vim

	VIM_PLUGINS_DIR=${HOME}/.vim/pack/plugins/start
	mkdir -p "${VIM_PLUGINS_DIR}"

	# ALE
	git clone --depth 1 https://github.com/dense-analysis/ale.git ${VIM_PLUGINS_DIR}/ale

	# Vim-polyglot
	git clone --depth 1 https://github.com/sheerun/vim-polyglot.git ${VIM_PLUGINS_DIR}/polyglot

	# YouCompleteMe
	git clone https://github.com/ycm-core/YouCompleteMe.git ${VIM_PLUGINS_DIR}/YouCompleteMe
	cd ${VIM_PLUGINS_DIR}/YouCompleteMe
	git submodule update --init --recursive
	sudo python3 install.py --ts-completer --rust-completer
}

manage() {
	while :
	do
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
