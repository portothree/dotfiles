{
  description = "@portothree dotfiles";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    nixgl.url = "github:guibou/nixGL";
  };
  outputs = { self, nixpkgs, nixgl }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ nixgl.overlay ];
      };
    in { };
}
