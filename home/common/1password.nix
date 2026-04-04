# 1Password home-manager integration: SSH agent + GPG agent forwarding
{ ... }:
{
  # Point SSH to the 1Password agent socket.
  # In 1Password Settings → Developer, enable "Use the SSH agent" first.
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
          IdentityAgent ~/.1password/agent.sock
    '';
  };
}
