# 1Password CLI + GUI with polkit integration and custom browser allowlist
{ ... }:
{
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Required for CLI integration and system authentication (PAM/polkit)
    polkitPolicyOwners = [ "nicola" ];
  };

  # Allow Zen browser (and Firefox) to communicate with the 1Password extension
  # via native messaging. Firefox is handled automatically; Zen needs an explicit
  # entry because its binary name differs from a standard Firefox install.
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      zen-beta
    '';
    mode = "0755";
  };
}
