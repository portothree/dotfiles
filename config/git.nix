{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Gustavo Porto";
    userEmail = "gustavo@portosanti.com";
    extraConfig = {
      core = { editor = "vim"; };
      color = { ui = true; };
      push = { default = "simple"; };
      pull = { ff = "only"; };
      init = { defaultBranch = "master"; };
    };
    delta = {
      enable = true;
      options = {
        enable = true;
        options = {
          navigate = true;
          line-numbers = true;
          syntax-them = "Github";
        };
      };
    };
    ignores = [
      "__pycache__"
      "[._]*.s[a-v][a-z]"
      "!*.svg"
      "[._]*.sw[a-p]"
      "[._]s[a-rt-v][a-z]"
      "[._]ss[a-gi-z]"
      "[._]sw[a-p]"
      "Session.vim"
      "Sessionx.vim"
      ".netrwhist"
      "*~"
      "tags"
      "[._]*.un~"
    ];
  };
}