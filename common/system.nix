{ config, pkgs, lib, inputs, ... }:

# This file holds the NixOS modules and settings that every machine takes.
# The configuration.nix file of each host then adds only its hardware, its
# locale, its window manager and its own differences. Read the comments in
# each host file for those differences.
#
# This file does not import these modules, although some hosts need them:
#  - base/hyprland.nix and base/screen_shot.nix: the server runs sway, which
#    has no hyprland, no hyprshot and no hyprpicker.
#  - hardware/bluetooth.nix, games/steam.nix and games/gamemode.nix: the
#    leisure desktop only.
#  - security/sshd.nix: each host imports this module as a commented line.
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
    ../system/base/git.nix

    ../system/hardware/systemd.nix
    ../system/hardware/opengl.nix
    ../system/hardware/time_syncd.nix

    ../system/app/thunar.nix
    ../system/app/browser/firefox.nix

    ../system/security/automount.nix
    ../system/security/firewall.nix
    ../system/security/openvpn.nix
    ../system/security/tailscale.nix
    ../system/security/proton-VPN.nix
  ];

  environment.systemPackages = with pkgs; [
     wget
     networkmanagerapplet
     openssl
     pciutils

     # Custom cursor, used whichever account is logged in
     inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
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
	"lp"
	"input"
	"audio"
   ];
  };
}
