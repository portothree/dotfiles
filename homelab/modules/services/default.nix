{ pkgs, config, ... }:

{
  imports = [ ./nextdns ./tailscale ];
}
