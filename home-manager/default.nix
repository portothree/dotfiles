{ ... }:

{
  programs = {
    home-manager = {
      enable = true;
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
  xdg = { enable = true; };
}
