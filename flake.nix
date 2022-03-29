{
  description = "@portothree dotfiles";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixGL.url = "github:guibou/nixGL";
  };
  outputs = { self, nixpkgs, homeManager, nixGL }: {
    homeConfigurations = {
      "gesonel" = homeManager.lib.homeManagerConfiguration {
        configuration = import ./hosts/gesonel/home.nix;
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ nixGL.overlay ];
        };
        system = "x86_64-linux";
        stateVersion = "22.05";
        username = "porto";
        homeDirectory = "/home/porto";
      };
    };
  };
}
