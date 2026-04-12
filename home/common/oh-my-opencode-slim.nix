# oh-my-opencode-slim plugin configuration for OpenCode
# Multi-agent orchestration: Orchestrator, Explorer, Oracle, Council, Librarian, Designer, Fixer
{ config, lib, ... }:
{
  xdg.configFile."opencode/oh-my-opencode-slim.json".text = builtins.toJSON {
    "$schema" = "https://unpkg.com/oh-my-opencode-slim@latest/oh-my-opencode-slim.schema.json";

    preset = "zai-plan";

    presets = {
      "zai-plan" = {
        orchestrator = {
          model = "zai-coding-plan/glm-5";
          variant = "high";
          skills = [ "*" ];
          mcps = [ "*" ];
        };
        oracle = {
          model = "zai-coding-plan/glm-5";
          variant = "high";
          skills = [ ];
          mcps = [ ];
        };
        librarian = {
          model = "zai-coding-plan/glm-5";
          variant = "low";
          skills = [ ];
          mcps = [
            "websearch"
            "context7"
            "grep_app"
          ];
        };
        explorer = {
          model = "zai-coding-plan/glm-5";
          variant = "low";
          skills = [ ];
          mcps = [ ];
        };
        designer = {
          model = "zai-coding-plan/glm-5";
          variant = "medium";
          skills = [ "agent-browser" ];
          mcps = [ ];
        };
        fixer = {
          model = "zai-coding-plan/glm-5";
          variant = "low";
          skills = [ ];
          mcps = [ "context7" ];
        };
      };
    };

    tmux = {
      enabled = false;
    };
  };
}
