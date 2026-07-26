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
          model = "zai-coding-plan/glm-5.1";
          variant = "high";
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
          model = "zai-coding-plan/glm-4.7-flash";
          variant = "high";
          skills = [ ];
          mcps = [
            "websearch"
            "context7"
            "gh_grep"
          ];
        };
        explorer = {
          model = "zai-coding-plan/glm-4.7-flash";
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
          model = "zai-coding-plan/glm-5.1";
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
            prompt = "You are a meticulous code reviewer. Focus on edge cases, error handling, and potential bugs.";
          };
          architect = {
            model = "zai-coding-plan/glm-4.7";
            variant = "high";
            prompt = "You are a systems architect. Focus on design patterns, scalability, and maintainability.";
          };
          optimiser = {
            model = "zai-coding-plan/glm-4.7";
            variant = "high";
            prompt = "You are a performance specialist. Focus on latency, throughput, and resource usage.";
          };
        };
      };
    };
  };
}
