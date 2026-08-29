# opencode — AI coding CLI with Material Deep Ocean theme
{
  config,
  lib,
  pkgs,
  ...
}:
let
  c = config.lib.stylix.colors;
in
{
  home.sessionVariables = {
    OPENCODE_ENABLE_EXA = "1";
    OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS = "true";
  };

  programs.opencode = {
    enable = true;
    tui.theme = lib.mkForce "material-deep-ocean";
    settings.lsp = true;
    settings.agent = {
      general.disable = true;
      explore.disable = true;
    };
    settings.plugin = [
      "oh-my-opencode-slim"
      "@tarquinen/opencode-dcp@latest"
    ];
    settings.permission.websearch = "allow";
    # Dangerous commands require approval before running; everything else
    # executes freely.
    settings.permission.bash = {
      # Filesystem destruction / ownership
      "rm" = "ask";
      "rm *" = "ask";
      "chmod *" = "ask";
      "chown *" = "ask";
      "shred *" = "ask";
      # Raw disk operations
      "dd" = "ask";
      "dd *" = "ask";
      "mkfs *" = "ask";
      "mkfs.ext2 *" = "ask";
      "mkfs.ext3 *" = "ask";
      "mkfs.ext4 *" = "ask";
      "mkfs.btrfs *" = "ask";
      "mkfs.fat *" = "ask";
      "mkfs.vfat *" = "ask";
      "mkfs.xfs *" = "ask";
      # Privilege escalation
      "sudo" = "deny";
      "sudo *" = "deny";
      # System state
      "nixos-rebuild" = "ask";
      "nixos-rebuild *" = "ask";
      "systemctl *" = "ask";
      "shutdown *" = "ask";
      "reboot" = "ask";
      "poweroff" = "ask";
      # Git
      "git" = "ask";
      "git *" = "ask";
      "git status" = "allow";
      "git status *" = "allow";
      "git diff" = "allow";
      "git diff *" = "allow";
      "git log" = "allow";
      "git log *" = "allow";
      # Arbitrary code / network fetches (paired with sandbox domain allowlist)
      "curl" = "ask";
      "curl *" = "ask";
      "wget" = "ask";
      "wget *" = "ask";
    };
  };

  home.file.".config/opencode/themes/material-deep-ocean.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/theme.json";
    theme = {
      primary = "#${c.base0D}";
      secondary = "#${c.base0C}";
      accent = "#${c.base0E}";
      error = "#${c.base08}";
      warning = "#${c.base09}";
      success = "#${c.base0B}";
      info = "#${c.base0C}";
      text = "#${c.base05}";
      textMuted = "#${c.base03}";
      background = "#${c.base00}";
      backgroundPanel = "#${c.base01}";
      backgroundElement = "#${c.base01}";
      border = "#${c.base02}";
      borderActive = "#${c.base03}";
      borderSubtle = "#${c.base02}";
      diffAdded = "#${c.base0B}";
      diffRemoved = "#${c.base08}";
      diffContext = "#${c.base03}";
      diffHunkHeader = "#${c.base03}";
      diffHighlightAdded = "#${c.base0B}";
      diffHighlightRemoved = "#${c.base08}";
      diffAddedBg = "#${c.base01}";
      diffRemovedBg = "#${c.base01}";
      diffContextBg = "#${c.base01}";
      diffLineNumber = "#${c.base02}";
      diffAddedLineNumberBg = "#${c.base01}";
      diffRemovedLineNumberBg = "#${c.base01}";
      markdownText = "#${c.base05}";
      markdownHeading = "#${c.base0D}";
      markdownLink = "#${c.base0D}";
      markdownLinkText = "#${c.base0C}";
      markdownCode = "#${c.base0B}";
      markdownBlockQuote = "#${c.base03}";
      markdownEmph = "#${c.base09}";
      markdownStrong = "#${c.base0A}";
      markdownHorizontalRule = "#${c.base03}";
      markdownListItem = "#${c.base0D}";
      markdownListEnumeration = "#${c.base0C}";
      markdownImage = "#${c.base0D}";
      markdownImageText = "#${c.base0C}";
      markdownCodeBlock = "#${c.base05}";
      syntaxComment = "#${c.base03}";
      syntaxKeyword = "#${c.base0E}";
      syntaxFunction = "#${c.base0D}";
      syntaxVariable = "#${c.base05}";
      syntaxString = "#${c.base0B}";
      syntaxNumber = "#${c.base09}";
      syntaxType = "#${c.base0A}";
      syntaxOperator = "#${c.base0C}";
      syntaxPunctuation = "#${c.base05}";
    };
  };
}
