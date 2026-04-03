# Git identity, delta pager, aliases
{ ... }:
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
