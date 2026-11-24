{ lib }:

# This is the home directory twin of config-files.nix. It turns every regular
# file under a layer's .claude directory into one home.file entry. Each key is
# ".claude/" plus the path of the file relative to that directory. Example:
# users/<name>/.claude/themes/neon-theme.json becomes the home.file key
# ".claude/themes/neon-theme.json". Nix links it from the store to
# ~/.claude/themes/neon-theme.json.
#
# This uses home.file, not xdg.configFile, because claude-code reads
# ~/.claude. That path is outside XDG, so config-files.nix cannot reach it.
# The keys are per file for the same reason as in config-files.nix.
# claude-code also writes its own state into ~/.claude. That state is
# settings.json, history.jsonl, projects/ and sessions/. It needs a normal
# writable directory with one symlink per file.
#
# This file does not manage settings.json. Claude writes settings.json on
# every /config change, /model change and theme change. A read-only store
# symlink makes those writes fail without a message. See the README. Its
# "theme" line is setup for one machine only.
#
# A missing layer gives {}. This is the same test as in config-files.nix.
dir:
if !(builtins.pathExists dir) then {} else
lib.listToAttrs (map
  (path: lib.nameValuePair
    ".claude/${lib.removePrefix "${toString dir}/" (toString path)}"
    { source = path; })
  (lib.filesystem.listFilesRecursive dir))
