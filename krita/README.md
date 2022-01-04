# Krita

## Running on Nix

I had some trouble running Krita from using Nix, the workaround was to use [NixGL](https://github.com/guibou/nixGL).

For my PC with a Nvidia card I have NixGL installed with:
```
$ nix-channel --add https://github.com/guibou/nixGL/archive/main.tar.gz nixgl && nix-channel --update
$ nix-env -iA nixgl.auto.nixGLNvidia
```

After that I'm able to run krita with
```
$ nixGLNvidia-390.144 krita
```

Worth note that the env var `QT_XCB_GL_INTEGRATION` is set to `xcb_egl`.
```
$ export QT_XCB_GL_INTEGRATION=xcb_egl
```
