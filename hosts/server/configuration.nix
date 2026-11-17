{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      # ---- Hardware ----
      ./hardware.nix

      # ---- Shared base, see common/system.nix ----
      ../../common/system.nix

      # ----  Base (this host only) ----
      ../../system/base/locale/Finnish_locale.nix

      # ---- hardware (this host only) ----
      ../../system/hardware/nvidia_proprietary.nix

      # ---- Security ----
      #../../system/security/sshd.nix
     ];

  # Runs sway, not hyprland - a headless/minimal box, no blur, shadows or
  # window animations by design. See .config/sway/{config,colors}.
  programs.sway.enable = true;

  environment.systemPackages = with pkgs; [
     # sway's screenshot tools - hyprshot/grimblast (system/base/screen_shot.nix)
     # are hyprland-only, so this host gets grim+slurp directly instead
     grim
     slurp
     swayimg
     gimp

     # the focused-window screenshot bind in .config/sway/config pipes
     # swaymsg's tree through jq, and the clipboard binds need wl-copy
     jq
     wl-clipboard
  ];

  # Define hostname
  networking.hostName = "NixOS-Server";

}
