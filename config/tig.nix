{ ... }:

{
  home.file.tig = {
    target = ".tigrc";
    text = ''
      bind main ! !?git revert %(commit)
    '';
  };
}
