MESH_INTERFACE="br-mesh"
CLIENT_INTERFACES="wlan0"

#CLIENTS
SEDDEV=`brctl showstp $MESH_INTERFACE | egrep '\([0-9]\)' | sed -e "s/(//;s/)//" | awk '{ print "s/^  "$2"/"$1"/;" }'`
	
for entry in $CLIENT_INTERFACES; do
	CLIENT_MACS=$CLIENT_MACS`brctl showmacs $MESH_INTERFACE | sed -e "$SEDDEV" | awk '{if ($3 != "yes" && $1 == "'"$entry"'") print $2}'`" "
done
					
i=0
for client in $CLIENT_MACS; do
	i=`expr $i + 1`  #Zähler um eins erhöhen
done
echo $i
