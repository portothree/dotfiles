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
    nixgl.url = "github:guibou/nixGL";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager
    , home-manager-unstable, nixgl, ... }@inputs:
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

      mkNixosSystem = pkgs: hm: hostName:
        pkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            { networking = { inherit hostName; }; }
            ./hosts/${hostName}/configuration.nix
          ];
        };

      mkHomeManager = pkgs: hm: hostName:
        home-manager.lib.homeManagerConfiguration {
          inherit system;
          inherit username;
          inherit homeDirectory;
          configuration = import ./hosts/gesonel/home.nix {
            inherit pkgs;
            inherit inputs;
          };
        };

      klongPkgs = mkPkgs nixpkgs { };
    in {
      nixosConfigurations = {
        "jorel" = mkNixosSystem nixpkgs home-manager "jorel";
        "juju" = mkNixosSystem nixpkgs home-manager "juju";
        "danubio" = mkNixosSystem nixpkgs home-manager "danubio";
        "nico" = mkNixosSystem nixpkgs home-manager "nico";
        "klong" = mkNixosSystem nixpkgs home-manager "klong";
      };
      homeConfigurations = {
        klong = mkHomeManager klongPkgs home-manager "klong";
      };
      devShell."${system}" =
        import ./shell.nix { pkgs = mkPkgs nixpkgs-unstable { }; };
    };
}
