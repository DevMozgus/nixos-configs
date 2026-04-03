# VSCodium + nix-vscode-extensions overlay + Stylix colorCustomizations
{ pkgs, lib, ... }:
{
  stylix.targets.vscode.enable = false;

  # LSP and formatter for the nix-ide extension
  home.packages = with pkgs; [
    nil
    nixfmt-rfc-style
  ];

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = false;
    argvSettings = {
      "password-store" = "gnome-libsecret";
    };

    profiles.default = {
      extensions =
        let
          marketplace = pkgs.nix-vscode-extensions.vscode-marketplace-release;
        in
        [
          marketplace.astro-build.astro-vscode
          marketplace.bbenoist.nix
          marketplace.bradlc.vscode-tailwindcss
          marketplace.cardinal90.multi-cursor-case-preserve
          marketplace.christian-kohler.npm-intellisense
          marketplace.dbaeumer.vscode-eslint
          marketplace.dsznajder.es7-react-js-snippets
          marketplace.eamodio.gitlens
          marketplace.ecmel.vscode-html-css
          marketplace.esbenp.prettier-vscode
          marketplace.formulahendry.auto-rename-tag
          marketplace.github.copilot-chat
          marketplace.github.vscode-github-actions
          marketplace.golang.go
          marketplace.graphql.vscode-graphql
          marketplace.graphql.vscode-graphql-syntax
          marketplace.jnoortheen.nix-ide
          marketplace.jock.svg
          marketplace.mechatroner.rainbow-csv
          marketplace.mikestead.dotenv
          marketplace.mquandalle.graphql
          marketplace.mrmlnc.vscode-scss
          marketplace.ms-azuretools.vscode-containers
          marketplace.ms-azuretools.vscode-docker
          marketplace.ms-dotnettools.csharp
          marketplace.ms-dotnettools.vscode-dotnet-runtime
          marketplace.mxsdev.typescript-explorer
          marketplace.parthr2031.colorful-comments
          marketplace.pkief.material-icon-theme
          marketplace.sst-dev.opencode
          marketplace.streetsidesoftware.code-spell-checker
          marketplace.streetsidesoftware.code-spell-checker-austrian-german
          marketplace.streetsidesoftware.code-spell-checker-british-english
          marketplace.svelte.svelte-vscode
          marketplace.t3dotgg.vsc-material-theme-but-i-wont-sue-you
          marketplace.vscodevim.vim
          marketplace.xabikos.javascriptsnippets
          marketplace.yinfei.luahelper
          marketplace.yoavbls.pretty-ts-errors
        ];

      userSettings = {
        # Editor
        "editor.fontSize" = lib.mkForce 16;
        "editor.fontFamily" = lib.mkForce "FiraCode Nerd Font, Menlo, Monaco, 'Courier New', monospace";
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
        "workbench.colorTheme" = "Material Theme Ocean High Contrast";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.editor.pinnedTabsOnSeparateRow" = true;
        "workbench.secondarySideBar.defaultVisibility" = "hidden";
        "workbench.colorCustomizations" = {
          "[Material Theme Ocean High Contrast]" = {
            "editorLineNumber.activeForeground" = "#babed8";
            "editorCursor.foreground" = "#FFCC00";
          };
        };

        # TypeScript / JavaScript
        "typescript.inlayHints.parameterNames.enabled" = "all";
        "javascript.inlayHints.parameterNames.enabled" = "all";
        "typescript.updateImportsOnFileMove.enabled" = "always";
        "javascript.updateImportsOnFileMove.enabled" = "always";
        "[javascript]" = {
          "editor.defaultFormatter" = "vscode.typescript-language-features";
        };
        "[typescriptreact]" = {
          "editor.defaultFormatter" = "vscode.typescript-language-features";
        };

        # Prettier
        "prettier.bracketSameLine" = true;
        "prettier.jsxSingleQuote" = true;
        "prettier.printWidth" = 120;
        "prettier.trailingComma" = "all";
        "prettier.singleQuote" = true;
        "prettier.documentSelectors" = [
          "*.{ts,tsx,js,jsx}"
          "*.astro"
          "**/*.astro"
          "*.svelte"
          "**/*.svelte"
        ];

        # Language-specific formatters
        "[astro]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[json]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[vue]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[graphql]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };

        # ESLint
        "eslint.validate" = [
          "typescript"
          "javascript"
          "typescriptreact"
          "javascriptreact"
          "html"
          "astro"
        ];
        "eslint.format.enable" = true;

        # Nix (jnoortheen.nix-ide)
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.serverSettings" = {
          "nil" = {
            "formatting" = {
              "command" = [ "nixfmt" ];
            };
          };
        };
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };

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
        "cSpell.userWords" = [
          "astro"
          "checkmark"
          "Dropwdown"
          "graphqlrc"
          "Mantine"
          "ressort"
          "serien"
          "tailwindcss"
          "uknown"
          "urql"
          "youtube"
        ];

        # Misc
        "chat.viewSessions.orientation" = "stacked";
        "npm.exclude" = "**/.**/**";
        "tailwindCSS.classAttributes" = [
          "class"
          "className"
          "ngClass"
          "classProps"
          "defaultStyle"
        ];
        "security.workspace.trust.untrustedFiles" = "open";
        "diffEditor.ignoreTrimWhitespace" = false;
        "files.associations" = {
          "*.html" = "html";
        };
        "explorer.confirmDragAndDrop" = false;
        "explorer.confirmDelete" = false;
        "window.title" = "\${activeEditorShort} </>< \${rootName}";
        "window.newWindowDimensions" = "offset";
        "svelte.enable-ts-plugin" = true;
        "dart.debugExternalPackageLibraries" = true;
        "dart.debugSdkLibraries" = false;
        "redhat.telemetry.enabled" = false;
        "git.openRepositoryInParentFolders" = "never";
        "keyboard.dispatch" = "keyCode";
        "svg.preview.mode" = "svg";
        "material-icon-theme.files.associations" = {
          "*.translation.ts" = "I18n";
        };
      };
    };
  };
}
