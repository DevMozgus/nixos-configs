# Zed editor — vim mode, Material Deep Ocean theme, GitHub Copilot
{ pkgs, ... }:
{
  stylix.targets.zed.enable = false;

  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor.fhs;

    # Fully declarative — Zed cannot mutate settings/keymaps
    mutableUserSettings = false;
    mutableUserKeymaps = false;

    extraPackages = with pkgs; [
      # Nix LSP + formatter
      nil
      nixfmt
    ];

    extensions = [
      "nix"
      "prettier"
      "svelte"
      "dockerfile"
      "graphql"
      "astro"
      "toml"
      "env"
      "csharp"
      "lua"
    ];

    userSettings = {
      # Vim mode
      vim_mode = true;
      relative_line_numbers = true;

      # Font (matches Stylix monospace)
      buffer_font_family = "FiraCode Nerd Font";
      buffer_font_size = 16;
      buffer_font_weight = 500;
      buffer_font_ligatures = true;

      # Terminal
      terminal = {
        font_family = "FiraCode Nerd Font";
        font_size = 14;
        shell = {
          program = "zsh";
        };
      };

      # Editor behaviour
      format_on_save = "on";
      tab_size = 2;
      soft_wrap = "preferred_line_length";
      preferred_line_length = 120;
      word_wrap = "on";
      show_whitespaces = "selection";

      # Theme (custom theme installed below)
      theme = {
        mode = "dark";
        dark = "Material Deep Ocean";
        light = "Material Deep Ocean";
      };

      # LSP
      lsp = {
        nil_ls = {
          initialization_options = {
            formatting = {
              command = [ "nixfmt" ];
            };
          };
        };
      };

      # Language-specific settings
      languages = {
        Nix = {
          language_servers = [ "nil_ls" ];
          formatter = "language_server";
          tab_size = 2;
        };
        JavaScript = {
          formatter = "prettier";
        };
        TypeScript = {
          formatter = "prettier";
        };
        TSX = {
          formatter = "prettier";
        };
        JSON = {
          formatter = "prettier";
        };
        CSS = {
          formatter = "prettier";
        };
        Svelte = {
          formatter = "prettier";
        };
        Astro = {
          formatter = "prettier";
        };
      };

      # GitHub Copilot
      features = {
        copilot = true;
      };

      # Telemetry
      telemetry = {
        metrics = false;
        diagnostics = false;
      };

      # Misc
      auto_update = false;
      usage_keyboard = true;
    };

    # Theme passed as raw JSON string — Zed uses flat dotted keys like
    # "border.variant" that conflict with Nix's nested attrset paths.
    themes = {
      "material-deep-ocean" = builtins.readFile ./zed-theme.json;
    };
  };
}
