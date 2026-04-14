# peon-ping — voice notifications for AI coding agents
# OpenCode adapter reads peon.sh via ~/.claude/hooks/peon-ping/peon.sh
{
  inputs,
  pkgs,
  lib,
  ...
}:

let
  peonPkg = inputs.peon-ping.packages.${pkgs.system}.default;
in
{
  programs.peon-ping = {
    enable = true;
    package = peonPkg;

    settings = {
      default_pack = "duke_nukem";
      volume = 0.5;
      enabled = true;
      desktop_notifications = true;
      categories = {
        "session.start" = true;
        "task.complete" = true;
        "task.error" = true;
        "input.required" = true;
        "resource.limit" = true;
        "user.spam" = true;
        "task.acknowledge" = false;
      };
    };

    installPacks = [
      "duke_nukem"
      {
        name = "solid_snake";
        src = pkgs.fetchFromGitHub {
          owner = "wsturgiss";
          repo = "openpeon-solid-snake";
          rev = "v1.0.0";
          sha256 = "sha256-pAUZer6QQq5BNTvhJTMjcA/CLHlgdARGcN+GT2sX2OY=";
        };
      }
    ];

    enableZshIntegration = true;
  };

  # OpenCode adapter looks for peon.sh at ~/.claude/hooks/peon-ping/peon.sh
  # but the HM module installs runtime to ~/.openpeon/. Bridge the path.
  home.file.".claude/hooks/peon-ping/peon.sh".source = "${peonPkg}/bin/peon";

  # Install the OpenCode TypeScript plugin
  home.file.".config/opencode/plugins/peon-ping.ts".source =
    "${peonPkg}/share/peon-ping/adapters/opencode/peon-ping.ts";
}
