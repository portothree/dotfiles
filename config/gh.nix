{ pkgs, ... }:

{
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      editor = "vim";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };
}
