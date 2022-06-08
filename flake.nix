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
        "juju" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/juju/configuration.nix ];
        };
        "danubio" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/danubio/configuration.nix ];
        };
        "nico" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/nico/configuration.nix ];
        };
        "klong" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/klong/configuration.nix ];
        };
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
        "juju" = home-manager.lib.homeManagerConfiguration {
          inherit system;
          inherit username;
          inherit homeDirectory;
          configuration =
            import ./hosts/juju/home.nix { pkgs = mkPkgs nixpkgs { }; };
          stateVersion = "21.11";
        };
        "danubio" = home-manager.lib.homeManagerConfiguration {
          inherit system;
          inherit username;
          inherit homeDirectory;
          configuration =
            import ./hosts/danubio/home.nix { pkgs = mkPkgs nixpkgs { }; };
          stateVersion = "21.11";
        };
        "nico" = home-manager.lib.homeManagerConfiguration {
          inherit system;
          inherit username;
          inherit homeDirectory;
          configuration =
            import ./hosts/nico/home.nix { pkgs = mkPkgs nixpkgs { }; };
          stateVersion = "21.11";
        };
        "klong" = home-manager.lib.homeManagerConfiguration {
          inherit system;
          inherit username;
          inherit homeDirectory;
          configuration =
            import ./hosts/klong/home.nix { pkgs = mkPkgs nixpkgs { }; };
          stateVersion = "22.05";
        };
      };
      devShell."${system}" =
        import ./shell.nix { pkgs = mkPkgs nixpkgs-unstable { }; };
    };
}
