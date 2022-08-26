{
  description = "@portothree dotfiles";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-hardware.url = "github:NixOs/nixos-hardware/master";
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:guibou/nixGL";
    pre-commit-hooks = { url = "github:cachix/pre-commit-hooks.nix"; };
    scripts.url = "path:./bin";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager
    , home-manager-unstable, nixos-hardware, microvm, nixgl, pre-commit-hooks
    , scripts, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "porto";
      homeDirectory = "/home/porto";
      shellScriptPkgs = scripts.packages.${system};
      mkPkgs = pkgs:
        { overlays ? [ ], allowUnfree ? false }:
        import pkgs {
          inherit system;
          inherit overlays;
          config.allowUnfree = allowUnfree;
        };
      mkNixosSystem = pkgs:
        { hostName, extraModules ? [ ] }:
        pkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            { networking = { inherit hostName; }; }
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
      mkHomeManager = pkgs: hm: hostName:
        hm.lib.homeManagerConfiguration {
          inherit system;
          inherit username;
          inherit homeDirectory;
          inherit pkgs;
          extraSpecialArgs = { inherit shellScriptPkgs; };
          configuration = import ./hosts/${hostName}/home.nix;
        };
    in {
      herculesCI = { ... }: {
        onPush = {
          default = {
            outputs = { ... }:
              let pkgs = mkPkgs nixpkgs { };
              in { hello = pkgs.hello; };
          };
        };
      };
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
      homeConfigurations = {
        jorel =
          mkHomeManager (mkPkgs nixpkgs { allowUnfree = true; }) home-manager
          "jorel";
        klong =
          mkHomeManager (mkPkgs nixpkgs { allowUnfree = true; }) home-manager
          "klong";
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
