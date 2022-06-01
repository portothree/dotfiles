{ pkgs, ... }:

{
  home.file.khal = {
    target = ".config/vdirsyncer/config";
    text = ''
      [general]
      status_path = "~/.vdirsyncer/status"
    '';
  };
}
