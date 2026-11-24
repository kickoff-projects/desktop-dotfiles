{ config, pkgs, lib, inputs, ... }:

{

# ./HARDWARE-NOTES.md holds the hardware notes for this host. It also holds
# the open on-device checks and the plan for hibernate and HybridSleep.
# Read that file before you change this file, system/hardware/power.nix or
# system/hardware/nvidia_prime_power.nix.

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

  # fwupd is the only route for the Lenovo BIOS updates and EC firmware
  # updates on this machine. The desktop gets its updates from the tools of
  # its motherboard vendor. This option therefore stays in the host file, and
  # not in common/system.nix.
  services.fwupd.enable = true;

  # legion-laptop is the external driver for the parts of this chassis that
  # the mainline kernel does not control:
  #  - the fan curves
  #  - the power profile and performance profile of the Fn+Q key
  #  - the keyboard backlight
  #  - the battery conservation mode
  #
  # This module possibly also gives /sys/firmware/acpi/platform_profile. That
  # node is the target of PLATFORM_PROFILE_ON_AC and PLATFORM_PROFILE_ON_BAT
  # in system/hardware/power.nix. The in-tree ideapad_laptop module gives the
  # same node on some Legion models, so test this instead of an assumption.
  # Run "cat /sys/firmware/acpi/platform_profile_choices" two times: first
  # with the module loaded, then with these lines commented out.
  #
  # The module is external to the kernel tree. It is therefore the one part
  # of this file that can fail to build after a kernel change. If a later
  # kernel breaks it, comment both lines out and rebuild. Do not pin the
  # kernel.
  # legion_cli and legion_gui come from the application package. They are the
  # user space side, and they need the loaded module.
  # Run "dmesg | grep -i legion" on the first boot after a change. The module
  # refuses to load on a chassis that it does not recognise.
  boot.extraModulePackages = [ config.boot.kernelPackages.lenovo-legion-module ];
  boot.kernelModules = [ "legion_laptop" ];
  environment.systemPackages = [ pkgs.lenovo-legion ];

  # Define hostname
  networking.hostName = "NanSuS-Laptop";

}
