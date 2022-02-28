#!/bin/bash

MACHINE=$2
VALID_ARGS=$(getopt -o sr --long setup,rebuild -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi


rebuild_machine() {
	export NIXOS_CONFIG="./config/nixos/machines/$MACHINE/configuration.nix"
	sudo nixos-rebuild switch -I $NIXOS_CONFIG
}


initial_setup() {
	sudo nix-channel --add https://nixos.org/channels/nixos-unstable unstable
	sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	sudo nix-channel --update
	
	rebuild_machine
}


eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -s | --setup)
        echo "Initial setup for machine $MACHINE"
        initial_setup 
        shift
        ;;
    -r | --rebuild)
        echo "Rebuilding machine $MACHINE"
        rebuild_machine
        shift
        ;;
    --) shift;
        break
        ;;
  esac
done
