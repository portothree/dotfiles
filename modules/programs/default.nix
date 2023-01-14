{ inputs, pkgs, config, binPkgs, ... }:

{
  imports = [
    ./anki
    ./androidTools
    ./bun
    ./bspwm
    ./dunst
    ./dockerTools
    ./tmux
    ./timewarrior
    ./nodejs
    ./neovim
    ./alacritty
    ./gcalcli
    ./jrnl
    ./sxhkd
    ./spotify
    ./xinit
    ./wally
    ./weechat
    ./xournalpp
    ./zsh
  ];
}
