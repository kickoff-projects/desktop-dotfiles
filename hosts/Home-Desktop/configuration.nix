{ config, pkgs, lib, inputs, ... }:

{

# Same module set as hosts/Laptop/configuration.nix, in the same order. The
# only deliberate differences are called out in comments below, and they are
# all hardware or location: no TLP (nothing to save battery on), no Intel
# microcode (Ryzen 7 3700X), and the Netherlands locale this box sits in.
# The GPU side is not handled here at all - nixos-hardware's
# lenovo-legion-t526amr5 module, wired up in flake.nix, owns the nvidia
# driver for this host the same way lenovo-legion-16ithg6 does for the
# Laptop.
# Commented are usually convenient to have in some situations
imports =
    [
      # ---- Hardware ----
      ./Desktop-hw.nix

      # ----  Base  ----
      ../../system/base/boot.nix
      ../../system/base/graceful_boot.nix
      ../../system/base/gnome_lockscreen.nix
      ../../system/base/unfree_software.nix
      ../../system/base/fonts.nix
      ../../system/base/hyprland.nix
      ../../system/base/networking.nix
      # This host lives in the Netherlands, the Laptop travels on
      # Finnish_locale.nix - the only non hardware difference left
      ../../system/base/locale/Netherlands_locale.nix
      ../../system/base/screen_shot.nix
      ../../system/base/pipewire.nix
      ../../system/base/kakoune.nix
      ../../system/base/foot/foot.nix
      #../../system/base/terminator.nix


      # ---- hostname ----
      ../../system/base/hostnames/Home-Desktop.nix

      # ---- Shell ----
      # Changing this changes the shell :exploding_head:
      ../../system/base/shells/zsh.nix

      # ---- Users ----
      ../../system/base/users/work_user.nix

      # ---- hardware ----
      # power.nix is Laptop only on purpose: it is TLP with battery charge
      # thresholds, AC/BAT governors and Intel GPU frequencies, none of which
      # apply to a desktop on mains with an AMD CPU and an nvidia GPU.
      #../../system/hardware/power.nix
      ../../system/hardware/systemd.nix
      ../../system/hardware/opengl.nix
      ../../system/hardware/time_syncd.nix
      #../../system/hardware/roccat.nix
      # The AX200 card in this box brings bluetooth (hci0) just like the
      # Laptop's, so blueman from StartPrograms.conf has something to talk to
      ../../system/hardware/bluetooth.nix


      # ---- App ----
      ../../system/app/discord.nix
      ../../system/app/thunar.nix
      ../../system/app/dolphin.nix
      ../../system/app/libreOffice.nix
      ../../system/app/browser/firefox.nix
      ../../system/app/spotify.nix
      ../../system/app/FreeCAD.nix
      #../../system/app/virt-manager.nix
      #../../system/app/VirtualBox.nix
      #../../system/app/Docker.nix
      ../../system/app/Qemu.nix

      # ---- games ----
      ../../system/games/steam.nix
      ../../system/games/prismlauncher.nix
      ../../system/games/tailscale.nix
      ../../system/games/gamemode.nix
      # Extra on this host: ydotool needs the uinput group added below
      ../../system/games/ydotool.nix

      # ---- Security ----
      ../../system/security/automount.nix
      ../../system/security/firewall.nix
      ../../system/security/openvpn.nix
      ../../system/security/sshd.nix


      # proxy
      #../../system/security/mitmproxy_cert.nix
     ];




  environment.systemPackages = with pkgs; [
     # system related
     wget
     networkmanagerapplet
     openssl
     pciutils
     net-tools

     openconnect
     proton-vpn
     #xdg-desktop-portal-gnome

     # Custom cursor
     inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default

     #inputs.bluetui.packages.${pkgs.system}.default

     # Zen browser
     # ($mainMod, F in the shared Keybinds.conf expects this)
     inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

     # Extras this host already carried, kept on top of the Laptop's list
     feh
     gh
     git
     btop
     claude-code
  ];

  # fastfetch greeting on every new interactive shell
  programs.zsh.interactiveShellInit = ''
    fastfetch
  '';

  # Allow unfree software
  nixpkgs.config.allowUnfree = true;

  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Define the primary group for the user
  users.groups.nansus = {};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nansus = {
     isNormalUser = true;
     group = "nansus";
     description = "NanSuS-Desktop";
     extraGroups = [
	"wheel" # Sudo for nansus
	"networkmanager" # ability to change internet connections
	"video" # change display settings
	"vboxusers" # ability to use virtual machines
	"libvirtd" # -"-
	"lp"
	"input"
	"audio"
	"uinput" # for ydotool, see the games import above
   ];
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
