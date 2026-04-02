# VSCodium + nix-vscode-extensions overlay + Stylix colorCustomizations
{ pkgs, config, lib, ... }:
{
  # Tell VS Code to use the libsecret/GNOME Keyring backend for credential storage
  home.file.".vscode/argv.json".text = builtins.toJSON {
    "password-store" = "gnome-libsecret";
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = false;

    profiles.default = {
      extensions = with pkgs.vscode-marketplace; [
        astro-build.astro-vscode
        bbenoist.nix
        bradlc.vscode-tailwindcss
        cardinal90.multi-cursor-case-preserve
        christian-kohler.npm-intellisense
        dbaeumer.vscode-eslint
        dsznajder.es7-react-js-snippets
        eamodio.gitlens
        ecmel.vscode-html-css
        esbenp.prettier-vscode
        formulahendry.auto-rename-tag
        github.copilot-chat
        github.vscode-github-actions
        golang.go
        graphql.vscode-graphql
        graphql.vscode-graphql-syntax
        jnoortheen.nix-ide
        jock.svg
        mechatroner.rainbow-csv
        mikestead.dotenv
        mquandalle.graphql
        mrmlnc.vscode-scss
        ms-azuretools.vscode-containers
        ms-azuretools.vscode-docker
        ms-dotnettools.csharp
        ms-dotnettools.vscode-dotnet-runtime
        mxsdev.typescript-explorer
        parthr2031.colorful-comments
        pkief.material-icon-theme
        sst-dev.opencode
        streetsidesoftware.code-spell-checker
        streetsidesoftware.code-spell-checker-austrian-german
        streetsidesoftware.code-spell-checker-british-english
        svelte.svelte-vscode
        t3dotgg.vsc-material-theme-but-i-wont-sue-you
        vscodevim.vim
        xabikos.javascriptsnippets
        yinfei.luahelper
        yoavbls.pretty-ts-errors
      ];

      userSettings = {
        # Editor
        "editor.fontSize" = lib.mkForce 16;
        "editor.fontFamily" = "FiraCode Nerd Font, Menlo, Monaco, 'Courier New', monospace";
        "editor.fontLigatures" = true;
        "editor.fontWeight" = 500;
        "editor.formatOnSave" = true;
        "editor.lineNumbers" = "relative";
        "editor.wordWrap" = "on";
        "editor.linkedEditing" = true;
        "editor.stickyScroll.enabled" = true;
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = "active";
        "editor.suggestSelection" = "first";
        "editor.unicodeHighlight.invisibleCharacters" = false;
        "editor.inlayHints.enabled" = "off";
        "editor.minimap.enabled" = false;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.codeActionsOnSave" = {
          "source.fixAll" = "always";
        };

        # Workbench
        "workbench.colorTheme" = "Stylix";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.editor.pinnedTabsOnSeparateRow" = true;
        "workbench.secondarySideBar.defaultVisibility" = "hidden";
        "workbench.colorCustomizations" = {
          "[Stylix]" = let
            c = config.lib.stylix.colors.withHashtag;
          in {
            "editorLineNumber.activeForeground" = c.base0D;
            "editorCursor.foreground" = c.base0E;
          };
        };

        # TypeScript / JavaScript
        "typescript.inlayHints.parameterNames.enabled" = "all";
        "javascript.inlayHints.parameterNames.enabled" = "all";
        "typescript.updateImportsOnFileMove.enabled" = "always";
        "javascript.updateImportsOnFileMove.enabled" = "always";
        "[javascript]" = { "editor.defaultFormatter" = "vscode.typescript-language-features"; };
        "[typescriptreact]" = { "editor.defaultFormatter" = "vscode.typescript-language-features"; };

        # Prettier
        "prettier.bracketSameLine" = true;
        "prettier.jsxSingleQuote" = true;
        "prettier.printWidth" = 120;
        "prettier.trailingComma" = "all";
        "prettier.singleQuote" = true;
        "prettier.documentSelectors" = [ "*.{ts,tsx,js,jsx}" "*.astro" "**/*.astro" "*.svelte" "**/*.svelte" ];

        # Language-specific formatters
        "[astro]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
        "[json]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
        "[vue]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
        "[graphql]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };

        # ESLint
        "eslint.validate" = [ "typescript" "javascript" "typescriptreact" "javascriptreact" "html" "astro" ];
        "eslint.format.enable" = true;

        # Nix
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";

        # GitLens
        "gitlens.hovers.currentLine.over" = "line";
        "gitlens.ai.model" = "vscode";
        "gitlens.ai.vscode.model" = "copilot:gpt-4.1";
        "gitlens.ai.experimental.provider" = "openai";
        "gitlens.ai.experimental.openai.model" = "gpt-4-1106-preview";
        "gitlens.advanced.messages" = {
          "suppressIntegrationDisconnectedTooManyFailedRequestsWarning" = true;
        };

        # GitHub Copilot
        "github.copilot.editor.enableAutoCompletions" = true;
        "github.copilot.enable" = {
          "*" = true;
          "plaintext" = false;
          "markdown" = true;
          "scminput" = false;
        };

        # cSpell
        "cSpell.language" = "en,en-GB,en-US,de-AT";
        "cSpell.userWords" = [ "astro" "checkmark" "Dropwdown" "graphqlrc" "Mantine" "ressort" "serien" "tailwindcss" "uknown" "urql" "youtube" ];

        # Misc
        "chat.viewSessions.orientation" = "stacked";
        "npm.exclude" = "**/.**/**";
        "tailwindCSS.classAttributes" = [ "class" "className" "ngClass" "classProps" "defaultStyle" ];
        "security.workspace.trust.untrustedFiles" = "open";
        "diffEditor.ignoreTrimWhitespace" = false;
        "files.associations" = { "*.html" = "html"; };
        "explorer.confirmDragAndDrop" = false;
        "explorer.confirmDelete" = false;
        "window.title" = ''''${activeEditorShort} </>< ''${rootName}'';
        "window.newWindowDimensions" = "offset";
        "svelte.enable-ts-plugin" = true;
        "dart.debugExternalPackageLibraries" = true;
        "dart.debugSdkLibraries" = false;
        "redhat.telemetry.enabled" = false;
        "git.openRepositoryInParentFolders" = "never";
        "svg.preview.mode" = "svg";
        "material-icon-theme.files.associations" = { "*.translation.ts" = "I18n"; };
      };
    };
  };
}
