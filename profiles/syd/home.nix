{ pkgs, ... }:

{
  imports = [
    ../../modules
    ../../home-manager
    ../../config/git.nix
    ../../config/ranger.nix
    ../../config/keynav.nix
    ../../config/conky.nix
    ../../config/rofi.nix
  ];
  home = {
    stateVersion = "22.11";
    username = "gus";
    homeDirectory = "/Users/gus";
    packages = with pkgs; [
      bitwarden-cli
      k9s
      kubectl
      glow
      pgcli
      mycli
      ledger
      tasksh
      vit
      pulsemixer
      nudoku
      dijo
      mutt
      mpv
      powertop
      acpi
      brightnessctl
      ledger-live-desktop
      monero-gui
      monero-cli
      nextdns
      llama
    ];
    sessionVariables = { EDITOR = "nvim"; };
  };
  services = {
    mpris-proxy.enable = true;
    keynav = { enable = true; };
    unclutter = {
      enable = true;
      timeout = 1;
      extraOptions = [ "root" ];
    };
    spotifyd = { enable = true; };
  };
  programs = {
    htop = { enable = true; };
    gh = {
      enable = true;
      settings = {
        git_protocol = "https";
        editor = "vim";
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
        browser = "qutebrowser";
      };
    };
    direnv = {
      enable = true;
      nix-direnv = { enable = true; };
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      defaultCommand = "rg --files | fzf";
      enableZshIntegration = true;
    };
    bat = {
      enable = true;
      config = {
        theme = "Github";
        italic-text = "always";
      };
    };
    zathura = {
      enable = true;
      options = {
        window-height = 1000;
        window-width = 1000;
      };
      extraConfig = ''
        map <C-i> recolor
      '';
    };
    qutebrowser = {
      enable = true;
      loadAutoconfig = true;
      extraConfig = ''
        start_page = "https://cs.github.com"
        c.url.default_page = start_page 
        c.url.start_pages = [ start_page ]
      '';
    };
  };
  modules = {
    bun.enable = true;
    dunst.enable = true;
    dockerTools.enable = true;
    alacritty.enable = true;
    tmux = {
      enable = true;
      gcalcli = false;
    };
    timewarrior.enable = true;
    neovim.enable = true;
    nodejs.enable = true;
    zsh.enable = true;
  };
}
