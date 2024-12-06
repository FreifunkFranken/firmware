#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-only
#
# Netmon Nodewatcher (C) 2010-2012 Freifunk Oldenburg

. /lib/functions/system.sh

debug() {
	(>&2 echo "nodewatcher: $1")
}

debug "Collecting information about connected clients"

client_count=0
dataclient=""

count_clients() {
	local name="$1"

	[ "$(uci -q get network.$name.fff_clientif)" = "1" ] || return

	CLIENT_INTERFACES=$(ls "/sys/class/net/br-$name/brif" | grep -v '^bat')
	for clientif in ${CLIENT_INTERFACES}; do
		cc=$(bridge fdb show br "br-$name" brport "$clientif" | grep -v self | grep -v permanent -c)
		client_count=$((client_count + cc))
		dataclient="$dataclient<$clientif>$cc</$clientif>"
	done
}

config_load network
config_foreach count_clients interface

echo -n "<client_count>$client_count</client_count>"
echo -n "<clients>$dataclient</clients>"

exit 0
