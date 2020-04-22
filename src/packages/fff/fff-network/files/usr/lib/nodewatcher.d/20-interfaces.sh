#!/bin/sh
# Netmon Nodewatcher (C) 2010-2012 Freifunk Oldenburg
# License; GPL v3

IFACEBLACKLIST=$(uci get nodewatcher.@network[0].iface_blacklist)
IPWHITELIST=$(uci get nodewatcher.@network[0].ip_whitelist)

debug() {
	(>&2 echo "nodewatcher: $1")
}

inArray() {
	local value
	for value in $1; do
		[ "$value" = "$2" ] && return 0
	done
	return 1
}

debug "Collecting information from network interfaces"

interface_data=""

# Loop through interfaces: for entry in $IFACES; do
for filename in $(grep 'up\|unknown' /sys/class/net/*/operstate); do
	ifpath=${filename%/operstate*}
	iface=${ifpath#/sys/class/net/}

	inArray "$IFACEBLACKLIST" "$iface" && continue

	#Get interface data for whitelisted interfaces
	# shellcheck disable=SC2016
	awkscript='
		/ether/ { printf "<mac_addr>"$2"</mac_addr>" }
		/mtu/ { printf "<mtu>"$5"</mtu>" }'
	if inArray "$IPWHITELIST" "$iface"; then
		# shellcheck disable=SC2016
		awkscript=$awkscript'
			/inet / { split($2, a, "/"); printf "<ipv4_addr>"a[1]"</ipv4_addr>" }
			/inet6/ && /scope global/ { printf "<ipv6_addr>"$2"</ipv6_addr>" }
			/inet6/ && /scope link/ { printf "<ipv6_link_local_addr>"$2"</ipv6_link_local_addr>"}'
	fi
	addrs=$(ip addr show dev "${iface}" | awk "$awkscript")

	traffic_rx=$(cat "$ifpath/statistics/rx_bytes")
	traffic_tx=$(cat "$ifpath/statistics/tx_bytes")

	interface_data=$interface_data"<$iface><name>$iface</name>$addrs<traffic_rx>$traffic_rx</traffic_rx><traffic_tx>$traffic_tx</traffic_tx>"

	interface_data=$interface_data$(iwconfig "${iface}" 2>/dev/null | awk -F':' '
		/Mode/{ split($2, m, " "); printf "<wlan_mode>"m[1]"</wlan_mode>" }
		/Cell/{ split($0, c, " "); printf "<wlan_bssid>"c[5]"</wlan_bssid>" }
		/ESSID/ { split($0, e, "\""); printf "<wlan_essid>"e[2]"</wlan_essid>" }
		/Freq/{ split($3, f, " "); printf "<wlan_frequency>"f[1]f[2]"</wlan_frequency>" }
		/Tx-Power/{ split($0, p, "="); sub(/[[:space:]]*$/, "", p[2]); printf "<wlan_tx_power>"p[2]"</wlan_tx_power>" }
	')

	interface_data=$interface_data$(iw dev "${iface}" info 2>/dev/null | awk '
		/ssid/{ split($0, s, " "); printf "<wlan_ssid>"s[2]"</wlan_ssid>" }
		/type/ { split($0, t, " "); printf "<wlan_type>"t[2]"</wlan_type>" }
		/channel/{ split($0, c, " "); printf "<wlan_channel>"c[2]"</wlan_channel>" }
		/width/{ split($0, w, ": "); sub(/ .*/, "", w[2]); printf "<wlan_width>"w[2]"</wlan_width>" }
	')

	interface_data=$interface_data"</$iface>"
done

echo -n "<interface_data>$interface_data</interface_data>"

exit 0
