# Git identity, delta pager, aliases
{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Nicola";
    userEmail = "nicola@example.com";  # TODO: Set your real email

    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
      };
    };

    aliases = {
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
      lg = "log --oneline --graph --decorate";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
    };

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };
}
