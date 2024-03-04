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
    ./hammerspoon
    ./karabiner-elements
    ./tmux
    ./timewarrior
    ./nodejs
    ./neovim
    ./nixTools
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
