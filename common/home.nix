{ config, lib, pkgs, hostDir, expectedHostName, ... }:

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

  # hosts/Home-Desktop and hosts/Home-Laptop share the same usernames, so
  # running e.g. "home-manager switch --flake .#nansus@Home-Laptop" on the
  # desktop would deploy the laptop's waybar/monitor config onto this machine
  # without any warning. The real /etc/hostname can only be read at
  # activation time (reading it at eval time would need --impure), so this
  # is a plain activation script and not an assertion. It is hooked before
  # writeBoundary, the point up to which nothing has been changed yet.
  home.activation.checkHostName =
    lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      actualHostName=$(cat /etc/hostname 2>/dev/null || true)
      if [ "$actualHostName" != "${expectedHostName}" ]; then
        echo "This home-manager configuration is for \"${expectedHostName}\", but this machine's /etc/hostname is \"$actualHostName\". Switch to the matching \"<user>@<host>\" flake target for this machine instead." >&2
        exit 1
      fi
    '';

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
  # no longer exists. Without the reseed, a scheme this refactor renamed or
  # deleted would leave btop on its built-in default for good, with no error.
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
      # Generated from common/palettes.nix, so a new theme is sixteen-ish hex
      # values and no file has to be copied by hand.
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
