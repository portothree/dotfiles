{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    extraConfig = ''
      {
      	modi: "drun,window,run,ssh";*/
        timeout {
            action: "kb-cancel";
            delay:  0;
        }
        filebrowser {
            directories-first: true;
            sorting-method:    "name";
        }
      }
    '';
  };
}
