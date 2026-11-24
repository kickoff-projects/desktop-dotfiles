{ ... }:

{
  # Network time for every machine. common/system.nix imports this module.
  services.timesyncd.enable = true;
}
