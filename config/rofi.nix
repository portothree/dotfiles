{ pkgs, ... }:

let
  # Use `mkLiteral` for string-like values that should show without
  # quotes, e.g.:
  # {
  #   foo = "abc"; => foo: "abc";
  #   bar = mkLiteral "abc"; => bar: abc;
  # };
  mkLiteral = value: {
    _type = "literal";
    inherit value;
  };
in {
  programs.rofi = {
    enable = true;
    theme = {
      "*" = {
        background-color = mkLiteral "#000000";
        foreground-color = mkLiteral "rgba ( 250, 251, 252, 100 % )";
        border-color = mkLiteral "#FFFFFF";
        width = 512;
      };
      "#inputbar" = { children = map mkLiteral [ "prompt" "entry" ]; };
      "#textbox-prompt-colon" = {
        expand = false;
        str = ":";
        margin = mkLiteral "0px 0.3em 0em 0em";
        text-color = mkLiteral "@foreground-color";
      };
    };
    extraConfig = { modi = "drun,window"; };
  };
}
