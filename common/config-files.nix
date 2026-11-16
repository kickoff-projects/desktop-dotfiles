{ lib }:

# Turn every regular file under a directory into an xdg.configFile entry,
# keyed by its path relative to that directory. ./.config/waybar/style.css
# becomes the xdg.configFile key "waybar/style.css", symlinked from the nix
# store at ~/.config/waybar/style.css.
#
# Each file gets its own symlink, and directories are never symlinked whole,
# so that apps which write runtime state next to their config (btop's log,
# etc.) still get a normal, writable directory to do that in.
# Per-file keys are also what lets a host or user layer's own file replace
# the shared one of the same name (see common/home.nix).
#
# A missing layer (e.g. a user with no .config overrides at all) yields {}.
# Ported from /srv/nixos-vm-config/common/config-files.nix, with that guard
# added because this repo has three layers and that one has two.
dir:
if !(builtins.pathExists dir) then {} else
lib.listToAttrs (map
  (path: lib.nameValuePair
    (lib.removePrefix "${toString dir}/" (toString path))
    { source = path; })
  (lib.filesystem.listFilesRecursive dir))
