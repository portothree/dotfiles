{ inputs, pkgs, config, shellScriptPkgs, ... }:

{
  imports = [
    ./anki
    ./zsh
    ./tmux
    ./bspwm
    ./dunst
    ./sxhkd
    ./nodejs
    ./alacritty
    ./gcalcli
    ./xinit
  ];
}
