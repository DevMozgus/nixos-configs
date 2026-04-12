# Security hardening: firewall, kernel lockdown, sysctl, module blacklist
{ lib, ... }:
{
  # ── Firewall ──────────────────────────────────────────────────────────
  # Default-deny inbound; outbound unrestricted.
  # Netbird opens its own ports via `openFirewall = true`.
  # Docker manages its own iptables chain — unaffected.
  networking.firewall = {
    enable = true;

    # Syncthing (user-level service declared in home-manager)
    allowedTCPPorts = [ 22000 ]; # sync traffic
    allowedUDPPorts = [ 21027 ]; # local discovery

    # Reject instead of drop for faster feedback to legitimate apps
    rejectPackets = true;

    # Allow ping (ICMP echo) — useful for diagnostics
    allowPing = true;
  };

  # ── Kernel hardening (sysctl) ─────────────────────────────────────────
  boot.kernel.sysctl = {
    # Restrict access to kernel pointers (1 = CAP_SYSLOG allowed; 2 = even root blocked)
    # Using 1 to preserve perf/bpftrace usability with sudo
    "kernel.kptr_restrict" = 1;
    "kernel.dmesg_restrict" = 1;

    # Restrict BPF — unprivileged users cannot load BPF programs
    "kernel.unprivileged_bpf_disabled" = 1;

    # Yama: only parent processes or CAP_SYS_PTRACE can trace
    # Allows strace/gdb with sudo; blocks cross-user ptracing
    "kernel.yama.ptrace_scope" = 1;

    # Disable core dumps for setuid binaries
    "fs.suid_dumpable" = 0;

    # Restrict loading TTY line disciplines
    "dev.tty.ldisc_autoload" = 0;

    # Protect against hardlink/symlink/fifo attacks
    "fs.protected_hardlinks" = 1;
    "fs.protected_symlinks" = 1;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;

    # ── Network hardening ──
    # Reverse path filtering — loose mode (2) required for WireGuard/Netbird VPN.
    # Strict mode (1) drops VPN packets due to asymmetric routing.
    # Loose mode still validates source addresses while allowing VPN traffic.
    "net.ipv4.conf.default.rp_filter" = 2;
    "net.ipv4.conf.all.rp_filter" = 2;

    # Do not accept source-routed packets
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;

    # Do not send or accept ICMP redirects
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;

    # SYN flood protection
    "net.ipv4.tcp_syncookies" = 1;

    # Ignore ICMP broadcasts and bogus error responses
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
  };

  # ── Kernel module blacklist ───────────────────────────────────────────
  # Uncommon network protocols and filesystems that are common attack vectors.
  # None of these are needed on a desktop/laptop workstation.
  boot.blacklistedKernelModules = [
    # Rare/unneeded network protocols
    "dccp" # Datagram Congestion Control Protocol
    "sctp" # Stream Control Transmission Protocol
    "rds" # Reliable Datagram Sockets
    "tipc" # Transparent Inter-Process Communication

    # Rare filesystems (not used on a NixOS workstation)
    "cramfs" # Compressed ROM filesystem
    "freevxfs" # Veritas filesystem
    "jffs2" # Journalling Flash filesystem
    "hfs" # Mac HFS (classic)
    "hfsplus" # Mac HFS+
    # Note: squashfs intentionally NOT blacklisted — needed by AppImages
    "udf" # UDF (optical media; load manually with modprobe if needed)

    # Video test driver — known exploit target
    "vivid"
  ];

  # Prevent loading the kernel image (protects against rootkits)
  security.protectKernelImage = true;
}
