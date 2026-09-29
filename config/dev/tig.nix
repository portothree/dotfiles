# TODO: Move to module
{ pkgs, ... }:

{
  home.packages = [ pkgs.tig ];
  home.file.tig = {
    target = ".tigrc";
    text = ''
      bind main ! !?git revert %(commit)
    '';
  };
}
