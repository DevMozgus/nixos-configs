# MCP server configuration — Context7 (docs), playwright + chrome-devtools (browser),
# sequential-thinking (reasoning), astro-docs (Astro framework)
# Servers are defined once via mcp-servers-nix and consumed by:
#   - opencode: via programs.opencode.enableMcpIntegration
#   - VS Code:  via programs.vscode.profiles.default.enableMcpIntegration
{ ... }:
let
  context7Instructions = ''
    Always use Context7 for library documentation:

    - Before suggesting code for any external library, use resolve-library-id and get-library-docs
    - Never rely on training data for framework APIs (Next.js, React, Svelte, Nixos, etc.)
    - Pull docs first, then code
    - Use version-specific documentation when available
  '';
in
{
  # Activate home-manager's centralized MCP server registry.
  programs.mcp.enable = true;

  # mcp-servers-nix populates programs.mcp.servers with Nix-store-pinned
  # server binaries for context7 and playwright.
  # nixos server disabled: aioboto3 (transitive dep) fails tests with Python 3.13.
  mcp-servers.programs = {
    context7.enable = true;
    # nixos.enable = true;

    # Browser automation (headed by default — window is visible on Hyprland).
    # Uses nixpkgs playwright-mcp + playwright-driver.browsers (chromium);
    # module auto-passes --executable-path (default: pkgs.chromium).
    playwright.enable = true;

    # Chrome DevTools protocol debugging (console, network, performance traces).
    # Same executable pattern as playwright; pairs with the vendored
    # accessibility-audit / accessibility-fix opencode skills.
    chrome-devtools.enable = true;

    # Structured reasoning scratchpad (zero-config stdio server from nixpkgs).
    sequential-thinking.enable = true;
  };

  # Custom remote HTTP servers
  mcp-servers.settings.servers = {
    "astro-docs" = {
      url = "https://mcp.docs.astro.build/mcp";
    };
  };

  # Both opencode and VS Code read from programs.mcp.servers when these
  # flags are set. VS Code writes ~/.config/Code/User/mcp.json;
  # opencode merges into opencode.json under the "mcp" key.
  programs.opencode.enableMcpIntegration = true;
  programs.vscode.profiles.default.enableMcpIntegration = true;

  # System prompt: always consult Context7 before suggesting library code.
  programs.opencode.context = context7Instructions;
  programs.vscode.profiles.default.userSettings."github.copilot.chat.codeGeneration.instructions" = [
    { text = context7Instructions; }
  ];
}
