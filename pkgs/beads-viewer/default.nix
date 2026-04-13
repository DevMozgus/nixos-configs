{
  stdenv,
  lib,
  fetchurl,
  ...
}:

stdenv.mkDerivation rec {
  pname = "beads-viewer";
  version = "0.15.2";

  arch =
    if stdenv.hostPlatform.parsed.cpu.name == "x86_64" then
      "amd64"
    else if stdenv.hostPlatform.parsed.cpu.name == "aarch64" then
      "arm64"
    else
      stdenv.hostPlatform.parsed.cpu.name;

  src = fetchurl {
    url = "https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_linux_${arch}.tar.gz";
    sha256 =
      if stdenv.hostPlatform.parsed.cpu.name == "x86_64" then
        "0kk6lxc904j3mxxjxp7df4hq9swib8rj5srqsqayk6f5fbp7sz26"
      else
        "1gj1fjs6df2i0ipvlc05wj5cq5s0lwmkcif4an5v0m6xrqkv7jab";
  };

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;

  unpackPhase = ''
    tar -xzf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bv $out/bin/
    chmod +x $out/bin/bv
  '';

  meta = with lib; {
    description = "Graph-aware TUI for Beads issue tracker: PageRank, critical path, kanban, dependency DAG visualization, and robot-mode JSON API";
    homepage = "https://github.com/Dicklesworthstone/beads_viewer";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "bv";
  };
}
