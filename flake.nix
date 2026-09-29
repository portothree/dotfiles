{
  description = "@portothree dotfiles";
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
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixgl.url = "github:guibou/nixGL";
    pre-commit-hooks = { url = "github:cachix/pre-commit-hooks.nix"; };
    scripts.url = "path:./bin";
    basic-memory = {
      url = "github:basicmachines-co/basic-memory";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, home-manager
    , nix-darwin, pre-commit-hooks, scripts, ... }@inputs:
    let
      mkPkgs = pkgs:
        { system, overlays ? [ ], allowUnfree ? false }:
        import pkgs {
          inherit system overlays;
          config.allowUnfree = allowUnfree;
        };
      mkHomeManager = system: hostName:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs nixpkgs {
            inherit system;
            allowUnfree = true;
          };
          modules = [ ./profiles/${hostName}/home.nix ];
          extraSpecialArgs = {
            inherit inputs;
            shellScriptPkgs = scripts.packages.${system};
          };
        };
      mkDarwin = system: hostName: user:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${hostName}/darwin.nix
            home-manager.darwinModules.home-manager
            {
              networking.hostName = hostName;
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "before-nix-darwin";
                users.${user} = import ./profiles/${hostName}/home.nix;
                extraSpecialArgs = {
                  inherit inputs;
                  shellScriptPkgs = scripts.packages.${system};
                };
              };
            }
          ];
        };
    in {
      darwinConfigurations = {
        boris = mkDarwin "aarch64-darwin" "boris" "gustavoporto";
      };
      homeConfigurations = {
        boris = mkHomeManager "aarch64-darwin" "boris";
        zaza = mkHomeManager "x86_64-darwin" "zaza";
        jorel = mkHomeManager "x86_64-linux" "jorel";
        klong = mkHomeManager "x86_64-linux" "klong";
        juju = mkHomeManager "x86_64-linux" "juju";
      };
    } // flake-utils.lib.eachDefaultSystem (system: {
      checks.pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt = {
            enable = true;
            excludes = [ "hardware-configuration.nix" ];
          };
          shellcheck = { enable = true; };
        };
      };
      packages.scripts = scripts.packages.${system};
      devShell = import ./shell.nix {
        pkgs = mkPkgs nixpkgs-unstable { inherit system; };
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };
    });
}
