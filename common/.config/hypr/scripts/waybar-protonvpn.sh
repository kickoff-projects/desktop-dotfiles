#!/usr/bin/env bash
# waybar custom/protonvpn: text, class and tooltip for the Proton VPN tunnel.
# NetworkManager owns the tunnel, so state comes from nmcli rather than from
# `protonvpn status`, which parses the 25 MB server-list cache on every call.

emit() {
	local line server type dev

	# proton-vpn-api-core names the tunnel "ProtonVPN <server>" and names every
	# kill-switch connection "pvpn-...", so the name prefix alone identifies it.
	# The NetworkManager type is not matched on: the wireguard protocol gives
	# type "wireguard", while Stealth, Auto and OpenVPN give type "vpn".
	line=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active 2>/dev/null |
		awk -F: '$1 ~ /^ProtonVPN / {print $1 "\t" $2 "\t" $3; exit}')

	if [[ -z $line ]]; then
		printf '{"text":"off 󰦝   ","class":"disconnected","tooltip":"Proton VPN disconnected"}\n'
		return
	fi

	IFS=$'\t' read -r server type dev <<<"$line"
	server=${server#ProtonVPN }

	printf '{"text":"%s 󰦝   ","class":"connected","tooltip":"Proton VPN | %s | %s | %s"}\n' \
		"$server" "$server" "$dev" "$type"
}

emit

# nmcli monitor prints one line per NetworkManager change and uses no CPU while
# idle, so the module updates on connect and disconnect without polling.
while read -r _; do
	emit
done < <(nmcli monitor)
