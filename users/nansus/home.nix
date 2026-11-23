{ lib, pkgs, ... }:

# The leisure account: common/home.nix plus these. Runs a black/rainbow
# variant of the shared theme - every surface goes pure black and the color
# is carried by text, borders and graphs instead of by backgrounds. The
# per-surface files live in ./.config (waybar, hypr), layered on top of
# hostDir/.config and common/.config. Foot keeps the rainbow sixteen ANSI
# colors verbatim - only its background is pulled to true black, below.
let
  palettes = import ../../common/palettes.nix;
  renderFootColors = import ../../common/lib/render-foot-colors.nix;
  renderKak = import ../../common/lib/render-kak.nix;
in
{
  # prismlauncher stays per-account rather than moving to common/home.nix -
  # see common/home.nix for the apps shared by every account.
  imports = [ ../../system/app/prismlauncher.nix ];

  home.packages = with pkgs; [
    ripgrep
    unzip
    uv
    net-tools
    vim
    neovim

    openconnect
    feh
    claude-code
  ];

  xdg.configFile."foot/colors.ini".text =
    lib.mkForce (renderFootColors {
      p = palettes.rainbow.foot // { background = "000000"; foreground = "9574f6"; bright7 = "9ed6b4"; };
    });

  xdg.configFile."kak/colors/account.kak".text =
    lib.mkForce (renderKak {
      p = palettes.rainbow.kak // { base00 = "000000"; base05 = "9e9ed6"; base06 = "9ed6b4"; };
    });
}
