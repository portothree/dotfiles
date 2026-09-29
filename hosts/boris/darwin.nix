{ pkgs, ... }:

{
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };
  # Nix itself is managed by the Determinate installer
  nix.enable = false;

  system = {
    primaryUser = "gustavoporto";
    stateVersion = 6;
    defaults = {
      dock = {
        autohide = false;
        tilesize = 69;
        show-recents = false;
      };
      finder.FXPreferredViewStyle = "icnv";
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
        "com.apple.swipescrolldirection" = false;
      };
      screencapture.location = "~/Documents/";
      trackpad.Clicking = true;
    };
  };

  users.users.gustavoporto.home = "/Users/gustavoporto";

  security.pam.services.sudo_local.touchIdAuth = true;

  fonts.packages = with pkgs; [ fira-code ];

  homebrew = {
    enable = true;
    taps = [
      "anomalyco/tap"
      "basicmachines-co/basic-memory"
      "hashicorp/tap"
      "supreme-gg-gg/tap"
      "warrensbox/tap"
    ];
    brews = [
      "anomalyco/tap/opencode"
      "asdf"
      "awscli"
      "backlog-md"
      "basicmachines-co/basic-memory/basic-memory"
      "bitwarden-cli"
      "cloud-sql-proxy"
      "cloudflared"
      "cocoapods"
      "colima"
      "docker"
      "docker-buildx"
      "docker-compose"
      "dotnet@8"
      "flyway"
      "gh"
      "glab"
      "go"
      "hashicorp/tap/terraform"
      "helix"
      "ios-deploy"
      "k9s"
      "kubernetes-cli"
      "mas"
      "mono"
      "node@18"
      "node@20"
      "node@22"
      "nvm"
      "okta-aws-cli"
      "ollama"
      "pinentry-mac"
      "postgresql@15"
      "python@3.10"
      "python@3.12"
      "qemu"
      "rbenv"
      "rclone"
      "ripgrep"
      "ruby@3.1"
      "scrcpy"
      "supreme-gg-gg/tap/instagram-cli"
      "syncthing"
      "tailscale"
      "timewarrior"
      "trivy"
      "uv"
      "warrensbox/tap/tfswitch"
      # Libraries installed by hand, probably for builds
      "ghostscript"
      "jpeg"
      "libpq"
      "librsvg"
      "poppler"
      "pyqt"
      "python-setuptools"
      "qt"
      "zlib"
    ];
    casks = [
      "1password"
      "1password-cli"
      "android-commandlinetools"
      "android-platform-tools"
      "anki"
      "betterdisplay"
      "bitwarden"
      "bruno"
      "cleanmymac-cli"
      "dbeaver-community"
      "ddpm"
      "docker-desktop"
      "dotnet-runtime"
      "finicky"
      "gcloud-cli"
      "ghostty"
      "google-chrome"
      "hammerspoon"
      "insomnia"
      "kaset"
      "mono-mdk"
      "ngrok"
      "openwebstart"
      "postman"
      "qutebrowser"
      "rio"
      "setapp"
      "shortcat"
      "slack"
      "stats"
      "sublime-merge"
      "sublime-text"
      "trader-workstation"
      "ungoogled-chromium"
      "yubico-authenticator"
      "zulu@17"
    ];
  };
}
