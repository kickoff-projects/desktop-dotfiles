#!/usr/bin/env bash
# waybar custom/microphone: text, class and tooltip for the default source

info=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)

# no default source at all - wpctl still exits 0, so match on the output
if [[ $info != Volume:* ]]; then
	printf '{"text":"  ","class":"unavailable","tooltip":"No microphone"}\n'
	exit 0
fi

vol=$(awk '{printf "%d", $2 * 100}' <<<"$info")

if [[ $info == *MUTED* ]]; then
	printf '{"text":"  ","class":"source-muted","tooltip":"Microphone muted | %s%%"}\n' "$vol"
else
	printf '{"text":"  ","class":"active","tooltip":"Microphone | %s%%"}\n' "$vol"
fi
