{
  stdenv,
  lib,
  fetchzip,
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

  src = fetchzip {
    url = "https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_linux_${arch}.tar.gz";
    sha256 =
      if stdenv.hostPlatform.parsed.cpu.name == "x86_64" then
        "467c7dee72c599e915d638eb22335a91eb842171eddc2e7baf43129058a7664e"
      else
        "4bc9b327cedd54b08b55c445362ba74017cc8ae40530ba6f0451b866b47441be";
    stripRoot = false;
  };

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;

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
