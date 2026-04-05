# Zsh + starship + direnv + zoxide
{ ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "docker-compose"
        "bun"
        "npm"
      ];
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      format = "[░▒▓](#676E95)[ ❄ ](bg:#676E95 fg:#0F111A)[](bg:#82AAFF fg:#676E95)$directory[](fg:#82AAFF bg:#464B5D)$git_branch$git_status[](fg:#464B5D bg:#1F2233)$nodejs$rust$golang$nix_shell[](fg:#1F2233 bg:#181A29)$time[ ](fg:#181A29)
$character";

      character = {
        success_symbol = "[›](bold green)";
        error_symbol = "[›](bold red)";
      };

      directory = {
        style = "fg:#EEFFFF bg:#82AAFF";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        truncate_to_repo = false;
      };

      git_branch = {
        symbol = " ";
        style = "bg:#464B5D";
        format = "[[ $symbol$branch ](fg:#82AAFF bg:#464B5D)]($style)";
      };

      git_status = {
        style = "bg:#464B5D";
        format = "[[($all_status$ahead_behind )](fg:#82AAFF bg:#464B5D)]($style)";
      };

      nodejs = {
        symbol = " ";
        style = "bg:#1F2233";
        format = "[[ $symbol($version) ](fg:#82AAFF bg:#1F2233)]($style)";
      };

      rust = {
        symbol = " ";
        style = "bg:#1F2233";
        format = "[[ $symbol($version) ](fg:#82AAFF bg:#1F2233)]($style)";
      };

      golang = {
        symbol = " ";
        style = "bg:#1F2233";
        format = "[[ $symbol($version) ](fg:#82AAFF bg:#1F2233)]($style)";
      };

      nix_shell = {
        symbol = " ";
        style = "bg:#1F2233";
        format = "[[ $symbol$state ](fg:#82AAFF bg:#1F2233)]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:#181A29";
        format = "[[  $time ](fg:#8F93A2 bg:#181A29)]($style)";
      };
    };
  };

  programs.autojump.enable = true;

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
