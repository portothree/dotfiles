{ inputs, pkgs, config, shellScriptPkgs, ... }:

{
  imports = [
    ./anki
    ./androidTools
    ./bun
    ./dunst
    ./dockerTools
    ./tmux
    ./timewarrior
    ./nodejs
    ./neovim
    ./alacritty
    ./gcalcli
    ./jrnl
    ./xinit
    ./xournalpp
    ./zsh
  ];
}
