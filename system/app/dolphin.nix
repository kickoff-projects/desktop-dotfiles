{ pkgs, ... }:

let
  # The KDE platform theme and the Breeze style. Together they build the Qt
  # palette of dolphin from ~/.config/kdeglobals, which
  # common/lib/render-kdeglobals.nix writes from common/palettes.nix.
  platformTheme = pkgs.kdePackages.plasma-integration;
  style = pkgs.kdePackages.breeze;

  # The KDE file manager with that pair bound to it.
  #
  # QT_QPA_PLATFORMTHEME must be the lower case "kde". That is the one key
  # that kdeplatformtheme.json declares, and the plugin loads under no other
  # spelling. The value reaches dolphin alone, so every other Qt application
  # keeps the qt6ct platform theme of ~/.config/qt6ct/qt6ct.conf.
  #
  # QT_STYLE_OVERRIDE reaches QApplicationPrivate::init before the style hint
  # of a platform theme, so breeze wins for dolphin.
  #
  # QT_PLUGIN_PATH carries both plugins. Qt searches no profile directory for
  # them, so without this prefix neither one loads.
  #
  # The desktop file of dolphin holds "Exec=dolphin %u", a bare name. A launch
  # from a file dialog or from xdg-open therefore also reaches this wrapper.
  dolphin = pkgs.symlinkJoin {
    name = "dolphin-kde";
    paths = [ pkgs.kdePackages.dolphin ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/dolphin \
        --set QT_QPA_PLATFORMTHEME kde \
        --set QT_STYLE_OVERRIDE breeze \
        --prefix QT_PLUGIN_PATH : ${platformTheme}/lib/qt-6/plugins \
        --prefix QT_PLUGIN_PATH : ${style}/lib/qt-6/plugins
    '';
  };
in
{
  # The KDE file manager, for every account. common/home.nix imports this
  # module. thunar is the other file manager, in system/app/thunar.nix.
  home.packages = [ dolphin ];
}
