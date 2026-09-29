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
  black = mkLiteral "#000000";
  red = mkLiteral "#eb6e67";
  green = mkLiteral "#95ee8f";
  yellow = mkLiteral "#f8c456";
  blue = mkLiteral "#6eaafb";
  magenta = mkLiteral "#d886f3";
  cyan = mkLiteral "#6cdcf7";
  emphasis = mkLiteral "#50536b";
  text = mkLiteral "#dfdfdf";
  text-alt = mkLiteral "#b2b2b2";
  fg = mkLiteral "#abb2bf";
  bg = mkLiteral "#282c34";
  spacing = 0;
  background-color = "transparent";
  border-color = mkLiteral "#FFFFFF";
in {
  programs.rofi = {
    enable = true;
    theme = "dmenu";
    extraConfig = { modi = "drun,window"; };
  };
}
