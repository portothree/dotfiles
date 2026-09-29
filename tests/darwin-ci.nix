# boris adapted to a GitHub macOS runner: runner user, checkout path, and no
# Homebrew or App Store installs (large downloads and GUI prompts).
{ lib, ... }:

{
  system.primaryUser = lib.mkForce "runner";
  users.users.runner.home = "/Users/runner";
  homebrew.enable = lib.mkForce false;

  home-manager.users.runner = {
    home = {
      username = lib.mkForce "runner";
      homeDirectory = lib.mkForce "/Users/runner";
    };
    modules.ai.dotfilesPath = lib.mkForce "/Users/runner/work/dotfiles/dotfiles";
  };
}
