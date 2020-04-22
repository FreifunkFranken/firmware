#!/bin/sh
# Netmon Nodewatcher (C) 2010-2012 Freifunk Oldenburg
# License; GPL v3

MESH_INTERFACE=$(uci get nodewatcher.@network[0].mesh_interface)

debug() {
	(>&2 echo "nodewatcher: $1")
}

debug "Collecting information about connected clients"

client_count=0
dataclient=""
CLIENT_INTERFACES=$(ls "/sys/class/net/$MESH_INTERFACE/brif" | grep -v '^bat')
for clientif in ${CLIENT_INTERFACES}; do
	cc=$(bridge fdb show br "$MESH_INTERFACE" brport "$clientif" | grep -v self | grep -v permanent -c)
	client_count=$((client_count + cc))
	dataclient="$dataclient<$clientif>$cc</$clientif>"
done

echo -n "<client_count>$client_count</client_count>"
echo -n "<clients>$dataclient</clients>"

exit 0
