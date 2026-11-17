{ config, lib, pkgs, inputs, hostDir, expectedHostName, ... }:

# Home-manager settings shared by every account. flake.nix's homeFor helper
# combines this with users/<name>/home.nix (the account's own packages) and
# sets the username/homeDirectory.
let
  configFilesOf = import ./config-files.nix { inherit lib; };
  claudeFilesOf = import ./claude-files.nix { inherit lib; };
  palettes = import ./palettes.nix;
  renderKak = import ./lib/render-kak.nix;
  renderFootColors = import ./lib/render-foot-colors.nix;
in
{
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # hosts/Home-Desktop and hosts/Home-Laptop share the same usernames, so
  # running e.g. "home-manager switch --flake .#nansus@Home-Laptop" on the
  # desktop would otherwise silently deploy the laptop's waybar/monitor
  # config onto this machine. The real /etc/hostname can only be read at
  # activation time, not at eval time (that would need --impure), so this
  # is a plain activation script, hooked before writeBoundary - the point
  # up to which nothing has been changed yet - rather than an assertion.
  home.activation.checkHostName =
    lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      actualHostName=$(cat /etc/hostname 2>/dev/null || true)
      if [ "$actualHostName" != "${expectedHostName}" ]; then
        echo "This home-manager configuration is for \"${expectedHostName}\", but this machine's /etc/hostname is \"$actualHostName\". Switch to the matching \"<user>@<host>\" flake target for this machine instead." >&2
        exit 1
      fi
    '';

  # Packages the shared Keybinds.conf shells out to, so every account that
  # inherits those binds can actually run them: playerctl for the four
  # XF86Audio binds, zen for $mainMod+F and CTRL+SHIFT+F.
  home.packages = [
    pkgs.playerctl
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    pkgs.git
    pkgs.gh
    pkgs.librespeed-cli
    pkgs.btop
    pkgs.libreoffice-qt

    # qt.style.package below only covers the Qt5 plugin; Qt6 apps need the
    # Qt6 build of the same style or they fall back to light Fusion.
    pkgs.adwaita-qt6
  ];

  # Dark GTK/Qt so the apps that draw their own chrome (file dialogs,
  # libreoffice, thunar/dolphin, firefox) stay dark instead of flashing a
  # light-themed dialog over a dark desktop.
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

  # btop rewrites its own config when it exits, so it cannot live in the
  # read only /nix/store copy of .config. Seed it from btop.conf.in on first
  # run, and reseed if the existing btop.conf names a color_theme path that
  # no longer exists - a scheme this refactor renamed or deleted would
  # otherwise leave btop silently on its built-in default forever.
  home.activation.seedBtopConfig =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      btopConfIn="$HOME/.config/btop/btop.conf.in"
      btopConf="$HOME/.config/btop/btop.conf"
      if [ -f "$btopConfIn" ]; then
        existingTheme=$(sed -n 's/^color_theme[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' "$btopConf" 2>/dev/null)
        expandedTheme="''${existingTheme/#\~/$HOME}"
        if [ ! -f "$btopConf" ] || { [ -n "$existingTheme" ] && [ ! -f "$expandedTheme" ]; }; then
          run install -m644 "$btopConfIn" "$btopConf"
        fi
      fi
    '';

  # Everything under common/.config is symlinked into every account's
  # ~/.config; hostDir/.config overrides it per-machine (waybar's
  # config.jsonc, monitor lines, ...), and users/<name>/.config overrides
  # both (palette files). Same-path wins right-to-left.
  xdg.configFile =
       configFilesOf ./.config
    // configFilesOf (hostDir + "/.config")
    // configFilesOf (../users + "/${config.home.username}/.config")
    // {
      # Generated from common/palettes.nix rather than a plain file, so a
      # new theme is sixteen-ish hex values instead of a hand-copied file.
      # mkDefault so a host/user layer (nansus-work's kak, hosts/Server's
      # theme.nix) can override with mkForce.
      "kak/colors/account.kak".text = lib.mkDefault (renderKak { p = palettes.rainbow.kak; });
      "foot/colors.ini".text = lib.mkDefault (renderFootColors { p = palettes.rainbow.foot; });

      # home-manager's qt module with platformTheme "qtct" installs qt5ct/qt6ct
      # and exports the env vars, but writes no config, so Qt apps would still
      # start on qt6ct's light default. These two files are what actually makes
      # them dark. Declared read-only from the store rather than seeded like
      # btop.conf: the only writer is the qt6ct settings GUI, and the point of
      # putting the style here is that it is not hand-edited.
      "qt5ct/qt5ct.conf".text = ''
        [Appearance]
        style=adwaita-dark
        icon_theme=Papirus-Dark
        standard_dialogs=default
        custom_palette=false
      '';
      "qt6ct/qt6ct.conf".text = ''
        [Appearance]
        style=adwaita-dark
        icon_theme=Papirus-Dark
        standard_dialogs=default
        custom_palette=false
      '';
    };

  # Same idea one directory up, for claude-code: common/.claude is symlinked
  # into every account's ~/.claude, and users/<name>/.claude overrides it.
  # Both CLAUDE.md and the neon theme live in the common layer - every
  # account gets them, and choosing the theme is a settings.json line rather
  # than a layer. No host layer either: nothing here is machine-specific.
  #
  # ~/.claude/settings.json is deliberately absent from both layers: claude
  # writes it itself, so it stays an ordinary file. Selecting a theme shipped
  # here is therefore one manual line per machine, e.g.
  #   "theme": "custom:neon-theme"
  home.file =
       claudeFilesOf ./.claude
    // claudeFilesOf (../users + "/${config.home.username}/.claude");

  # disable ssh, home-manager doesn't manage its config
  programs.ssh.enable = false;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;
}
