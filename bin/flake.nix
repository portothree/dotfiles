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
        bspwm-bar = mkShellScript "bspwm-bar" ./bspwm/bar
          (with pkgs; [ lemonbar xdo bspwm ]);
        bluetooth-connect =
          mkShellScript "bluetooth-connect" ./bluetooth/bluetooth-connect
          (with pkgs; [ bluez ]);
        bw-with-session = mkShellScript "bw-with-session" ./bw/bw-with-session
          (with pkgs; [ bitwarden-cli ]);
        pomodoro = mkShellScript "pomodoro" ./pomodoro
          (with pkgs; [ timer lolcat speechd ]);
      };
    };
}
