{ lib, pkgs, ... }:

# The work account: common/home.nix plus these. Neon rainbow kakoune is the only
# override - see common/palettes.nix and common/home.nix's mkDefault for
# the mechanism. Everything else inherits the rainbow default.
#
# Visuals: this account runs a black/rainbow variant of the shared theme -
# every surface goes pure black and the color is carried by text, borders
# and graphs instead of by backgrounds. The per-surface files live in
# ./.config (waybar, hypr, rofi, btop, fastfetch, zsh prompt), which the
# config-files.nix layering puts on top of common/ and hosts/<host>/.
# Deliberately left alone: foot's sixteen ANSI colors (only its background
# is darkened) and the wallpaper.
let
  palettes = import ../../common/palettes.nix;
  renderKak = import ../../common/lib/render-kak.nix;
  renderFootColors = import ../../common/lib/render-foot-colors.nix;
in
{
  home.packages = with pkgs; [
    git
    gh
    ripgrep

    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt

    uv
    python3

    libreoffice-qt
    openconnect
    proton-vpn

    claude-code

    # qt.style.package below only covers the Qt5 plugin; Qt6 apps need the
    # Qt6 build of the same style or they fall back to light Fusion.
    adwaita-qt6
  ];

  # Dark GTK/Qt so the apps that draw their own chrome (file dialogs,
  # libreoffice, thunar/dolphin, firefox) stop flashing white against the
  # black desktop. Nothing in the repo configured this before.
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    # Apps that ask the toolkit for a preference rather than reading the
    # theme name (most GTK3/GTK4 apps do) need this as well.
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    # GTK4/libadwaita apps ignore a theme *name* - they take the dark
    # preference from the setting above and from the portal (dconf below),
    # so there is nothing to point gtk4.theme at. Set explicitly because
    # home-manager warns about the default changing in 26.05 otherwise.
    gtk4.theme = null;
  };

  # Same preference over dbus, for anything that asks the xdg settings
  # portal instead (firefox's "follow system theme", electron apps).
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  # platformTheme "qtct" rather than "gtk3" on purpose: the hosts' hypr
  # ENV-Variables.conf already exports QT_QPA_PLATFORMTHEME=qt6ct for every
  # account, and a hyprland env line wins over the one home-manager sets.
  # Writing qt5ct/qt6ct's own config is the only way to be heard here
  # without editing a host file that nansus shares.
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
  # home-manager's qt module with platformTheme "qtct" installs qt5ct/qt6ct
  # and exports the env vars, but writes no config, so Qt apps would still
  # start on qt6ct's light default. These two files are what actually makes
  # them dark. Declared read-only from the store rather than seeded like
  # btop.conf: the only writer is the qt6ct settings GUI, and the point of
  # putting the style here is that it is not hand-edited.
  xdg.configFile."qt5ct/qt5ct.conf".text = ''
    [Appearance]
    style=adwaita-dark
    icon_theme=Papirus-Dark
    standard_dialogs=default
    custom_palette=false
  '';
  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    style=adwaita-dark
    icon_theme=Papirus-Dark
    standard_dialogs=default
    custom_palette=false
  '';

  xdg.configFile."kak/colors/account.kak".text =
    lib.mkForce (renderKak { p = palettes.neon_rainbow.kak; } + ''
      # Account override, appended after the rendered template. Kakoune's
      # set-face is last-one-wins, so these seven lines replace the ones
      # render-kak.nix emitted without the shared template (and so the
      # rainbow and red themes) having to change.
      #
      # Cursor is magenta and the selection is yellow, the reverse of the
      # template's baseAD01/baseAD02 pairing. Not done by swapping palette
      # slots because the template couples PrimaryCursorEol's background
      # and LineNumberCursor to base0A, which this theme spends on types
      # and docstrings - swapping the values there would have turned every
      # type magenta to recolor the end-of-line cursor.
      set-face global PrimaryCursor "%opt{base00},%opt{baseAD02}+b"
      set-face global PrimaryCursorEol "%opt{base00},%opt{baseAD02}"
      set-face global LineNumberCursor "%opt{baseAD02},%opt{base00}+b"
      # Secondary (multi-)cursors take the neighbouring violet, so they
      # read as cursors without being mistaken for the primary one.
      set-face global SecondaryCursor "%opt{base00},%opt{base0E}"
      set-face global SecondaryCursorEol "%opt{base00},%opt{base0E}"
      # Primary selection stays foreground-only, as the template had it -
      # only the hue changes. The secondary one needs a background to be
      # told apart, and base02 is the dark one that leaves the yellow legible.
      set-face global PrimarySelection "%opt{base0A}"
      set-face global SecondarySelection "%opt{base0A},%opt{base02}"
    '');

  # Foot keeps the rainbow sixteen verbatim - only the background is pulled
  # from the rainbow theme's near-black 0a0a20 to true black.
  xdg.configFile."foot/colors.ini".text =
    lib.mkForce (renderFootColors {
      p = palettes.rainbow.foot // { background = "000000"; };
    });
}
