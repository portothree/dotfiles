{
  pkgs ? import <nixpkgs> { },
  shellHook ? "",
}:

pkgs.mkShell {
  packages = with pkgs; [
    git
    nixfmt
    statix
    deadnix
    shellcheck
  ];
  inherit shellHook;
}
