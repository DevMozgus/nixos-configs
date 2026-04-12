# oh-my-opencode-slim plugin configuration for OpenCode
# Multi-agent orchestration: Orchestrator, Explorer, Oracle, Council, Librarian, Designer, Fixer
{ config, lib, ... }:
{
  xdg.configFile."opencode/oh-my-opencode-slim.json".text = builtins.toJSON {
    "$schema" = "https://unpkg.com/oh-my-opencode-slim@latest/oh-my-opencode-slim.schema.json";

    agents = {
      orchestrator = {
        model = "zai-coding-plan/glm-5";
        variant = "medium";
      };

      explorer = {
        model = "zai-coding-plan/glm-4.7-flash";
        variant = "low";
      };

      oracle = {
        model = "zai-coding-plan/glm-5";
        variant = "high";
      };

      librarian = {
        model = "zai-coding-plan/glm-4.7-flash";
        variant = "low";
      };

      designer = {
        model = "zai-coding-plan/glm-4.7";
        variant = "low";
      };

      fixer = {
        model = "zai-coding-plan/glm-4.7-flash";
        variant = "low";
      };
    };

    council = {
      master = {
        model = "zai-coding-plan/glm-5";
        variant = "high";
      };
      presets.default = {
        councillor1.model = "zai-coding-plan/glm-4.7";
        councillor2.model = "zai-coding-plan/glm-4.7-flash";
      };
    };

    tmux = {
      enable = false;
    };

    mcp = {
      context7 = {
        permissions = [ "search" ];
      };

      fetch = {
        permissions = [ "fetch" ];
      };

      nixos = {
        permissions = [ "nix" ];
      };

      astroDocs = {
        permissions = [ "search" ];
      };
    };
  };
}
