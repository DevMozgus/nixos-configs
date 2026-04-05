# Git identity, delta pager, aliases
{ pkgs, lib, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "DevMozgus";
      user.email = "web@urlicic.dev";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";

      # SSH signing via 1Password
      #! Set user.signingKey to the SSH public key managed by 1Password, e.g.:
      user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPluYJyHhlqZfyMorZU59OcXA7gtnWJSOouKGnHzB3R9";
      gpg.format = "ssh";
      commit.gpgsign = true;
      tag.gpgsign = true;

      "gpg \"ssh\"" = {
        program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
    };
  };
}
