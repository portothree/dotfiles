{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs
    node2nix
    yarn2nix
    nodePackages.npm
    nodePackages.node-gyp
    nodePackages.node-pre-gyp
    nodePackages.node-gyp-build
    yarn
  ];
}
