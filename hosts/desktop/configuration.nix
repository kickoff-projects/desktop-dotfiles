{ config, pkgs, lib, inputs, ... }:

{

# Same module set as hosts/laptop/configuration.nix, in the same order.
# The deliberate differences are called out in comments below. All but one
# are hardware: no TLP (nothing to save battery on), no Intel microcode
# (Ryzen 7 3700X). The GPU side is not handled here at all - nixos-hardware's
# lenovo-legion-t526amr5 module, wired up in flake.nix, owns the nvidia
# driver for this host the same way lenovo-legion-16ithg6 does for the
# Laptop. The one non-hardware difference is graceful_boot.nix, which has
# never been enabled on the Laptop in any commit, so it stays desktop only.
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
      # power.nix is Laptop only on purpose: it is TLP with battery charge
      # thresholds, AC/BAT governors and Intel GPU frequencies, none of which
      # apply to a desktop on mains with an AMD CPU and an nvidia GPU.
      #../../system/hardware/power.nix
      #../../system/hardware/roccat.nix
      # The AX200 card in this box brings bluetooth (hci0) just like the
      # Laptop's, so blueman from StartPrograms.conf has something to talk to
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

  # Define hostname
  networking.hostName = "NanSuS-Desktop";

}
