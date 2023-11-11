{
  description = "@portothree homelab";
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
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-23.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOs/nixos-hardware/master";
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = { url = "github:cachix/pre-commit-hooks.nix"; };
    k1x = { url = "github:p8sco/k1x"; };
    devenv = { url = "github:cachix/devenv/v0.5"; };
  };
  outputs = { self, nixpkgs, nixpkgs-darwin, nix-darwin, nixos-hardware, microvm, pre-commit-hooks, k1x
    , devenv, ... }@inputs:
    let
      system = "x86_64-linux";
      mkDarwinSystem = {
        system ? "aarch64-darwin",
        nixpkgs ? inputs.nixpkgs,
        baseModules ? [],
        extraModules ? [],
      }:
      inputs.nix-darwin.lib.darwinSystem {
        inherit system;
        modules = baseModules ++ extraModules;
        specialArgs = {inherit self inputs nixpkgs;};
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
      packages.${system} = {
        k1x = k1x.packages.${system}.default;
        inherit (devenv.packages.${system}.devenv)
        ;
      };
      darwinConfigurations."Gustavos-MacBook-Pro" = mkDarwinSystem {
        system = "aarch64-darwin";
	nixpkgs = nixpkgs-darwin;
        extraModules = [
          ./hosts/boris/darwin-configuration.nix
        ];
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
    };
}
