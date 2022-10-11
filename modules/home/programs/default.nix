{ inputs, pkgs, config, shellScriptPkgs, ... }:

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
    ./weechat
    ./xournalpp
    ./zsh
  ];
}
