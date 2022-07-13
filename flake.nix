{
  description = "@portothree dotfiles";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:guibou/nixGL";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixgl }:
    let
      system = "x86_64-linux";
      username = "porto";
      homeDirectory = "/home/porto";
      mkPkgs = pkgs:
        { overlays ? [ ], allowUnfree ? false }:
        import pkgs {
          inherit system;
          config.allowUnfree = allowUnfree;
          inherit overlays;
        };
    in {
      nixosConfigurations = {
        "jorel" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/jorel/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.porto =
                import ./hosts/jorel/home.nix { pkgs = mkPkgs nixpkgs { }; };
            }
          ];
        };
        "juju" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/juju/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.porto =
                import ./hosts/juju/home.nix { pkgs = mkPkgs nixpkgs { }; };
            }
          ];
        };
        "danubio" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/danubio/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.porto =
                import ./hosts/danubio/home.nix { pkgs = mkPkgs nixpkgs { }; };
            }
          ];
        };
        "nico" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nico/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.porto =
                import ./hosts/nico/home.nix { pkgs = mkPkgs nixpkgs { }; };
            }
          ];
        };
        "klong" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/klong/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.porto =
                import ./hosts/klong/home.nix { pkgs = mkPkgs nixpkgs { }; };
            }
          ];
        };
      };
      homeConfigurations = {
        "gesonel" = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs nixpkgs-unstable {
            overlays = [ nixgl.overlay ];
            allowUnfree = true;
          };
          modules = [ ./hosts/gesonel/home.nix ];
        };
      };
      devShell."${system}" =
        import ./shell.nix { pkgs = mkPkgs nixpkgs-unstable { }; };
    };
}
