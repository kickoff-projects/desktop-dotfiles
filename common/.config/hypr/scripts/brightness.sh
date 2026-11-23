#!/usr/bin/env bash
# F5/F6 screen brightness. Shared by both hosts because the mechanism differs
# per machine.
#
# The Laptop has a backlight class device, so brightnessctl drives its panel
# directly. The Desktop has an empty /sys/class/backlight: its ASUS VG34VQL1B
# is driven over DDC/CI on the DisplayPort i2c link instead. That monitor
# rejects DDC writes while it is in HDR, so a step is dropped whenever
# Hyprland has switched the output to HDR for fullscreen HDR content.
#
# flock keeps one DDC call in flight. A round trip takes about 0.3s and F5/F6
# are held-repeat binds, so without the guard a held key queues calls faster
# than the monitor answers them.
#
# shortcut: the i2c bus is pinned to 8, where the VG34VQL1B answers. Run
# "ddcutil detect" and update the number if the GPU enumerates it differently.

set -eu

case "${1:-}" in
  up)   backlight_step="10%+" ; ddc_step=(+ 10) ;;
  down) backlight_step="10%-" ; ddc_step=(- 10) ;;
  *)    echo "usage: ${0##*/} up|down" >&2 ; exit 2 ;;
esac

# A non-empty backlight class means this host can drive its panel directly.
if [ -n "$(ls -A /sys/class/backlight 2>/dev/null)" ]; then
  exec brightnessctl -c backlight s "$backlight_step"
fi

flock -n "${XDG_RUNTIME_DIR:-/tmp}/brightness.lock" \
  ddcutil --bus 8 --noverify setvcp 10 "${ddc_step[@]}"

# The Desktop's custom/backlight module has no interval: it reads the monitor
# once at startup and then only on SIGRTMIN+8, so the new value has to be
# announced here. set -e stops the script above this line when flock finds the
# lock held, so a dropped step sends no signal. pkill reports no match when
# waybar is not running, which is not an error for this script.
pkill -RTMIN+8 -x .waybar-wrapped || true
