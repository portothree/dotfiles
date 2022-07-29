{ pkgs, ... }:

{
  home.packages = with pkgs; [
    sysz
    gnumake
    gcc
    ranger
    ripgrep
    xclip
    xdotool
    xdo
    rofi
    tig
    s-tui
    python3
    zathura
    maim
    pass
    yank
    jq
    yq
    cachix
  ];
  programs = { home-manager = { enable = true; }; };
  xdg = { enable = true; };
}
