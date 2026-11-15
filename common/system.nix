{ config, pkgs, lib, inputs, ... }:

# The NixOS modules and settings every machine takes, verified against
# Home-Laptop, Home-Desktop and Server's active imports (see AUDIT history
# and the refactor plan). Each host's own configuration.nix then adds only
# its hardware, locale, window manager and real deltas - see the comments
# there for what those are per host.
#
# Deliberately NOT here even though some hosts want it: base/hyprland.nix
# and base/screen_shot.nix (Server runs sway, which has neither hyprland nor
# hyprshot/hyprpicker), hardware/bluetooth.nix, games/steam.nix and
# games/gamemode.nix (leisure-desktop only), security/sshd.nix (kept as a
# file, imported commented-out per host - see AUDIT #19).
{
  imports = [
    ../system/base/boot.nix
    ../system/base/gnome_lockscreen.nix
    ../system/base/unfree_software.nix
    ../system/base/fonts.nix
    ../system/base/networking.nix
    ../system/base/pipewire.nix
    ../system/base/kakoune.nix
    ../system/base/foot/foot.nix
    ../system/base/shells/zsh.nix
    ../system/base/users/work_user.nix

    ../system/hardware/systemd.nix
    ../system/hardware/opengl.nix
    ../system/hardware/time_syncd.nix

    ../system/app/thunar.nix
    ../system/app/browser/firefox.nix

    ../system/security/automount.nix
    ../system/security/firewall.nix
    ../system/security/openvpn.nix
    ../system/security/tailscale.nix
  ];

  environment.systemPackages = with pkgs; [
     wget
     networkmanagerapplet
     openssl
     pciutils

     # Custom cursor, used whichever account is logged in
     inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
  ];

  # Allow unfree software
  nixpkgs.config.allowUnfree = true;

  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11"; # Did you read the comment?

  # Define the primary group for the user
  users.groups.nansus = {};

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.nansus = {
     isNormalUser = true;
     group = "nansus";
     description = "nansus";
     extraGroups = [
	"wheel" # Sudo for nansus
	"networkmanager" # ability to change internet connections
	"video" # change display settings
	"vboxusers" # ability to use virtual machines
	"libvirtd" # -"-
	"lp"
	"input"
	"audio"
   ];
  };
}
