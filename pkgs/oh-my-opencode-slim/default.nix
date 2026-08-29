# oh-my-opencode-slim skills, built from upstream source instead of vendored
# copies. Exposes $out/skills/<name> for home/common/opencode-skills.nix.
#
# Update procedure: bump `version` to the latest tag at
# https://github.com/alvinunreal/oh-my-opencode-slim/tags, then refresh `hash`:
#   nix store prefetch-file --unpack \
#     https://github.com/alvinunreal/oh-my-opencode-slim/archive/refs/tags/v<version>.tar.gz
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "oh-my-opencode-slim-skills";
  version = "2.2.17";

  src = fetchFromGitHub {
    owner = "alvinunreal";
    repo = "oh-my-opencode-slim";
    rev = "v${version}";
    hash = "sha256-v0mtLl9wUEql76ZwDRBNnwuFSINat+8qt75megH7dVY=";
  };

  installPhase = ''
    runHook preInstall

    cp -r src/skills $out/skills

    runHook postInstall
  '';

  meta = {
    description = "Skill sources from alvinunreal/oh-my-opencode-slim (only src/skills)";
    homepage = "https://github.com/alvinunreal/oh-my-opencode-slim";
    license = lib.licenses.mit;
  };
}
