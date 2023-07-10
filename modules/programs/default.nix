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
    ./gcloud
    ./gptcommit
    ./jrnl
    ./sxhkd
    ./spotify
    ./qutebrowser
    ./xinit
    ./wally
    ./weechat
    ./xournalpp
    ./zsh
  ];
}
