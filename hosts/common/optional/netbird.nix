# Netbird peer-to-peer VPN client (Wireguard-based)
# After importing, run `netbird-wt0 login` to authenticate manually.
{ ... }:
{
  services.netbird.clients.wt0 = {
    port = 51821;
    ui.enable = false;
    openFirewall = true;
    openInternalFirewall = true;
  };

  # Required for Netbird's client-side DNS resolution
  services.resolved.enable = true;
}
