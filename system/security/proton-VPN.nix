{ pkgs, ... }:

{
  environment.systemPackages = [
      pkgs.proton-vpn-cli
      #pkgs.proton-vpn
  ];

  # proton-vpn-cli stores its session in the Secret Service keyring.
  # GNOME Keyring provides it and unlocks at GDM login (system/base/gnome_lockscreen.nix).
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;
}
