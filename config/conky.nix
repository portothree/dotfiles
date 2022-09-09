{ lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [ conky ];
    file.conky = {
      target = ".conkyrc";
      text = lib.strings.fileContents ./conky/config.lua;
    };
  };
}
