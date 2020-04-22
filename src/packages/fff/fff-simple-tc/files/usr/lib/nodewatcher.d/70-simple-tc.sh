#!/bin/sh

. /lib/functions.sh

config_load simple-tc
tc_enabled="0"
tc_in="0"
tc_out="0"
parseTcInterface() {
	local iface="$1"

	config_get ifname "$iface" ifname
	[ "wan" = "$ifname" ] || return

	config_get tc_enabled "$iface" enabled "0"
	config_get tc_in "$iface" limit_ingress "0"
	config_get tc_out "$iface" limit_egress "0"
}
config_foreach parseTcInterface 'interface'

echo -n "<traffic_control><wan><enabled>$tc_enabled</enabled><in>$tc_in</in><out>$tc_out</out></wan></traffic_control>"

exit 0
