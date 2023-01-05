{ pkgs ? import <nixpkgs> { }, packages ? [ ], shellHook ? "" }:

with pkgs;
let
  nixBin = writeShellScriptBin "nix" ''
    ${nixFlakes}/bin/nix --option experimental-features "nix-command flakes" "$@"
  '';
in mkShell {
  inherit packages;
  buildInputs = [ git ];
  shellHook = pkgs.lib.concatStringsSep "\n" [
    ''
      export FLAKE="$(pwd)";
      export PATH="$FLAKE/bin:/${nixBin}/bin:$PATH"
      source "$FLAKE/.env"
    ''
    shellHook
  ];
}
