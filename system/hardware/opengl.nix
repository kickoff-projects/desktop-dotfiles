{ pkgs, ... }:

{
  # OpenGL
#  hardware.opengl.enable = true;
#  hardware.opengl.extraPackages = with pkgs; [
#    rocmPackages.clr.icd
#  ];

  # OpenGL
  hardware.graphics.enable = true;

  # Additional 32bit graphics driver can be found
  # in system/games/steam.nix for games mostly

}
