{
  description = "Jorel NixOS MicroVM";
  nixConfig = {
    extra-substituters = [ "https://microvm.cachix.org" ];
    extra-trusted-public-keys =
      [ "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys=" ];
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, microvm }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      defaultPackage.${system} = self.packages.${system}.jorel;

      packages.${system}.jorel = let
        inherit (self.nixosConfigurations.jorel) config;
        # quickly build with another hypervisor if this MicroVM is built as a package
        hypervisor = "qemu";
      in config.microvm.runner.${hypervisor};

      nixosConfigurations.jorel = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          microvm.nixosModules.microvm
          {
            networking = {
              hostName = "jorel";
              firewall = {
                allowedTCPPorts = [ 80 443 ];
                extraCommands = ''
                  iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
                  iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
                  iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

                  iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
                  iptables -A INPUT -i lo -j ACCEPT
                  iptables -P OUTPUT ACCEPT

                  iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
                  iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT

                  iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT

                  iptables -A INPUT -s 10.42.0.0/16 -d 46.226.106.65/32 -j ACCEPT

                  iptables -P INPUT DROP
                '';
              };
            };
            users = { users = { root = { password = ""; }; }; };
            nix = {
              enable = true;
              extraOptions = ''
                experimental-features = nix-command flakes
              '';
              trustedUsers = [ "root" ];
            };
            environment = {
              systemPackages = with pkgs; [
                git
                curl
                k9s
                kubectl
                fluxcd
                fluxctl
              ];
            };
            services = {
              k3s = {
                enable = true;
                role = "server";
                extraFlags =
                  toString [ "--disable traefik" "--disable servicelb" ];
              };
            };
            system.stateVersion = "22.05";
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
              interfaces = [{
                type = "user";
                # interface name on the host
                id = "microvm-a1";
                # Ethernet address of the MicroVM's interface, not the host's
                mac = "02:00:00:00:00:01";
              }];
            };
          }
        ];
      };
    };
}
