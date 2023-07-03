{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.nodejs;
in {
  options.modules.nodejs = { enable = mkEnableOption "nodejs"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs_20
      nodePackages.node-gyp
      nodePackages.node-pre-gyp
      nodePackages.node-gyp-build
      yarn
      nodePackages.prisma
    ];
    home.sessionVariables = with pkgs; {
      PRISMA_MIGRATION_ENGINE_BINARY = "${prisma-engines}/bin/migration-engine";
      PRISMA_QUERY_ENGINE_BINARY = "${prisma-engines}/bin/query-engine";
      PRISMA_QUERY_ENGINE_LIBRARY =
        "${prisma-engines}/lib/libquery_engine.node";
      PRISMA_INTROSPECTION_ENGINE_BINARY =
        "${prisma-engines}/bin/introspection-engine";
      PRISMA_FMT_BINARY = "${prisma-engines}/bin/prisma-fmt";
    };
  };
}
