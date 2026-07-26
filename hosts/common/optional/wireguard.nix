# WireGuard + wg-quick: kernel support and tooling (wg / wg-quick)
# No tunnels are declared here on purpose. Create a config manually, e.g.
# /etc/wireguard/wg0.conf (or under /persist), then `wg-quick up wg0`.
# Port 51820 is the conventional WireGuard port; adjust if you use another.
{ ... }:
{
  networking.wireguard.enable = true;

  networking.firewall.allowedUDPPorts = [ 51820 ];
}
