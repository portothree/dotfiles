{
  description = "Script to start lemonbar";
  inputs = { nixpkgs = { url = "nixpkgs/nixos-unstable"; }; };
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      mkShellScript = name: srcPath: deps:
        let
          src = builtins.readFile srcPath;
          script = (pkgs.writeScriptBin name src).overrideAttrs (old: {
            buildCommand = ''
              ${old.buildCommand}
               patchShebangs $out'';
          });
        in pkgs.symlinkJoin {
          inherit name;
          paths = [ script ] ++ deps;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
        };

    in {
      packages.${system} = {
        start-lemonbar =
          mkShellScript "start-lemonbar" ./lemonbar/start-lemonbar
          (with pkgs; [ lemonbar xdo bspwm ]);
      };
    };
}
