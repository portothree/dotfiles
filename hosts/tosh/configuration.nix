{ pkgs, ... }:

{
  imports = [ ./gandicloud.nix ];
  config = {
    services = {
      nginx = {
        enable = true;
        virtualHosts = {
          "nixos.gandi.net" = {
            locations."/".root = pkgs.runCommand "web-root" { } ''
              mkdir $out
              echo 'NixOS @ gandi.net' > $out/index.html
            '';
          };
        };
      };
    };
    networking = { firewall = { allowedTCPPorts = [ 80 ]; }; };
  };
}
