{ lib, pkgs, ... }:

# The work account: common/home.nix plus these. Red kakoune is the only
# override (see common/palettes.nix and common/home.nix's mkDefault for
# the mechanism). Everything else inherits the rainbow default.
let
  palettes = import ../../common/palettes.nix;
  renderKak = import ../../common/lib/render-kak.nix;
in
{
  home.packages = with pkgs; [
    git
    gh
    ripgrep

    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt

    uv
    python3

    libreoffice-qt
    openconnect
    proton-vpn
  ];

  xdg.configFile."kak/colors/account.kak".text =
    lib.mkForce (renderKak { p = palettes.red.kak; });
}
