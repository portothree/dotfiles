{
  description = "@portothree nixos-configs";
  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io"
      "https://cache.nixos.org"
      "https://portothree.cachix.org"
      "https://microvm.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "portothree.cachix.org-1:L4w3V/jrM+5cG0yEAypCPan94GLUxWYm8VFLB774J6I="
      "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
    ];
  };
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOs/nixos-hardware/master";
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = { url = "github:cachix/pre-commit-hooks.nix"; };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware
    , microvm, pre-commit-hooks, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "porto";
      homeDirectory = "/home/porto";
      mkPkgs = pkgs:
        { overlays ? [ ], allowUnfree ? false }:
        import pkgs {
          inherit system;
          inherit overlays;
          config.allowUnfree = allowUnfree;
        };
      mkNixosSystem = pkgs:
        { hostName, allowUnfree ? false, extraModules ? [ ] }:
        pkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs self; };
          modules = [
            {
              nix.registry.n.flake = pkgs;
              nixpkgs.config.allowUnfree = allowUnfree;
              networking = { inherit hostName; };
            }
            ./hosts/${hostName}/configuration.nix
          ] ++ extraModules;
        };
      mkQemuMicroVM = pkgs:
        { hostName, extraModules ? [ ] }:
        pkgs.lib.nixosSystem {
          inherit system;
          modules = [
            microvm.nixosModules.microvm
            {
              networking = { inherit hostName; };
              microvm = {
                hypervisor = "qemu";
                interfaces = [{
                  type = "user";
                  id = "microvm-a1";
                  mac = "02:00:00:00:00:01";
                }];
              };
            }
          ] ++ extraModules;
        };
    in {
      checks.${system}.pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt = {
            enable = true;
            excludes = [ "hardware-configuration.nix" ];
          };
          shellcheck = { enable = true; };
        };
      };
      nixosConfigurations = {
        jorel = mkNixosSystem nixpkgs {
          hostName = "jorel";
          allowUnfree = true;
          extraModules = [
            nixos-hardware.nixosModules.common-cpu-amd
            microvm.nixosModules.host
          ];
        };
        klong = mkNixosSystem nixpkgs { hostName = "klong"; };
        juju = mkNixosSystem nixpkgs { hostName = "juju"; };
        oraculo = mkQemuMicroVM nixpkgs {
          hostName = "oraculo";
          extraModules = [
            ({ config, pkgs, ... }: {
              system.stateVersion = config.system.nixos.version;
              users = { users = { root = { password = ""; }; }; };
              services = {
                getty.helpLine = ''
                  Log in as "root" with an empty password.
                  Type Ctrl-a c to switch to the qemu console
                  and `quit` to stop the VM.
                '';
              };
              nix = {
                enable = true;
                package = pkgs.nixFlakes;
                extraOptions = ''
                  experimental-features = nix-command flakes
                '';
                registry = { nixpkgs.flake = nixpkgs; };
              };
            })
          ];
        };
      };
      devShells.${system}.default = import ./shell.nix {
        pkgs = mkPkgs nixpkgs-unstable { };
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };
    };
}
