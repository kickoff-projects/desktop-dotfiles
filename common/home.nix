{ config, lib, pkgs, hostDir, ... }:

# Home-manager settings shared by every account. flake.nix's homeFor helper
# combines this with users/<name>/home.nix (the account's own packages) and
# sets the username/homeDirectory.
let
  configFilesOf = import ./config-files.nix { inherit lib; };
  palettes = import ./palettes.nix;
  renderKak = import ./lib/render-kak.nix;
  renderFootColors = import ./lib/render-foot-colors.nix;
in
{
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The four XF86Audio media binds in the shared Keybinds.conf call
  # playerctl; it was installed nowhere before this refactor.
  home.packages = [ pkgs.playerctl ];

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
    };

  # disable ssh, home-manager doesn't manage its config
  programs.ssh.enable = false;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;
}
