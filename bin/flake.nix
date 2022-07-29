{
  description = "Script to start lemonbar";
  inputs = { nixpkgs = { url = "nixpkgs/nixos-unstable"; }; };
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.start-lemonbar = let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      name = "start-lemonbar";
      src = builtins.readFile ./lemonbar/start-lemonbar;
      script = (pkgs.writeScriptBin name src).overrideAttrs (old: {
        buildCommand = ''
          ${old.buildCommand}
           patchShebangs $out'';
      });
      buildInputs = with pkgs; [ lemonbar bspwm xdo ];
    in pkgs.symlinkJoin {
      inherit name;
      paths = [ script ] ++ buildInputs;
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
    };
  };
}
