#!/usr/bin/env bash
# describe: Debian porto setup

initial_setup() {
	# Increase system's file watchers limit
	echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
}

install_nix() {
	sh <(curl -L https://nixos.org/nix/install) --daemon
}

install_weeslack() {
	mkdir -p $HOME/.weechat/python/autoload
	cd $HOME/.weechat/python
	curl -O https://raw.githubusercontent.com/wee-slack/wee-slack/master/wee_slack.py
	ln -s ../wee_slack.py autoload
}

install_vim_plugins() {
	rm -rf ${VIM_PLUGINS_DIR}
	mkdir -p ${VIM_PLUGINS_DIR}

	# Vimwiki
	git clone https://github.com/vimwiki/vimwiki ${VIM_PLUGINS_DIR}/vimwiki

	# Ledger
	git clone --depth 1 https://github.com/ledger/vim-ledger ${VIM_PLUGINS_DIR}/ledger

	# Dirsettings
	git clone https://github.com/chazy/dirsettings ${VIM_PLUGINS_DIR}/dirsettings

	# ALE
	git clone --depth 1 https://github.com/dense-analysis/ale.git ${VIM_PLUGINS_DIR}/ale

	# Polyglot
	git clone --depth 1 https://github.com/sheerun/vim-polyglot.git ${VIM_PLUGINS_DIR}/polyglot

	# Airline
	git clone https://github.com/vim-airline/vim-airline ${VIM_PLUGINS_DIR}/airline

	# NERDTree
	git clone https://github.com/preservim/nerdtree ${VIM_PLUGINS_DIR}/nerdtree

	# Prettier
	git clone https://github.com/prettier/vim-prettier ${VIM_PLUGINS_DIR}/prettier

	# YouCompleteMe
	git clone https://github.com/ycm-core/YouCompleteMe.git ${VIM_PLUGINS_DIR}/youcompleteme
	(cd ${VIM_PLUGINS_DIR}/youcompleteme; git submodule update --init --recursive)
	(cd ${VIM_PLUGINS_DIR}/youcompleteme; python3 install.py --ts-completer --rust-completer)
}

setup_tablet() {
	MONITOR="DP-0"
	ID_STYLUS=`xinput | grep "Pen stylus" | cut -f 2 | cut -c 4-5`

	xinput map-to-output $ID_STYLUS $MONITOR
}

init() {
	while :
	do
		echo -e "\n[1] Install nix"
		echo -e "\n[1] Setup tablet"
		echo -e "[q/Q] Quit session"

		read -p "Choose an option: [1]" -n 1 -r USER_INPUT
		USER_INPUT=${USER_INPUT:-1}

		case $USER_INPUT in
		[1]*) install_nix ;;
		[1]*) setup_tablet ;;
		[q/Q]*) exit ;;
		*) printf "\n%s\n" "Invalid input" ;;
		esac
	done
}

init
