{ pkgs, ... }:

{
  home.file.vdirsyncer = {
    target = ".config/vdirsyncer/config";
    text = ''
      [general]
      status_path = "~/.vdirsyncer/status"
    '';
  };
}
