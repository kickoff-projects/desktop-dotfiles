{ pkgs, lib,  ... }:

{

  # Firefox for every machine. common/system.nix imports this module.
  programs.firefox.enable = true;

}

