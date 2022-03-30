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
  outputs = inputs @ { self, nixpkgs, home-manager, nixgl }:
    let system = "x86_64-linux";
    in {
      homeConfigurations = {
        "gesonel" = home-manager.lib.homeManagerConfiguration {
          configuration = import ./hosts/gesonel/home.nix;
          inherit system;
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ nixgl.overlay ];
          };
          stateVersion = "22.05";
          username = "porto";
          homeDirectory = "/home/porto";
        };
      };
    };
}
