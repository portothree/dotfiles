{ inputs, pkgs, config, shellScriptPkgs, ... }:

{
  imports = [
    ./anki
    ./androidTools
    ./bun
    ./bspwm
    ./conky
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
    ./rust
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
