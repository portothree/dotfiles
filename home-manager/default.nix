{ pkgs, ... }:

{
  home.packages = with pkgs; [
    astyle
    sysz
    gnumake
    gcc
    ranger
    ripgrep
    xclip
    xdotool
    xdo
    stylua
    nixfmt
    shfmt
    shellcheck
    rofi
    tig
    s-tui
    duf
    python3
    zathura
    maim
    pass
    yank
    jq
    yq
    sd
    fd
    cachix
  ];
  programs = { home-manager = { enable = true; }; };
  xdg = { enable = true; };
}
