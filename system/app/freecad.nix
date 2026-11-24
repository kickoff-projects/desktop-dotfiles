{ pkgs, ... }:

{
  # FreeCAD for every account. common/home.nix imports this module.
  home.packages = [ pkgs.freecad ];
}
