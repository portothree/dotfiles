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
        sunrise-vpn = mkShellScript "sunrise-vpn" ./sunrise/vpn
          (with pkgs; [ openconnect vpn-slice ]);
      };
    };
}
