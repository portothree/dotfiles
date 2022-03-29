{ config, pkgs, ... }:

{
  services.picom = {
    enable = true;
    extraOptions = ''
      #################################
      #             Shadows           #
      #################################


      shadow = true; 
      shadow-radius = 7;
      shadow-opacity = 0.7; 
      shadow-offset-x = -7;
      shadow-offset-y = -7;
      shadow-color = "#000000";
      shadow-exclude = [
        "name = 'Notification'",
        "class_g = 'Conky'",
        "class_g ?= 'Notify-osd'",
        "class_g = 'Cairo-clock'",
        "_GTK_FRAME_EXTENTS@:c"
      ];

      #################################
      #           Fading              #
      #################################


      fading = false;

      #################################
      #   Transparency / Opacity      #
      #################################


      inactive-opacity = 0.8;
      frame-opacity = 0.7;
      active-opacity = 1.0;
      inactive-dim = 0.0;

      #################################
      #           Corners             #
      #################################


      corner-radius = 0;
      rounded-corners-exclude = [
        "window_type = 'dock'",
        "window_type = 'desktop'"
      ];

      #################################
      #     Background-Blurring       #
      #################################


      blur-kern = "3x3box";
      blur-background-exclude = [
        "window_type = 'dock'",
        "window_type = 'desktop'",
        "_GTK_FRAME_EXTENTS@:c"
      ];

      #################################
      #       General Settings        #
      #################################


      backend = "glx";
      vsync = false;
      refresh-rate = 60;
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;

      # GLX backend: Avoid using stencil buffer, useful if you don't have a stencil buffer.
      # Might cause incorrect opacity when rendering transparent content (but never
      # practically happened) and may not work with blur-background.
      # My tests show a 15% performance boost. Recommended.
      #
      glx-no-stencil = false;

      # GLX backend: Avoid rebinding pixmap on window damage.
      # Probably could improve performance on rapid window content changes,
      # but is known to break things on some drivers (LLVMpipe, xf86-video-intel, etc.).
      # Recommended if it works.
      #
      glx-no-rebind-pixmap = false;
      use-damage = true;

      # Use X Sync fence to sync clients' draw calls, to make sure all draw
      # calls are finished before picom starts drawing. Needed on nvidia-drivers
      # with GLX backend for some users.
      #
      xrender-sync-fence = true; 

      # GLX backend: Use specified GLSL fragment shader for rendering window contents.
      # See `compton-default-fshader-win.glsl` and `compton-fake-transparency-fshader-win.glsl`
      # in the source tree for examples.
      #
      # glx-fshader-win = ""

      # Force all windows to be painted with blending. Useful if you
      # have a glx-fshader-win that could turn opaque pixels transparent.
      #
      # force-win-blend = false

      # Set the log level. Possible values are:
      #  "trace", "debug", "info", "warn", "error"
      # in increasing level of importance. Case doesn't matter.
      # If using the "TRACE" log level, it's better to log into a file
      # using *--log-file*, since it can generate a huge stream of logs.
      #
      # log-level = "debug"
      log-level = "warn";

      # Set the log file.
      # If *--log-file* is never specified, logs will be written to stderr.
      # Otherwise, logs will to written to the given file, though some of the early
      # logs might still be written to the stderr.
      # When setting this option from the config file, it is recommended to use an absolute path.
      #
      # log-file = "/path/to/your/log/file"

      # Show all X errors (for debugging)
      # show-all-xerrors = false

      wintypes:
      {
        tooltip = { fade = true; shadow = true; opacity = 0.75; focus = true; full-shadow = false; };
        dock = { shadow = false; clip-shadow-above = true; }
        dnd = { shadow = false; }
        popup_menu = { opacity = 0.8; }
        dropdown_menu = { opacity = 0.8; }
      };
    '';
  };
}
