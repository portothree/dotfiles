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
    ./tree-sitter
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
    ./xinit
    ./wally
    ./weechat
    ./xournalpp
    ./zsh
  ];
}
