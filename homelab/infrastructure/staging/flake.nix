{
  description = "Staging NixOS MicroVM";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, microvm }:
    let system = "x86_64-linux";
    in {
      defaultPackage.${system} = self.packages.${system}.staging;

      packages.${system}.staging = let
        inherit (self.nixosConfigurations.staging) config;
        # quickly build with another hypervisor if this MicroVM is built as a package
        hypervisor = "qemu";
      in config.microvm.runner.${hypervisor};

      nixosConfigurations.staging = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          {
            nix = {
              enable = true;
              extraOptions = ''
                experimental-features = nix-command flakes
              '';
              trustedUsers = [ "root" ];
            };
          }
          microvm.nixosModules.microvm
          {
            networking.hostName = "staging";
            users.users.root.password = "";
            microvm = {
              volumes = [{
                mountPoint = "/var";
                image = "var.img";
                size = 256;
              }];
              shares = [{
                # use "virtiofs" for MicroVMs that are started by systemd
                proto = "9p";
                tag = "ro-store";
                # a host's /nix/store will be picked up so that the
                # size of the /dev/vda can be reduced.
                source = "/nix/store";
                mountPoint = "/nix/.ro-store";
              }];
              socket = "control.socket";
              # relevant for delarative MicroVM management
              hypervisor = "qemu";
            };
          }
        ];
      };
    };
}
