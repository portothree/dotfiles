{ pkgs, ... }:

{
  programs.git = {
    package = pkgs.gitFull;
    enable = true;
    userName = "Gustavo Porto";
    userEmail = "gus@p8s.co";
    extraConfig = {
      credential.helper =
        "${pkgs.gitAndTools.gitFull}/bin/git-credential-libsecret";
      core = { editor = "vim"; };
      color = { ui = true; };
      push = {
        default = "current";
        autoSetupRemote = true;
      };
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
    aliases = {
      st = "status";
      co = "checkout";
      ci = "commit";
      br = "branch";
      lg =
        "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      recent =
        "for-each-ref --sort=-committerdate --format='%(committerdate:short): %(refname:short)' refs/heads/";
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
