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
    , home-manager-unstable, nixgl }@inputs:
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
      mkNixosSystem = pkgs: hostname:
        pkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${hostname}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraExpecialArgs = { inherit inputs; };
                users.porto =
                  import ./hosts/${hostname}/home.nix { inherit pkgs; };
              };
            }
          ];
        };
      defaultNixpkgs = mkPkgs nixpkgs { };
    in {
      nixosConfigurations = {
        "jorel" = mkNixosSystem defaultNixpkgs "jorel";
        "juju" = mkNixosSystem defaultNixpkgs "juju";
        "danubio" = mkNixosSystem defaultNixpkgs "danubio";
        "nico" = mkNixosSystem defaultNixpkgs "nico";
        "klong" = mkNixosSystem defaultNixpkgs "klong";
      };
      homeConfigurations = {
        "gesonel" = home-manager.lib.homeManagerConfiguration {
          inherit system;
          inherit username;
          inherit homeDirectory;
          configuration = import ./hosts/gesonel/home.nix {
            pkgs = mkPkgs nixpkgs-unstable {
              overlays = [ nixgl.overlay ];
              allowUnfree = true;
            };
          };
          stateVersion = "22.05";
        };
      };
      devShell."${system}" =
        import ./shell.nix { pkgs = mkPkgs nixpkgs-unstable { }; };
    };
}
