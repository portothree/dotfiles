{ self, ... }:

let name = builtins.baseNameOf ./.;
in {
  microvm = {
    hypervisor = "qemu";
    vms = {
      jorel = {
        flake = self;
        updateFlake = "microvm";
      };
    };
  };
}
