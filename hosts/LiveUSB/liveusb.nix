{ lib, hostname, pkgs, ... }:

{
  imports = [ ];

  # ISO / USB image settings
  isoImage = {
    volumeID = lib.mkForce "nixos-live";
    isoName = lib.mkForce "nixos-live.iso";
    makeEfiBootable = true;
    makeUsbBootable = true;
    squashfsCompression = "lz4";
  };

  # Packages in live environment
  environment.systemPackages = with pkgs; [
    ripgrep
    fd
    tree
    unzip
    htop

    parted
    e2fsprogs
    dosfstools

    curl
    inetutils
    nmap

    kakoune
    kitty

    fastfetch
];

  # fastfetch config for the live environment; /etc/xdg is on fastfetch's search path
  environment.etc."xdg/fastfetch/config.jsonc".source = ./.config/fastfetch/config.jsonc;
  environment.etc."xdg/fastfetch/moved_chesire_cat_with_text".source = ./.config/fastfetch/moved_chesire_cat_with_text;

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

 services.gvfs.enable = false;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.root.password = "";

  system.stateVersion = "24.05";
}
