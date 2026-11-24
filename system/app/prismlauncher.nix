{ pkgs, ... }:

{
  # The Minecraft launcher. This module belongs to one account only:
  # users/nansus/home.nix imports it, and common/home.nix does not.
  home.packages = [ pkgs.prismlauncher ];
}
