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
    nixgl.url = "github:guibou/nixGL";
    scripts.url = "path:./bin";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager
    , home-manager-unstable, nixos-hardware, nixgl, scripts, ... }@inputs:
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
      nixosConfigurations = {
        jorel = mkNixosSystem nixpkgs {
          hostName = "jorel";
          extraModules = [ nixos-hardware.nixosModules.common-cpu-amd ];
        };
        juju = mkNixosSystem nixpkgs { hostName = "juju"; };
        danubio = mkNixosSystem nixpkgs { hostName = "danubio"; };
        nico = mkNixosSystem nixpkgs { hostName = "nico"; };
        klong = mkNixosSystem nixpkgs { hostName = "klong"; };
      };
      homeConfigurations = {
        jorel =
          mkHomeManager (mkPkgs nixpkgs { allowUnfree = true; }) home-manager
          "jorel";
        klong =
          mkHomeManager (mkPkgs nixpkgs { allowUnfree = true; }) home-manager
          "klong";
      };
      devShell."${system}" =
        import ./shell.nix { pkgs = mkPkgs nixpkgs-unstable { }; };
    };
}
