# opencode — AI coding CLI with Material Deep Ocean theme
{ config, lib, ... }:
let
  c = config.lib.stylix.colors;
in
{
  programs.opencode = {
    enable = true;
    settings.theme = lib.mkForce "material-deep-ocean";
  };

  home.file.".config/opencode/themes/material-deep-ocean.json".text =
    builtins.toJSON {
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
