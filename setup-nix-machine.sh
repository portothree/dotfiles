#!/bin/sh

HOST=$2
VALID_ARGS=$(getopt -o sr --long setup,rebuild -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

setup_channels() {
	nix-channel --add https://nixos.org/channels/nixos-unstable unstable
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	nix-channel --add https://github.com/guibou/nixGL/archive/main.tar.gz nixgl
	nix-channel --update
}

rebuild_nixos() {
	sudo nixos-rebuild switch -I nixos-config=./config/nixos/hosts/$HOST/configuration.nix --show-trace
}

rebuild_home_manager() {
	home-manager -f ./config/nixos/hosts/$HOST/home.nix switch
}


eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -S | --setup)
        echo "Initial NixOS setup for host $HOST"
        setup_channels 
		rebuild_nixos
        shift
        ;;
    -s | --setup)
        echo "Initial non-NixOS setup for host $HOST"
        setup_channels 
        shift
        ;;
    -R | --rebuild-nixos)
        echo "Rebuilding NixOS for host $HOST"
        rebuild_nixos
        shift
        ;;
    -r | --rebuild-home)
        echo "Rebuilding home-manager for host $HOST"
        rebuild_home_manager
        shift
        ;;
    --) shift;
        break
        ;;
  esac
done
