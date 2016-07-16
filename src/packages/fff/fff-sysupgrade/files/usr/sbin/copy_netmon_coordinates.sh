#!/bin/sh

delete_myself()
{
	echo "This Script will be deleted now!"
	rm -f /usr/lib/micron.d/fff-sysupgrade
	rm -f "$0"
	exit 0
}

#Get Mac Address of br-mesh if already up
if ! mac=$( cat /sys/class/net/br-mesh/address ); then
	echo "Interface br-mesh is not available!"
	exit 1
fi

#Check if Coordinates are already set
if uci get system.@system[0].latitude && uci get system.@system[0].longitude; then
	echo "Coordinates are already set."
	delete_myself
fi

#Get Router from Netmon Database
xml_data=$( wget -q -O - "http://fe80::ff:feee:1%br-mesh/api/rest/api.php?rquest=router&mac=${mac//:}" 2>&1)

if [ -z "$xml_data" ]; then
	echo "xml_data is not set"
	exit 1
elif echo "$xml_data"|grep "HTTP/1.1 404 Not Found" ;then
	echo "This Router is not present in the Netmon Database."
	delete_myself
fi

#Reduce XML_DATA to Router only
xml_data=$( echo $xml_data |grep -o '<router>.*<\/router>' |sed -e 's/<user>.*<\/user>//g' |sed -e 's/<chipset>.*<\/chipset>//g' |sed -e 's/<chipset>.*<\/chipset>//g' )

#Get needed Variables
hostname=$( echo $xml_data |grep -o  '<hostname>.*<\/hostname>'|sed -e 's/<\/\?hostname>//g' )
description=$( echo $xml_data |grep -o  '<description>.*<\/description>'|sed -e 's/<\/\?description>//g' )
latitude=$( echo $xml_data |grep -o  '<latitude>.*<\/latitude>'|sed -e 's/<\/\?latitude>//g' )
longitude=$( echo $xml_data |grep -o  '<longitude>.*<\/longitude>'|sed -e 's/<\/\?longitude>//g' )

#Check for netmon default coordinates
if [ "$latitude" -eq 0 ] && [ "$longitude" -eq 0 ]; then
	echo "Unable to retrieve coordinates from Netmon."
	echo "Maybe the coordinates are suppressed."
	delete_myself
fi

uci set system.@system[0]=system
echo "Setting hostname $hostname"
uci set system.@system[0].hostname="$hostname"
echo "Setting description $description"
uci set system.@system[0].description="$description"
echo "Setting latitude $latitude"
uci set system.@system[0].latitude="$latitude"
echo "Setting longitude $longitude"
uci set system.@system[0].longitude="$longitude"
uci commit

echo "Coordinates are now copied from Netmon. Router will be rebooted."
reboot
exit 0