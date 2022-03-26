{ ... }:

{
  time = {
    timeZone = "Europe/Lisbon";
  };
  networking.extraHosts = ''
    192.168.1.100 pve.homelab
    192.168.1.106 lara.homelab
    192.168.1.200 pi.hole
    192.168.1.200 uptime.kuma
  '';
}
