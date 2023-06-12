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
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixgl.url = "github:guibou/nixGL";
    pre-commit-hooks = { url = "github:cachix/pre-commit-hooks.nix"; };
    scripts.url = "path:./bin";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager
    , home-manager-unstable, nixgl, pre-commit-hooks, scripts, ... }@inputs:
    let
      system = "x86_64-linux";
      shellScriptPkgs = scripts.packages.${system};
      mkPkgs = pkgs:
        { overlays ? [ ], allowUnfree ? false }:
        import pkgs {
          inherit system;
          inherit overlays;
          config.allowUnfree = allowUnfree;
        };
      mkHomeManager = pkgs: hm: hostName:
        hm.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./profiles/${hostName}/home.nix ];
          extraSpecialArgs = { inherit shellScriptPkgs; };

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
      homeConfigurations = {
        jorel =
          mkHomeManager (mkPkgs nixpkgs { allowUnfree = true; }) home-manager
          "jorel";
        klong = mkHomeManager (mkPkgs nixpkgs-unstable { allowUnfree = true; })
          home-manager "klong";
        juju =
          mkHomeManager (mkPkgs nixpkgs { allowUnfree = true; }) home-manager
          "juju";
      };
      devShells.${system}.default = import ./shell.nix {
        pkgs = mkPkgs nixpkgs-unstable { };
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };
    };
}
