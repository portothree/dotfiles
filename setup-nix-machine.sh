#!/bin/sh

HOST=$2
VALID_ARGS=$(getopt -o sr --long setup,rebuild -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi


rebuild() {
	sudo nixos-rebuild switch -I nixos-config=./config/nixos/hosts/$HOST/configuration.nix --show-trace
}


initial_setup() {
	sudo nix-channel --add https://nixos.org/channels/nixos-unstable unstable
	sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	sudo nix-channel --update
	
	rebuild
}


eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -s | --setup)
        echo "Initial setup for host $HOST"
        initial_setup 
        shift
        ;;
    -r | --rebuild)
        echo "Rebuilding host $HOST"
        rebuild
        shift
        ;;
    --) shift;
        break
        ;;
  esac
done
