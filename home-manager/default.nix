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
    stow
    difftastic
  ];
  programs = { home-manager = { enable = true; }; };
  xdg = { enable = true; };
}
