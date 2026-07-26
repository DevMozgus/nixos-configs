# WireGuard + wg-quick: kernel support and tooling (wg / wg-quick)
# No tunnels are declared here on purpose. Create a config manually, e.g.
# /etc/wireguard/wg0.conf (or under /persist), then `wg-quick up wg0`.
# Port 51820 is the conventional WireGuard port; adjust if you use another.
{ pkgs, ... }:
{
  networking.wireguard.enable = true;

  # networking.wireguard.enable only adds wireguard-tools when an interface is
  # declared. Since we keep this module connection-free, install the package
  # explicitly so `wg` and `wg-quick` land on PATH.
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking.firewall.allowedUDPPorts = [ 51820 ];
}
