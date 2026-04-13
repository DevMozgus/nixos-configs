{ stdenv, lib, fetchzip, ... }:

stdenv.mkDerivation rec {
  pname = "beads-viewer";
  version = "0.15.2";

  src = fetchzip {
    url = "https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_linux_${stdenv.hostPlatform.parsed.cpu.name}.tar.gz";
    sha256 = stdenv.hostPlatform.parsed.cpu.name == "x86_64"
      ? "467c7dee72c599e915d638eb22335a91eb842171eddc2e7baf43129058a7664e"
      : "4bc9b327cedd54b08b55c445362ba74017cc8ae40530ba6f0451b866b47441be";
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
