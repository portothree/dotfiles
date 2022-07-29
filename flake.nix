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
    scripts.url = "path:./bin";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager
    , home-manager-unstable, nixgl, scripts, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "porto";
      homeDirectory = "/home/porto";
      shellScriptsPkgs = scripts.packages.${system};

      mkPkgs = pkgs:
        { overlays ? [ ], allowUnfree ? false }:
        import pkgs {
          inherit system;
          inherit overlays;
          config.allowUnfree = allowUnfree;
        };

      mkNixosSystem = pkgs: hostName:
        pkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            { networking = { inherit hostName; }; }
            ./hosts/${hostName}/configuration.nix
          ];
        };

      mkHomeManager = pkgs: hm: hostName:
        hm.lib.homeManagerConfiguration {
          inherit system;
          inherit username;
          inherit homeDirectory;
          inherit pkgs;
          extraSpecialArgs = { inherit shellScriptsPkgs; };
          configuration = import ./hosts/${hostName}/home.nix;
        };

    in {
      nixosConfigurations = {
        "jorel" = mkNixosSystem nixpkgs "jorel";
        "juju" = mkNixosSystem nixpkgs "juju";
        "danubio" = mkNixosSystem nixpkgs "danubio";
        "nico" = mkNixosSystem nixpkgs "nico";
        "klong" = mkNixosSystem nixpkgs "klong";
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
