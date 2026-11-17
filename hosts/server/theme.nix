{ lib, ... }:

# Red kak + foot for whichever account lands on the Server - see
# common/palettes.nix and common/home.nix's mkDefault for the mechanism.
# Imported conditionally by flake.nix's homeFor when a host directory has
# a theme.nix, the same way hostDir/.config is picked up optionally.
let
  palettes = import ../../common/palettes.nix;
  renderKak = import ../../common/lib/render-kak.nix;
  renderFootColors = import ../../common/lib/render-foot-colors.nix;
in
{
  xdg.configFile."kak/colors/account.kak".text =
    lib.mkForce (renderKak { p = palettes.red.kak; });
  xdg.configFile."foot/colors.ini".text =
    lib.mkForce (renderFootColors { p = palettes.red.foot; });
}
