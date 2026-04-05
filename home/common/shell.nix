# Zsh + starship + direnv + zoxide
{ ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "docker"
      ];
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      format = "$directory$git_branch$git_status$nix_shell$character";
      character = {
        success_symbol = "[›](bold green)";
        error_symbol = "[›](bold red)";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch.format = "[$branch]($style) ";
      git_status.format = "[$all_status$ahead_behind]($style) ";
      nix_shell.format = "[$symbol$state]($style) ";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zoxide.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "zen-beta";
  };
}
