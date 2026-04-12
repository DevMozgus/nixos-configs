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
          model = "zai-coding-plan/glm-4.7";
          variant = "high";
          skills = [ ];
          mcps = [ ];
        };
        librarian = {
          model = "zai-coding-plan/glm-4.7";
          variant = "medium";
          skills = [ ];
          mcps = [
            "websearch"
            "context7"
            "grep_app"
          ];
        };
        explorer = {
          model = "zai-coding-plan/glm-4.7";
          variant = "medium";
          skills = [ ];
          mcps = [ ];
        };
        designer = {
          model = "zai-coding-plan/glm-4.7";
          variant = "medium";
          skills = [
            "agent-browser"
            "frontend-design"
          ];
          mcps = [ ];
        };
        fixer = {
          model = "zai-coding-plan/glm-4.7";
          variant = "medium";
          skills = [ ];
          mcps = [
            "context7"
            "websearch"
          ];
        };
      };
    };

    council = {
      master = {
        model = "zai-coding-plan/glm-5";
        prompt = "Prioritise correctness and security over creativity. Flag any risks.";
      };
      presets = {
        default = {
          reviewer = {
            model = "zai-coding-plan/glm-4.7";
            prompt = "You are a meticulous code reviewer. Focus on edge cases, error handling, and potential bugs.";
            mcps = [ "context7" ];
          };
          architect = {
            model = "zai-coding-plan/glm-4.7";
            prompt = "You are a systems architect. Focus on design patterns, scalability, and maintainability.";
            mcps = [ "context7" ];
          };
          optimiser = {
            model = "zai-coding-plan/glm-4.7";
            prompt = "You are a performance specialist. Focus on latency, throughput, and resource usage.";
            mcps = [ "context7" ];
          };
        };
      };
    };

    tmux = {
      enabled = false;
    };
  };
}
