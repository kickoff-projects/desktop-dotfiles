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

  # The packages in the live environment. The red theme below belongs to
  # foot. This image has no hyprland and no waybar, so it needs no kitty.
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

  # A red theme for foot and kakoune. Nix generates both from
  # common/palettes.nix, with the same method as common/home.nix.
  # This image has no home-manager, so environment.etc.text takes the place
  # of mkForce.
  # The kak theme comes from render-kak-legacy.nix. palettes.red matches
  # that body, and it declares none of the values baseAD06 to baseAD15 that
  # the live render-kak.nix needs.
  # kakrc is the shared file, like the file of every other account.
  environment.etc."xdg/foot/foot.ini".source = ./.config/foot/foot.ini;
  environment.etc."xdg/foot/colors.ini".text = renderFootColors { p = palettes.red.foot; };
  environment.etc."kak/kakrc".source = ../../common/.config/kak/kakrc;
  environment.etc."kak/colors/account.kak".text =
    renderKak { p = palettes.red.kak; } + ''
      # The shared kakrc uses these faces in modelinefmt and in its nix
      # highlighter hook. Nix adds them after the frozen body of
      # render-kak-legacy.nix.
      # This palette is red only, so base0A is its light red accent, and not
      # a violet. base09 and base08 are its deep red and its orange red.
      # They take the place of baseAD06 and baseAD10 in the template.
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
