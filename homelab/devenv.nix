{ pkgs, ... }:

{
  env.GREET = "devenv";
  packages = [ pkgs.git ];
  languages.nix.enable = true;
  scripts.hello.exec = "echo hello from $GREET";
  pre-commit.hooks.shellcheck.enable = true;
  processes.ping.exec = "ping p8s.co";
}
