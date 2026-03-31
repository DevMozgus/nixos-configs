# Custom package derivations — callPackage all custom packages
{ pkgs }:
{
  materialDeepOceanPlymouth = pkgs.callPackage ./plymouth-material-deep-ocean { };
}
