{ pkgs ? import <nixpkgs> { }, shellHook ? "" }:

with pkgs;
let
  nixBin = writeShellScriptBin "nix" ''
    ${nixFlakes}/bin/nix --option experimental-features "nix-command flakes" "$@"
  '';
in mkShell {
  buildInputs = [ git nixfmt ];
  shellHook = pkgs.lib.concatStringsSep "\n" [''
    export FLAKE="$(pwd)";
    export PATH="$FLAKE/bin:/${nixBin}/bin:$PATH"
  ''];
}
