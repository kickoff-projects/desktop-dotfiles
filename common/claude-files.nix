{ lib }:

# The ~/-rooted twin of config-files.nix: turn every regular file under a
# layer's .claude directory into a home.file entry, keyed by ".claude/" plus
# its path relative to that directory - so users/<name>/.claude/themes/
# neon-theme.json becomes the home.file key ".claude/themes/neon-theme.json",
# symlinked from the nix store at ~/.claude/themes/neon-theme.json.
#
# home.file rather than xdg.configFile because claude-code reads ~/.claude,
# which is outside XDG and so unreachable by config-files.nix. Per-file keys
# for the same reason as there: ~/.claude also holds state claude-code writes
# itself (settings.json, history.jsonl, projects/, sessions/), and that only
# keeps working if the directory stays a normal writable one with individual
# symlinks in it.
#
# Deliberately not managed here: settings.json. Claude writes it on every
# /config, /model or theme change, and a read-only store symlink would make
# those silently fail - see README. Its "theme" line is one-per-machine setup.
#
# A missing layer yields {}, same guard as config-files.nix.
dir:
if !(builtins.pathExists dir) then {} else
lib.listToAttrs (map
  (path: lib.nameValuePair
    ".claude/${lib.removePrefix "${toString dir}/" (toString path)}"
    { source = path; })
  (lib.filesystem.listFilesRecursive dir))
