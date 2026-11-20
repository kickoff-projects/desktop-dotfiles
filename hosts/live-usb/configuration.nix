{ lib, pkgs, ... }:

let
  palettes = import ../../common/palettes.nix;
  renderKak = import ../../common/lib/render-kak-legacy.nix;
  renderFootColors = import ../../common/lib/render-foot-colors.nix;
in
{
  imports = [ ];

  # ISO / USB image settings
  isoImage = {
    volumeID = lib.mkForce "nixos-live";
    makeEfiBootable = true;
    makeUsbBootable = true;
    squashfsCompression = "lz4";
  };
  image.fileName = lib.mkForce "nixos-live.iso";

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
  environment.etc."xdg/fastfetch/moved_chesire_cat_with_text".source = ../../common/.config/fastfetch/moved_chesire_cat_with_text;

  # Red foot + kakoune, generated from common/palettes.nix, same mechanism
  # as common/home.nix. No home-manager here, so environment.etc.text
  # stands in for mkForce. The kak theme renders through
  # render-kak-legacy.nix - palettes.red was authored against that body and
  # declares none of the baseAD06-baseAD15 the live render-kak.nix now
  # requires. kakrc is the shared one, same as every other account.
  environment.etc."xdg/foot/foot.ini".source = ./.config/foot/foot.ini;
  environment.etc."xdg/foot/colors.ini".text = renderFootColors { p = palettes.red.foot; };
  environment.etc."kak/kakrc".source = ../../common/.config/kak/kakrc;
  environment.etc."kak/colors/account.kak".text =
    renderKak { p = palettes.red.kak; } + ''
      # Faces the shared kakrc references in modelinefmt and in its nix
      # highlighter hook, added after render-kak-legacy.nix's frozen body.
      # This palette is monochrome red, so base0A is its light-red accent
      # rather than a violet; base09 and base08 are its deep red and
      # orange-red, standing in for the template's baseAD06 and baseAD10.
      set-face global kak_mode_info "%opt{base0A}+i"
      set-face global violet "%opt{base0A}"
      set-face global row_color "%opt{base09}"
      set-face global nix_interp "%opt{base08}"
    '';
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
