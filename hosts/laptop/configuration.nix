{ config, pkgs, lib, inputs, ... }:

{

# Hardware notes, open on-device checks and the hibernate/HybridSleep plan for
# this host live in ./HARDWARE-NOTES.md - read it before changing anything here,
# in system/hardware/power.nix or in system/hardware/nvidia_prime_power.nix.

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
      #../../system/base/locale/Netherlands_locale.nix
      ../../system/base/screen_shot.nix
      #../../system/base/terminator.nix

      # ---- hardware (this host only) ----
      ../../system/hardware/power.nix
      ../../system/hardware/nvidia_prime_power.nix
      #../../system/hardware/roccat.nix
      ../../system/hardware/bluetooth.nix

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

  # Lenovo's own BIOS/EC firmware updates reach this machine through fwupd
  # and nowhere else - the Desktop gets them from its motherboard vendor's
  # own tooling, so this stays per host rather than in common/system.nix.
  services.fwupd.enable = true;

  # legion-laptop is the out-of-tree driver for the parts of this chassis
  # the mainline kernel does not touch: fan curves, the power/performance
  # profile the Fn+Q key switches, keyboard backlight and the battery
  # conservation mode. Whether it is also what provides
  # /sys/firmware/acpi/platform_profile - the node TLP's
  # PLATFORM_PROFILE_ON_AC/BAT in system/hardware/power.nix write to - is
  # worth checking rather than assuming: in-tree ideapad_laptop provides it
  # on some Legions. Compare "cat /sys/firmware/acpi/platform_profile_choices"
  # with the module loaded and with these lines commented out.
  #
  # Being out-of-tree, it is the one thing here that can fail to build on a
  # kernel bump. It compiles against this host's 6.18.62; if a later kernel
  # breaks it, comment both lines out and rebuild rather than pinning the
  # kernel. legion_cli / legion_gui from the app package are the userspace
  # side and need the module loaded to do anything. On the first boot after
  # this, "dmesg | grep -i legion" is the signal: the module refuses to load
  # on a chassis it does not recognise.
  boot.extraModulePackages = [ config.boot.kernelPackages.lenovo-legion-module ];
  boot.kernelModules = [ "legion_laptop" ];
  environment.systemPackages = [ pkgs.lenovo-legion ];

  # Define hostname
  networking.hostName = "NanSuS-Laptop";

}
