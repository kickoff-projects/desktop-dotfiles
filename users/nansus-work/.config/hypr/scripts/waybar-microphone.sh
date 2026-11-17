#!/usr/bin/env bash
# nansus-work: copy of
# hosts/Home-Desktop/.config/hypr/scripts/waybar-microphone.sh, differing
# only in the no-device branch. The shared script prints a slashed glyph
# with class "unavailable"; this one prints empty text, because waybar
# hides a custom module whose text is empty and this account wants no
# microphone indicator at all on a machine with no capture device.
#
# The other two classes are what ../../waybar/style.css colors: "active"
# falls through to the base #custom-microphone rule (red glyph and
# underline), "source-muted" takes the green matching the volume module
# to its left.

info=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)

# No default source at all. wpctl still exits 0 and writes its "Translate
# ID error" to stdout, so the shape of the output is the only reliable test.
# Empty text hides the widget, so there is no class or tooltip to set.
if [[ $info != Volume:* ]]; then
	printf '{"text":""}\n'
	exit 0
fi

vol=$(awk '{printf "%d", $2 * 100}' <<<"$info")

if [[ $info == *MUTED* ]]; then
	printf '{"text":"  ","class":"source-muted","tooltip":"Microphone muted | %s%%"}\n' "$vol"
else
	printf '{"text":"  ","class":"active","tooltip":"Microphone | %s%%"}\n' "$vol"
fi
