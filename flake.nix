{
  description = "@portothree dotfiles";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    nixgl.url = "github:guibou/nixGL";
  };
  outputs = { self, nixpkgs, nixgl }: { overlays = [ nixgl.overlay ]; };
}
