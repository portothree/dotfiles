{ pkgs, ... }:

{
  # Keep only generic packages to all systems
  # right now it only supports x86_64-linux
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
    usbutils
  ];
  programs = { home-manager = { enable = true; }; };
  xdg = { enable = true; };
}
