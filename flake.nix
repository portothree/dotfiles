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
      mkPkgs = pkgs:
        { overlays ? [ ], allowUnfree ? false }:
        import pkgs {
          inherit system;
          config.allowUnfree = allowUnfree;
          inherit overlays;
        };
    in {
      homeConfigurations = {
        "gesonel" = home-manager.lib.homeManagerConfiguration {
          inherit system;
          configuration = import ./hosts/gesonel/home.nix {
            pkgs = mkPkgs nixpkgs {
              overlays = [ nixgl.overlay ];
              allowUnfree = true;
            };
          };
          stateVersion = "22.05";
          username = "porto";
          homeDirectory = "/home/porto";
        };
        "juju" = home-manager.lib.homeManagerConfiguration {
          inherit system;
          configuration = import ./hosts/juju/home.nix {
            pkgs = mkPkgs nixpkgs {};
          };
          stateVersion = "21.11";
          username = "porto";
          homeDirectory = "/home/porto";
        };
      };
      devShell."${system}" = import ./shell.nix { pkgs = mkPkgs nixpkgs-unstable { }; };
    };
}
