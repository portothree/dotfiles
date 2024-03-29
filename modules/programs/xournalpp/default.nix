{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.xournalpp;
in {
  options.modules.xournalpp = { enable = mkEnableOption "xournalpp"; };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        xournalpp
        # TODO: Remove when https://github.com/NixOS/nixpkgs/issues/163107 is fixed
        gnome.adwaita-icon-theme
        shared-mime-info
      ];
      file.xournalpp-toolbar = {
        target = ".config/xournalpp/toolbar.ini";
        text = ''
          [Dracula]
          toolbarTop1=SAVE,NEW,SEPARATOR,OPEN,CUT,COPY,PASTE,SEPARATOR,UNDO,REDO,SEPARATOR,SEPARATOR,SEPARATOR,INSERT_NEW_PAGE,DELETE_CURRENT_PAGE,SEPARATOR,GOTO_BACK,GOTO_NEXT,SEPARATOR,FULLSCREEN,SEPARATOR,IMAGE,TEXT
          toolbarLeft1=COLOR(0x282a36),COLOR(0x44475a),COLOR(0x6272a4),COLOR(0xf1fa8c),COLOR(0xffb86c),COLOR(0xff5555),COLOR(0xbd93f9),COLOR(0xff79c6),COLOR(0x50fa7b),COLOR(0x8be9fd),COLOR(0xf8f8f2),SEPARATOR,COLOR_SELECT,ZOOM_100,ZOOM_FIT,ZOOM_IN,ZOOM_OUT,VERY_FINE,SEPARATOR,FINE,MEDIUM,THICK,VERY_THICK,TOOL_FILL,SEPARATOR,DRAW_CIRCLE,SEPARATOR,DRAW_RECTANGLE,RULER,DRAW_ARROW,DRAW_COORDINATE_SYSTEM,GRID_SNAPPING,ROTATION_SNAPPING,SEPARATOR,SELECT_REGION,SELECT_RECTANGLE,PEN,ERASER,HILIGHTER,DEFAULT_TOOL
          name=Dracula
        '';
      };
    };
  };
}
