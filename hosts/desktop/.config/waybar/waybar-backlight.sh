#!/usr/bin/env bash
# waybar custom/backlight: screen brightness for this host, read over DDC/CI.
# /sys/class/backlight is empty on this box, so waybar's own backlight module
# has no device to read and the percentage comes from "ddcutil getvcp 10"
# instead. The text layout matches the laptop's backlight module, and the
# seven icons are md-brightness_1 to md-brightness_7, one per seventh of the
# range.
#
# flock is shared with hypr/scripts/brightness.sh, which the F5/F6 keys and
# this module's scroll binds drive: one DDC call at a time, and this read waits
# up to two seconds for a held key to finish rather than failing.
#
# shortcut: the i2c bus is pinned to 8, where the VG34VQL1B answers. Run
# "ddcutil detect" and update the number if the GPU enumerates it differently.

set -u

icons=("󰃛" "󰃛" "󰃜" "󰃝 " "󰃞 " "󰃟 " "󰃠 ")

# --brief prints "VCP 10 C <current> <max>".
read -r _ _ _ cur max < <(
	flock -w 2 "${XDG_RUNTIME_DIR:-/tmp}/brightness.lock" \
		ddcutil --bus 8 --brief getvcp 10 2>/dev/null
)

# The monitor rejects DDC while it is in HDR mode, and a busy bus times out.
if [[ -z ${max:-} || $max -eq 0 ]]; then
	printf '{"text":"󰃟 --","class":"unavailable","tooltip":"Brightness unavailable"}\n'
	exit 0
fi

pct=$((cur * 100 / max))
idx=$((pct * ${#icons[@]} / 100))
((idx >= ${#icons[@]})) && idx=$((${#icons[@]} - 1))

printf '{"text":"%s%d%%","class":"on","tooltip":"Brightness: %d%% "}\n' \
	"${icons[idx]}" "$pct" "$pct"
