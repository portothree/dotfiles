{ inputs, pkgs, config, shellScriptPkgs, ... }:

{
  imports = [
    ./alacritty
    ./anki
    ./androidTools
    ./bun
    ./bspwm
    ./conky
    ./dunst
    ./dockerTools
    ./karabiner-elements
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
