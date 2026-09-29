{ ... }:

{
  version = "1.0";
  cluster = {
    name = "mycluster";
    provider = "k3d";
    # https://k3d.io/v5.0.0/usage/configfile/
    nativeConfig = {
      apiVersion = "k3d.io/v1alpha3";
      kind = "Simple";
      name = "mycluster";
      servers = 1;
      agents = 2;
      image = "rancher/k3s:v1.20.4-k3s1";
      ports = [{
        port = "8080:80";
        nodeFilters = [ "loadbalancer" ];
      }];
    };
  };
}
