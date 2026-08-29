# opencode agent sandboxing — bubblewrap isolation via the opencode-sandbox
# plugin (@anthropic-ai/sandbox-runtime bundled through npm; only bwrap is
# needed on PATH). Global policy lives here; per-project overrides can be
# placed imperatively in ~/.config/opencode-sandbox/projects/<name>.json.
# Temporarily disable with OPENCODE_DISABLE_SANDBOX=1.
{ pkgs, ... }:
{
  # sandbox-runtime execs bubblewrap for filesystem + network isolation
  home.packages = [ pkgs.bubblewrap ];

  # Register the plugin (list-concatenates with settings.plugin in ./opencode.nix)
  programs.opencode.settings.plugin = [ "opencode-sandbox" ];

  # Global sandbox policy. Path precedence: allowRead > denyRead;
  # denyWrite > allowWrite. "." = project working directory.
  xdg.configFile."opencode-sandbox/config.json".text = builtins.toJSON {
    filesystem = {
      denyRead = [
        "~/.ssh"
        "~/.gnupg"
        "~/.aws"
        "~/.azure"
        "~/.config/gcloud"
        "~/.config/gh"
        "~/.kube"
        "~/.docker/config.json"
        "~/.npmrc"
        "~/.netrc"
        "~/.env"
        "~/.config/1Password"
        "~/.config/opencode/auth.json"
        "~/.config/syncthing"
      ];
      allowRead = [ ];
      allowWrite = [
        "."
        "/tmp"
      ];
      denyWrite = [
        ".env.production"
        ".env.local"
        ".env.development"
        ".env.test"
        ".env"
      ];
    };
    network = {
      allowedDomains = [
        # LLM providers (zai-coding-plan/glm is the primary)
        "api.z.ai"
        "api.anthropic.com"
        "api.openai.com"
        # Package registries
        "registry.npmjs.org"
        "*.npmjs.org"
        "pypi.org"
        "files.pythonhosted.org"
        # Git hosting
        "github.com"
        "*.github.com"
        "*.githubusercontent.com"
        # Nix caches
        "cache.nixos.org"
        "cachix.org"
        "*.cachix.org"
        # MCP backends
        "context7.com"
        "mcp.docs.astro.build"
        # opencode itself (docs/plugin resolution)
        "opencode.ai"
      ];
      deniedDomains = [ ];
      # NixOS: agents need the nix-daemon unix socket (/nix/var/nix/daemon-socket)
      allowAllUnixSockets = true;
    };
    disabled = false;
  };
}
