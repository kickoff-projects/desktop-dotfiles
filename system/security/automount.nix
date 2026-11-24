{ ... }:

{
  # Automatic mounting of a removable disk, on every machine.
  # common/system.nix imports this module. devmon watches for the disk,
  # udisks2 mounts it, and gvfs gives the file managers access to it.
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
}
