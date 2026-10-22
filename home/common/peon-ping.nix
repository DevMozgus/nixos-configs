# peon-ping — voice notifications for AI coding agents
# Self-contained module (upstream HM module has a home.file merge bug)
{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:

let
  peonPkg = inputs.peon-ping.packages.${pkgs.stdenv.hostPlatform.system}.default;

  peonConfig = {
    default_pack = "lcars";
    volume = 0.5;
    enabled = true;
    desktop_notifications = true;
    categories = {
      "session.start" = true;
      "task.complete" = true;
      "task.error" = true;
      "input.required" = true;
      "resource.limit" = false;
      "user.spam" = false;
      "task.acknowledge" = false;
    };
  };

  lcarsPack = pkgs.fetchFromGitHub {
    owner = "heidilux";
    repo = "openpeon-lcars";
    rev = "v1.0.0";
    sha256 = "sha256-8FJr45EV1ExFpe0evfNareoUItYzoa5tBAzrJadmQz4=";
  };

  packsDrv = pkgs.runCommand "peon-packs" { } ''
    mkdir -p $out
    cp -r "${lcarsPack}" "$out/lcars"
  '';

  configFile = (pkgs.formats.json { }).generate "peon-ping-config" peonConfig;
in
{
  # Runtime files (share dir minus peon.sh)
  home.file.".openpeon" = {
    source = pkgs.runCommand "peon-home-files" { } ''
      cp -r ${peonPkg}/share/peon-ping $out
      chmod -R u+w $out
      rm -f $out/peon.sh
    '';
    recursive = true;
  };

  # peon.sh wrapper
  home.file.".openpeon/peon.sh".source = "${peonPkg}/bin/peon";

  # Config
  home.file.".openpeon/config.json".source = configFile;

  # Sound packs
  home.file.".openpeon/packs".source = packsDrv;

  # PEON_DIR env var
  home.sessionVariables.PEON_DIR = "${config.home.homeDirectory}/.openpeon";

  # Claude Code hook bridge
  home.file.".claude/hooks/peon-ping/peon.sh".source = "${peonPkg}/bin/peon";

  # OpenCode TypeScript plugin
  # Local union adapter (V1 `server` + V2 `setup`) — upstream at rev de4ada79
  # only exports the OpenCode 2.x `setup` API, which the 1.x plugin loader
  # rejects ("must default export an object with server()"). Revert to
  # "${peonPkg}/share/peon-ping/adapters/opencode/peon-ping.ts" once upstream
  # ships a union export.
  home.file.".config/opencode/plugins/peon-ping.ts".source = ./peon-ping-plugin.ts;

  # Zsh integration
  programs.zsh.initContent = ''
    source ${peonPkg}/share/zsh/site-functions/_peon 2>/dev/null || true
    alias peon="${peonPkg}/bin/peon"
  '';
}
