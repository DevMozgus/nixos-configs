# MCP server configuration — Context7 (docs) + fetch (web)
# Servers are defined once via mcp-servers-nix and consumed by:
#   - opencode: via programs.opencode.enableMcpIntegration
#   - VS Code:  via programs.vscode.profiles.default.enableMcpIntegration
{ ... }:
let
  context7Instructions = ''
    Always use Context7 for library documentation:

    - Before suggesting code for any external library, use resolve-library-id and get-library-docs
    - Never rely on training data for framework APIs (Next.js, React, Astro, Svelte, Nixos, etc.)
    - Pull docs first, then code
    - Use version-specific documentation when available
  '';
in
{
  # Activate home-manager's centralized MCP server registry.
  programs.mcp.enable = true;

  # mcp-servers-nix populates programs.mcp.servers with Nix-store-pinned
  # server binaries for context7 and fetch.
  mcp-servers.programs = {
    context7.enable = true;
    fetch.enable = true;
  };

  # Both opencode and VS Code read from programs.mcp.servers when these
  # flags are set. VS Code writes ~/.config/Code/User/mcp.json;
  # opencode merges into opencode.json under the "mcp" key.
  programs.opencode.enableMcpIntegration = true;
  programs.vscode.profiles.default.enableMcpIntegration = true;

  # System prompt: always consult Context7 before suggesting library code.
  programs.opencode.rules = context7Instructions;
  programs.vscode.profiles.default.userSettings."github.copilot.chat.codeGeneration.instructions" = [
    { text = context7Instructions; }
  ];
}
