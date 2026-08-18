# oh-my-opencode-slim plugin configuration for OpenCode
# Multi-agent orchestration: Orchestrator, Explorer, Oracle, Council, Librarian, Designer, Fixer
{ config, lib, ... }:
{
  xdg.configFile."opencode/oh-my-opencode-slim.jsonc".text = builtins.toJSON {
    "$schema" = "https://unpkg.com/oh-my-opencode-slim@latest/oh-my-opencode-slim.schema.json";

    preset = "zai-plan";

    presets = {
      "zai-plan" = {
        orchestrator = {
          model = "zai-coding-plan/glm-5.3";
          variant = "medium";
          skills = [ "*" ];
          mcps = [ "*" ];
        };
        oracle = {
          model = "zai-coding-plan/glm-4.7";
          variant = "high";
          skills = [ "*" ];
          mcps = [ "*" ];
        };
        librarian = {
          model = "zai-coding-plan/glm-4.7";
          variant = "high";
          skills = [ ];
          mcps = [
            "websearch"
            "context7"
            "gh_grep"
          ];
        };
        explorer = {
          model = "zai-coding-plan/glm-4.7";
          variant = "high";
          skills = [ ];
          mcps = [ ];
        };
        designer = {
          model = "zai-coding-plan/glm-4.7";
          variant = "medium";
          skills = [ "*" ];
          mcps = [ ];
        };
        fixer = {
          model = "zai-coding-plan/glm-4.7";
          variant = "high";
          skills = [ "*" ];
          mcps = [
            "context7"
            "websearch"
          ];
        };
        council = {
          model = "zai-coding-plan/glm-5-turbo";
          variant = "high";
        };
      };
    };

    council = {
      default_preset = "default";
      presets = {
        default = {
          reviewer = {
            model = "zai-coding-plan/glm-4.7";
            variant = "high";
          };
          architect = {
            model = "zai-coding-plan/glm-4.7";
            variant = "high";
          };
          optimiser = {
            model = "zai-coding-plan/glm-4.7";
            variant = "high";
          };
        };
      };
    };
  };
}
