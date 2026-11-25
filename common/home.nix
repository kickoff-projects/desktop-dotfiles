{ config, lib, pkgs, inputs, hostDir, expectedHostName, ... }:

# Home-manager settings that every account shares. The homeFor helper in
# flake.nix joins this file with users/<name>/home.nix, which holds the
# packages of the account. The helper also sets username and homeDirectory.
let
  configFilesOf = import ./config-files.nix { inherit lib; };
  claudeFilesOf = import ./claude-files.nix { inherit lib; };
  palettes = import ./palettes.nix;
  renderKak = import ./lib/render-kak.nix;
  renderFootColors = import ./lib/render-foot-colors.nix;
  renderRofi = import ./lib/render-rofi.nix;
  renderKdeglobals = import ./lib/render-kdeglobals.nix;

  # Nix writes this text to both qt5ct.conf and qt6ct.conf below. Qt5
  # applications and Qt6 applications therefore always get the same style.
  qtctConf = ''
    [Appearance]
    style=adwaita-dark
    icon_theme=Papirus-Dark
    standard_dialogs=default
    custom_palette=false
  '';
in
{
  # One file per application, shared by every account. See system/app/.
  # An application that must stay with one account comes from the home.nix
  # file of that account. prismlauncher is the only one today.
  imports = [
    ../system/app/dolphin.nix
    ../system/app/discord.nix
    ../system/app/spotify.nix
    ../system/app/freecad.nix
    ../system/app/qemu.nix
  ];

  home.stateVersion = "24.11"; # Please read the comment before changing.

  # hosts/desktop and hosts/laptop use the same usernames. This test stops
  # a command such as "home-manager switch --flake .#nansus@laptop" on the
  # desktop. Without the test, that command writes the waybar config and
  # the monitor config of the laptop onto this machine. It prints no
  # warning.
  #
  # Nix can read the real /etc/hostname at activation time only. A read at
  # evaluation time needs --impure. This test is therefore an activation
  # script, and not an assertion. It runs before writeBoundary, which is
  # the point up to which nothing has changed.
  home.activation.checkHostName =
    lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      actualHostName=$(cat /etc/hostname 2>/dev/null || true)
      if [ "$actualHostName" != "${expectedHostName}" ]; then
        echo "This home-manager configuration is for \"${expectedHostName}\", but this machine's /etc/hostname is \"$actualHostName\". Switch to the matching \"<user>@<host>\" flake target for this machine instead." >&2
        exit 1
      fi
    '';

  # The shared Keybinds.conf runs these packages. Every account that takes
  # those binds therefore needs them. playerctl serves the 4 XF86Audio
  # binds. zen serves $mainMod+F and CTRL+SHIFT+F.
  home.packages = [
    pkgs.playerctl
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    pkgs.gh
    pkgs.librespeed-cli
    # cudaSupport adds only the autoAddDriverRunpath hook of nixpkgs. It
    # adds no CUDA package. The hook puts /run/opengl-driver/lib on the
    # runpath of btop. btop can then open libnvidia-ml.so.1 and fill the
    # gpu0 box.
    (pkgs.btop.override { cudaSupport = true; })
    pkgs.libreoffice-qt

    # The option qt.style.package below covers the Qt5 plugin only. Qt6
    # applications need the Qt6 build of the same style. Without it, they
    # use the light Fusion style.
    pkgs.adwaita-qt6
  ];

  # A dark GTK theme and Qt theme. Some applications draw their own window
  # parts: file dialogs, libreoffice, thunar, dolphin and firefox. These
  # options keep them dark. Without the options, they show a light dialog
  # over a dark desktop.
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
    # Some applications ask the toolkit for a preference, and do not read
    # the theme name. Most GTK3 and GTK4 applications do this. They need
    # this setting too.
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    # GTK4 applications and libadwaita applications ignore a theme name.
    # They read the dark preference from the setting above and from the
    # portal, which is dconf below. There is therefore no theme for
    # gtk4.theme.
    # This line sets the value, because home-manager prints a warning about
    # a new default in 26.05.
    gtk4.theme = null;
  };

  # The same preference over DBus. Some programs ask the xdg settings
  # portal instead: the "follow system theme" option of firefox, and
  # electron applications.
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  # platformTheme is "qtct", and not "gtk3". The file ENV-Variables.conf of
  # each host already exports QT_QPA_PLATFORMTHEME=qt6ct for every account.
  # An env line in hyprland wins over the line that home-manager sets.
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # git identity, shared by every home configuration
  programs.git = {
    enable = true;
    settings.user.name = "ViliLuosujarvi";
    settings.user.email = "vili.luosujarvi@edu.lapinamk.fi";

    # github https auth via the gh cli token
    settings.credential."https://github.com".helper =
      "!gh auth git-credential";
  };

  # btop writes its own config file at exit, so that file cannot live in
  # the read-only /nix/store copy of .config. This script copies
  # btop.conf.in on the first run. It copies the file again when the
  # current btop.conf names a color_theme that does not exist. Without the
  # second copy, btop keeps its built-in default theme and prints nothing.
  # A bare theme name is a name that btop finds in ~/.config/btop/themes,
  # so this script looks there.
  # shortcut: only the theme triggers a reseed, upgrade if btop.conf.in gains
  # settings that must reach accounts which already have a btop.conf.
  home.activation.seedBtopConfig =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      btopConfIn="$HOME/.config/btop/btop.conf.in"
      btopConf="$HOME/.config/btop/btop.conf"
      if [ -f "$btopConfIn" ]; then
        existingTheme=$(sed -n 's/^color_theme[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' "$btopConf" 2>/dev/null)
        expandedTheme="''${existingTheme/#\~/$HOME}"
        case "$expandedTheme" in
          /*) ;;
          Default|TTY) expandedTheme="$btopConfIn" ;;
          *) expandedTheme="$HOME/.config/btop/themes/$expandedTheme" ;;
        esac
        if [ ! -f "$btopConf" ] || { [ -n "$existingTheme" ] && [ ! -f "$expandedTheme" ]; }; then
          run install -m644 "$btopConfIn" "$btopConf"
        fi
      fi
    '';

  # The generated files below come first. The three file layers follow:
  #  - common/.config: Nix links every file into the ~/.config directory of
  #    every account.
  #  - hostDir/.config: this layer replaces files per machine, such as the
  #    waybar config.jsonc and the monitor lines.
  #  - users/<name>/.config: this layer replaces files of both layers above,
  #    such as the palette files.
  # For the same path, the layer on the right wins. A real file in any layer
  # also replaces a generated entry of the same name.
  xdg.configFile =
    {
      # Nix generates this file from common/palettes.nix. It is not a plain
      # file. A new theme is therefore a set of hex values, and not a copy
      # of a file.
      # This line uses mkDefault, so a host layer or user layer can replace
      # it with mkForce. The kak file of nansus-work does this.
      "kak/colors/account.kak".text = lib.mkDefault (renderKak { p = palettes.rainbow.kak; });
      "foot/colors.ini".text = lib.mkDefault (renderFootColors { p = palettes.rainbow.foot; });

      # The rofi theme and the colour scheme of dolphin, both with a black
      # background.
      # A host layer or user layer that keeps its own real rofi/account.rasi
      # replaces this generated entry, because the three configFilesOf layers
      # below come after it. hosts/server and users/nansus-work both do that.
      "rofi/account.rasi".text = lib.mkDefault (renderRofi { p = palettes.rainbow.rofi; });
      # The KDE platform theme builds the whole Qt palette of dolphin from
      # the [Colors:*] groups of this file. system/app/dolphin.nix starts
      # dolphin with QT_QPA_PLATFORMTHEME=kde so that it loads.
      "kdeglobals".text =
        lib.mkDefault (renderKdeglobals { p = palettes.rainbow.dolphin; });

      # The qt module of home-manager with platformTheme "qtct" installs
      # qt5ct and qt6ct, and it exports the env vars. It writes no config
      # file, so Qt applications start on the light default of qt6ct.
      # These two files make those applications dark. Both files hold the
      # same qtctConf text, so Qt5 and Qt6 applications keep the same style.
      # These files are read-only from the store. They are not copies like
      # btop.conf, because the only writer is the settings GUI of qt6ct.
      # The style lives here so that nobody edits it by hand.
      "qt5ct/qt5ct.conf".text = qtctConf;
      "qt6ct/qt6ct.conf".text = qtctConf;
    }
    // configFilesOf ./.config
    // configFilesOf (hostDir + "/.config")
    // configFilesOf (../users + "/${config.home.username}/.config");

  # The same method one directory up, for claude-code. Nix links
  # common/.claude into the ~/.claude directory of every account, and
  # users/<name>/.claude replaces files in it.
  # The common layer holds CLAUDE.md and the neon theme, so every account
  # gets them. A settings.json line picks the theme, and not a layer.
  # There is no host layer, because nothing here belongs to one machine.
  #
  # Neither layer holds ~/.claude/settings.json. Claude writes that file
  # itself, so it stays an ordinary file. Each machine therefore needs one
  # manual line to pick a theme from this layer. Example:
  #   "theme": "custom:neon-theme"
  home.file =
       claudeFilesOf ./.claude
    // claudeFilesOf (../users + "/${config.home.username}/.claude");

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;
}
