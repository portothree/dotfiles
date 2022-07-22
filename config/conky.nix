{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [ conky ];
    file.conky = {
      target = ".conkyrc";
      text = builtings.concatStringSep "\n" [''
        lua << EOF
        ${lib.strings.fileContents ./conky/config.lua}
        EOF
      ''];
    };
  };
}
