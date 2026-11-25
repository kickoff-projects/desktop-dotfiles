#!/usr/bin/env bash
# Toggles Hyprland's eyecandy off for windowed and borderless games, and
# forces every enabled monitor's colour management preset to HDR. A
# fullscreen game is already "solitary" and skips compositing entirely, so the
# eyecandy part only matters for games that keep a windowed surface. The HDR
# part matters on hosts where Monitors.conf leaves cm at "auto" (HDR only for
# fullscreen HDR surfaces): this keybind forces it on regardless of surface.
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

  # Re-applies each enabled monitor's own mode, position, scale and SDR
  # brightness/saturation, with cm forced to hdr and bitdepth forced to 10.
  # sdr_min_luminance and sdr_max_luminance are monitorv2-only keys with no
  # equivalent on this keyword line, so they fall back to Hyprland's
  # defaults (0.2 and 80 nits) while gamemode stays on. hyprctl reload below
  # restores the tuned values, and the 8 bit default, from Monitors.conf on
  # exit.
  # shortcut: sdr_min/max_luminance go untuned while gamemode is on; upgrade
  # if that shows up as washed-out SDR content during HDR gaming sessions.
  hyprctl monitors | awk '
    /^Monitor / { if (name != "" && disabled == "false") print name, mode, pos, scale, sb, ss
                  name=$2; mode=""; pos=""; scale=""; sb=""; ss=""; disabled="false" }
    /^\t[0-9]+x[0-9]+@[0-9.]+ at [0-9]+x[0-9]+/ { mode=$1; pos=$3 }
    /^\tscale:/        { scale=$2 }
    /^\tsdrBrightness:/ { sb=$2 }
    /^\tsdrSaturation:/ { ss=$2 }
    /^\tdisabled:/      { disabled=$2 }
    END { if (name != "" && disabled == "false") print name, mode, pos, scale, sb, ss }
  ' | while read -r name mode pos scale sb ss; do
    hyprctl keyword monitor "$name,$mode,$pos,$scale,cm,hdr,bitdepth,10,sdrbrightness,$sb,sdrsaturation,$ss"
  done

  : > "$state"
else
  rm -f "$state"
  # Restores every keyword above from the config files. Execs.conf uses "exec="
  # rather than "exec-once=", so smooth_RainbowBorder.sh re-runs on reload and
  # restores the runtime col.active_border too.
  hyprctl reload
fi
