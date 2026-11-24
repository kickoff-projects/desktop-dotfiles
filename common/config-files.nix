{ lib }:

# This turns every regular file under a directory into one xdg.configFile
# entry. Each key is the path of the file relative to that directory. Example:
# ./.config/waybar/style.css becomes the xdg.configFile key
# "waybar/style.css". Nix links it from the store to
# ~/.config/waybar/style.css.
#
# Each file gets its own symlink. This file does not link whole directories.
# Some applications write runtime state next to their config, such as the
# btop log. Those applications need a normal writable directory. Keys per
# file also let a host layer or user layer replace a shared file of the same
# name. See common/home.nix.
#
# A missing layer gives {}. Example: a user with no .config files.
dir:
if !(builtins.pathExists dir) then {} else
lib.listToAttrs (map
  (path: lib.nameValuePair
    (lib.removePrefix "${toString dir}/" (toString path))
    { source = path; })
  (lib.filesystem.listFilesRecursive dir))
