{ config, pkgs, lib, inputs, ... }:

{

# Commented are usually convenient to have in some situations
imports =
    [
      # ---- Hardware ----
      ./hardware.nix

      # ---- Shared base, see common/system.nix ----
      ../../common/system.nix

      # ----  Base (this host only) ----
      ../../system/base/hyprland.nix
      ../../system/base/locale/Finnish_locale.nix
      ../../system/base/screen_shot.nix
      #../../system/base/terminator.nix

      # ---- hardware (this host only) ----
      ../../system/hardware/power.nix
      #../../system/hardware/roccat.nix
      ../../system/hardware/bluetooth.nix

      # ---- games ----
      ../../system/games/steam.nix
      ../../system/games/gamemode.nix

      # ---- Security ----
      #../../system/security/sshd.nix

      # proxy
      #../../system/security/mitmproxy_cert.nix
      #../../system/app/virt-manager.nix
      #../../system/app/VirtualBox.nix
      #../../system/app/Docker.nix
     ];

  # Define hostname
  networking.hostName = "NanSuS-Laptop";

}
