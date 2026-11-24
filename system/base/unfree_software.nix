{ config, lib, pkgs, ... }:

{
  # This option lets every machine build packages with an unfree licence.
  # common/system.nix imports this module, and it also sets the same option
  # directly. See item 2 of AUDIT-findings-server-and-unfree.md.
  nixpkgs.config.allowUnfree = true;
}
