#!/usr/bin/env bash
# Toggles Hyprland's eyecandy off for windowed and borderless games. A
# fullscreen game is already "solitary" and skips compositing entirely, so this
# only matters for games that keep a windowed surface.
#
# Driven by SUPER+G (Keybinds.conf), which calls it with no argument:
#   on | off | toggle   (default: toggle)

set -u

# gamemoded runs as a user service and may not have the session's instance
# signature in its environment; fall back to the only socket in the runtime dir.
if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  HYPRLAND_INSTANCE_SIGNATURE=$(
    ls -1 "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr" 2>/dev/null | head -1
  )
  export HYPRLAND_INSTANCE_SIGNATURE
fi
[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] || exit 0

state="${XDG_RUNTIME_DIR:-/tmp}/hypr-gamemode"

case "${1:-toggle}" in
  on)  want=on ;;
  off) want=off ;;
  *)   if [ -e "$state" ]; then want=off; else want=on; fi ;;
esac

if [ "$want" = on ]; then
  hyprctl --batch "\
    keyword animations:enabled 0;\
    keyword decoration:blur:enabled 0;\
    keyword decoration:shadow:enabled 0;\
    keyword decoration:rounding 0;\
    keyword general:gaps_in 0;\
    keyword general:gaps_out 0;\
    keyword general:border_size 1"
  : > "$state"
else
  rm -f "$state"
  # Restores every keyword above from the config files. Execs.conf uses "exec="
  # rather than "exec-once=", so smooth_RainbowBorder.sh re-runs on reload and
  # restores the runtime col.active_border too.
  hyprctl reload
fi
