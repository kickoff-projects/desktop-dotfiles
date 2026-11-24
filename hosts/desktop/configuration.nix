{ config, pkgs, lib, inputs, ... }:

{

# The same module set as hosts/laptop/configuration.nix, in the same order.
# The comments below name each difference.
#
# Nearly every difference is hardware. This host has no TLP, because it has
# no battery. It has no Intel microcode, because it has a Ryzen 7 3700X CPU.
# This file does not set up the GPU. The lenovo-legion-t526amr5 module of
# nixos-hardware holds the nvidia driver for this host. flake.nix imports
# that module. The laptop uses lenovo-legion-16ithg6 in the same way.
#
# One difference is not hardware: graceful_boot.nix. The laptop does not
# use it, so it stays on the desktop only.
# Commented are usually convenient to have in some situations
imports =
    [
      # ---- Hardware ----
      ./hardware.nix

      # ---- Shared base, see common/system.nix ----
      ../../common/system.nix

      # ----  Base (this host only) ----
      ../../system/base/graceful_boot.nix
      ../../system/base/hyprland.nix
      ../../system/base/locale/Finnish_locale.nix
      #../../system/base/locale/Netherlands_locale.nix
      ../../system/base/screen_shot.nix
      #../../system/base/terminator.nix

      # ---- hardware (this host only) ----
      # power.nix serves the laptop only. It holds TLP with battery charge
      # thresholds, AC and BAT governors, and Intel GPU frequencies. None of
      # those apply to a desktop on mains power with an AMD CPU and an
      # nvidia GPU.
      #../../system/hardware/power.nix
      #../../system/hardware/roccat.nix
      # The AX200 card in this machine gives bluetooth on hci0, like the
      # card of the laptop. blueman from StartPrograms.conf can therefore
      # reach a device.
      ../../system/hardware/bluetooth.nix
      # DDC/CI brightness over DP-3. Read the comment in the module. This
      # module serves the desktop only. The laptop controls its panel
      # through /sys/class/backlight.
      ../../system/hardware/ddc.nix

      # ---- games ----
      ../../system/games/steam.nix
      ../../system/games/gamemode.nix

      # ---- Security ----
      #../../system/security/sshd.nix

      # proxy
      #../../system/security/mitmproxy_cert.nix
     ];

  # fastfetch greeting on every new interactive shell
  programs.zsh.interactiveShellInit = ''
    fastfetch
  '';

  # Define hostname
  networking.hostName = "NanSuS-Desktop";

}
