{
  description = "@portothree dotfiles";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:guibou/nixGL";
  };
  outputs = { self, nixpkgs, home-manager, nixgl }:
    let
      system = "x86_64-linux";

      mkPkgs = pkgs: extraOverlays:
        import pkgs {
          inherit system;
          config.allowUnfree = false;
          overlays = extraOverlays;
        };
    in {
      homeConfigurations = {
        "gesonel" = home-manager.lib.homeManagerConfiguration {
          inherit system;
          configuration = import ./hosts/gesonel/home.nix {
            pkgs = mkPkgs nixpkgs [ nixgl.overlay ];
            inherit nixgl;
          };
          stateVersion = "22.05";
          username = "porto";
          homeDirectory = "/home/porto";
        };
      };
      devShell."${system}" = import ./shell.nix { pkgs = mkPkgs nixpkgs [ ]; };
    };
}
