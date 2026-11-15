{ lib, pkgs, ... }:

let
  palettes = import ../../common/palettes.nix;
  renderKak = import ../../common/lib/render-kak.nix;
  renderFootColors = import ../../common/lib/render-foot-colors.nix;
in
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

  # Packages in live environment. foot replaces kitty - red theme below is
  # foot's, and this image has no hyprland/waybar to need kitty either.
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
    foot

    fastfetch
];

  # fastfetch config for the live environment; /etc/xdg is on fastfetch's search path
  environment.etc."xdg/fastfetch/config.jsonc".source = ./.config/fastfetch/config.jsonc;
  environment.etc."xdg/fastfetch/moved_chesire_cat_with_text".source = ./.config/fastfetch/moved_chesire_cat_with_text;

  # Red foot + kakoune, same scheme as the Server - generated from
  # common/palettes.nix, same mechanism as hosts/Server/theme.nix. No
  # home-manager here, so environment.etc.text stands in for mkForce.
  environment.etc."xdg/foot/foot.ini".source = ./.config/foot/foot.ini;
  environment.etc."xdg/foot/colors.ini".text = renderFootColors { p = palettes.red.foot; };
  environment.etc."kak/kakrc".source = ./.config/kak/kakrc;
  environment.etc."kak/colors/account.kak".text = renderKak { p = palettes.red.kak; };
  environment.variables.KAKOUNE_CONFIG_DIR = "/etc/kak";

  networking = {
    hostName = "hassus";
    networkmanager.enable = true;
  };

 services.gvfs.enable = false;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.root.password = "";

  system.stateVersion = "24.11";
}
