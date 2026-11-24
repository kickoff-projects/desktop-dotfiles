{ pkgs, ... }:

{
  # QEMU for every account. common/home.nix imports this module.
  home.packages = [ pkgs.qemu ];
}
