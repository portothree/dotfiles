{
  description = "Collection of shell scripts";
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
        lemonbar-bspwm =
          mkShellScript "lemonbar-bspwm" ./lemonbar/lemonbar-bspwm
          (with pkgs; [ lemonbar xdo bspwm ]);
        bluetooth-connect =
          mkShellScript "bluetooth-connect" ./bluetooth/bluetooth-connect
          (with pkgs; [ bluez ]);
      };
    };
}
