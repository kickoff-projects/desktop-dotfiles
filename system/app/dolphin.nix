{ pkgs, ... }:

{
  # The KDE file manager, for every account. common/home.nix imports this
  # module. thunar is the other file manager, in system/app/thunar.nix.
  home.packages = [ pkgs.kdePackages.dolphin ];
}
