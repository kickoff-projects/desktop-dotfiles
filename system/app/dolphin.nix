{ pkgs, lib,  ... }:

{

  # Dolphin file manager, this is what $fileManager
  # points at in .config/hypr/UserConfigs/Keybinds.conf
  environment.systemPackages = [
    pkgs.kdePackages.dolphin
  ];

}
