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
    taps =
      map
        (name: {
          inherit name;
          trusted = true;
        })
        [
          "anomalyco/tap"
          "basicmachines-co/basic-memory"
          "hashicorp/tap"
          "sozercan/repo"
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
      "arduino-ide"
      "betterdisplay"
      "bitwarden"
      "bruno"
      "chatgpt"
      "claude"
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
      "jamie"
      "sozercan/repo/kaset"
      "ledger-wallet"
      "microsoft-teams"
      "mono-mdk"
      "ngrok"
      "notion"
      "notion-calendar"
      "obsidian"
      "openvpn-connect"
      "openwebstart"
      "postman"
      "qutebrowser"
      "raycast"
      "rio"
      "setapp"
      "shortcat"
      "slack"
      "stats"
      "steam"
      "sublime-merge"
      "sublime-text"
      "telegram"
      "trader-workstation"
      "warrensbox/tap/tfswitch"
      "ungoogled-chromium"
      "vlc"
      "yubico-authenticator"
      "zed"
      "zen"
      "zulu@17"
    ];
    masApps = {
      "DigiDoc4" = 1370791134;
      "Okta Verify" = 490179405;
      "TestFlight" = 899247664;
      "Web eID" = 1576665083;
      "WhatsApp" = 310633997;
    };
  };
}
