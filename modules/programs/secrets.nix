{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.secrets;
in
{
  options.modules.secrets.file = mkOption {
    type = types.str;
    default = "${config.xdg.configHome}/dotfiles/secrets.env";
    description = "KEY='value' file, kept out of git, that fills the placeholders in templated configs.";
  };
  # Activation snippet: write `template` to ~/`target`, filling only the
  # variables the secrets file defines. The result is a real file because the
  # apps edit it; the previous one is kept as `target`.bak when it differs.
  config.lib.secrets.render = template: target: ''
    (
      secrets=${escapeShellArg cfg.file}
      dest="$HOME/${target}"
      vars=""
      if [ -r "$secrets" ]; then
        set -a; . "$secrets"; set +a
        vars=$(${pkgs.gnused}/bin/sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/$\1/p' "$secrets")
      else
        warnEcho "$secrets is missing, so ~/${target} keeps its placeholders"
      fi
      tmp=$(mktemp)
      ${pkgs.gettext}/bin/envsubst "$vars" < ${template} > "$tmp"
      run mkdir -p "$(dirname "$dest")"
      if [ -e "$dest" ] && ! ${pkgs.diffutils}/bin/cmp -s "$tmp" "$dest"; then
        run cp -L "$dest" "$dest.bak"
      fi
      run rm -f "$dest"
      run install -m 600 "$tmp" "$dest"
      rm -f "$tmp"
    )
  '';
}
