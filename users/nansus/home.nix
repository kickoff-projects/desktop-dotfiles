{ lib, pkgs, ... }:

# The leisure account. It takes common/home.nix and the options below.
# It uses a black and rainbow variant of the shared theme. Every surface is
# pure black. The text, the borders and the graphs carry the colour, and the
# backgrounds do not.
# The files per surface live in ./.config, for waybar and hypr. They go on
# top of hostDir/.config and common/.config.
# Foot keeps the 16 rainbow ANSI colours without a change. Only its
# background goes to true black, below.
let
  palettes = import ../../common/palettes.nix;
  renderFootColors = import ../../common/lib/render-foot-colors.nix;
  renderKak = import ../../common/lib/render-kak.nix;
in
{
  # prismlauncher stays with this account. It does not move to
  # common/home.nix. Read common/home.nix for the applications that every
  # account shares.
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
