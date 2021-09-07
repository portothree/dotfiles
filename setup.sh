#!/usr/bin/env bash
# describe: Debian porto setup

DOT_REPO="https://github.com/portothree/dotfiles"
DOT_DEST="$PWD"
CURRENT_SHELL=$(basename "$SHELL")
VIM_DIR=/usr/src/vim
VIM_PLUGINS_DIR=${HOME}/.vim/pack/plugins/start
VIMRUNTIMEDIR=/usr/local/share/vim/vim82
LUA_DIR=/usr/local/lua
LUAROCKS_DIR=/usr/local/luarocks
GO_DIR=/usr/local/go
NYXT_DIR=/usr/local/nyxt

init() {
	add_env
	manage

	# Increase system's file watchers limit
	echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
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
		git \
		tmux \
		stow \
		zsh

	# Multimedia
	sudo apt install -y \
		pavucontrol

	# Build tools
	sudo apt install -y \
		build-essential \
		checkinstall \
		cmake \
		ruby-dev \
		lua5.2 \
		liblua5.2-dev \
		libperl-dev \
		python2-dev \
		python3-dev \
		python3-pip \
		libxft-dev \
		libx11-dev \
		libgtk2.0-dev \
		libatk1.0-dev \
		libcairo2-dev \
		libx11-dev \
		libxpm-dev \
		libxt-dev \
		libssl-dev \
		zlib1g-dev \
		libbz2-dev \
		libreadline-dev \
		libsqlite3-dev \
		llvm \
		libncurses5-dev \
		libncursesw5-dev \
		xz-utils \
		tk-dev \
		libffi-dev \
		liblzma-dev

	# Terminal emulators
	git clone https://git.suckless.org/st $HOME/st

	# Other packages
	sudo apt install -y \
		xautolock \
		xinput \
		unclutter \
		acpi

	# Code formatters
	# TODO: setup go before executing this
	GO111MODULE=on go get mvdan.cc/sh/v3/cmd/shfmt

	# Pyenv
	curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash

	# Luarocks
	sudo curl "https://luarocks.org/releases/luarocks-3.7.0.tar.gz" --output "/usr/local/luarocks-3.7.0.ta.gz"

	# NVM
	curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh" | bash

	# Go
	sudo curl "https://golang.org/dl/go1.17.linux-amd64.tar.gz" --output "/usr/local/go-1.17.tar.gz"

	# Nyxt browser
	sudo curl "https://nyxt.atlas.engineer/static/release/nyxt-linux-2.1.1.tar.xz" --output "/usr/local/nyxt-2.1.1.tar.xz"
}

config() {
	cd $(pwd)
	stow -v bspwm sxhkd compton vim tmux ranger shell st
}

setup_oh_my_zsh() {
	sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
}

setup_go() {
	sudo mkdir $GO_DIR
	sudo tar -C $GO_DIR -xzf /usr/local/go-1.17.tar.gz
}

setup_lua() {
	sudo mkdir $LUA_DIR
	sudo mkdir $LUAROCKS_DIR
	# Luarocks
	tar -C $LUAROCKS_DIR -zxpf /usr/local/luarocks-3.7.0.tar.gz
	cd $LUAROCKS_DIR
	./configure && make && make install
	sudo luarocks install luasocket
}

setup_node() {
	echo -e "\nInstalling Node LTS and NPM"

	nvm install --lts
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

	sudo git clone https://github.com/vim/vim.git $VIM_DIR/
	cd $VIM_DIR
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
	sudo make VIMRUNTIMEDIR=$VIMRUNTIMEDIR
	sudo make install
	
	mkdir -p "${VIM_PLUGINS_DIR}"

	# ALE
	git clone --depth 1 https://github.com/dense-analysis/ale.git ${VIM_PLUGINS_DIR}/ale

	# Vim-polyglot
	git clone --depth 1 https://github.com/sheerun/vim-polyglot.git ${VIM_PLUGINS_DIR}/polyglot

	# YouCompleteMe
	git clone https://github.com/ycm-core/YouCompleteMe.git ${VIM_PLUGINS_DIR}/YouCompleteMe
	cd ${VIM_PLUGINS_DIR}/YouCompleteMe
	git submodule update --init --recursive
	python3 install.py --ts-completer --rust-completer

	cd $DOT_DEST
}

setup_nyxt() {
	sudo tar -C $NYXT_DIR -xf /usr/local/nyxt-2.1.1.tar.xz
}

setup_tablet() {
	MONITOR="DP-0"
	ID_STYLUS=`xinput | grep "Pen stylus" | cut -f 2 | cut -c 4-5`

	xinput map-to-output $ID_STYLUS $MONITOR
}

manage() {
	while :
	do
		echo -e "\n[1] List dotfiles"
		echo -e "\n[2] Install and setup dependencies"
		echo -e "\n[3] Setup dot files"
		echo -e "\n[4] Setup Node"
		echo -e "\n[5] Setup GO"
		echo -e "\n[6] Setup LUA"
		echo -e "\n[7] Setup STTerm"
		echo -e "\n[8] Setup VIM"
		echo -e "[q/Q] Quit session"

		read -p "Choose an option: [1]" -n 1 -r USER_INPUT
		USER_INPUT=${USER_INPUT:-1}

		case $USER_INPUT in
		[1]*) find_dotfiles ;;
		[2]*) install_dependencies ;;
		[3]*) config ;;
		[4]*) setup_node ;;
		[5]*) setup_go ;;
		[6]*) setup_lua ;;
		[7]*) setup_st ;;
		[8]*) setup_vim ;;
		[q/Q]*) exit ;;
		*) printf "\n%s\n" "Invalid input" ;;
		esac
	done
}

init
