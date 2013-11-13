#!/bin/ash

POSTPROC="$@"
[ -n "$POSTPROC" ] || POSTPROC="cat -"

# functions
# prefixes all lines with a comma but the first one
comma() {
	awk '{ if (NR >1) print ","$0; else print $0; }'
}

# counts clients via bridge
# hardcoded interfaces br-mesh and wlan0 as they
# are the same on all routers
get_clients() {
	local COUNT=0
	local DEVNUMBER=
	DEVNUMBER=$(brctl showstp br-mesh |\
		grep -e "^wlan0 " |\
		cut -d" " -f2- | tr -d "()")
	if [ -n "$DEVNUMBER" ]; then
		COUNT=$(brctl showmacs br-mesh |\
			sed 's/[ \t]\+/ /g' |\
			grep -o -E "^ $DEVNUMBER [^ ]+ no" |\
			wc -l)
	fi
	echo $COUNT
}

# generate a json report compatible with libremap 1.0
report() {
	# json
	echo "{"

	# use lowercase MAC addr from br-mesh interface as id
	local ID=$(ifconfig br-mesh |\
			grep -o -E "HWaddr[ ]+[0-9a-fA-F:]+" |\
		 	tr -s " " |\
			cut -d" " -f2 |\
			tr "ABCDEF" "abcdef")
	local HOSTNAME=$(cat /proc/sys/kernel/hostname)
	echo "\"_id\":\"${ID}\""
	echo ",\"api_rev\":1.0"
	echo ",\"type\":\"router\""
	echo ",\"hostname\":\"${HOSTNAME}\""

	# location
	# latitude and longitude are required!
	echo ",\"location\":{"
	local LATITUDE=$(uci get site.location.latitude)
	local LOGITUDE=$(uci get site.location.longitude)
	local ELEVATION=$(uci get site.location.elevation 2>/dev/null)
	echo "\"lat\":${LATITUDE}"
	echo ",\"lon\":${LOGITUDE}"
	echo ",\"ele\":${ELEVATION}"
	echo "}"
	# /location

	# aliases
	# each mac adresses identifies the router
	echo ",\"aliases\":["
	ip -o address show |\
		grep -o -E "link/ether [0-9a-fA-F:]+" |\
		tr -s " " |\
		cut -d" " -f2 |\
		sort -u |\
		tr "ABCDEF" "abcdef" |\
		awk '{print "{\"alias\":\""$0"\",\"type\":\"mac\"}"}' |\
		comma
	echo "]"
	# /aliases

	# links
	echo ",\"links\":["
	batctl o |\
		grep -o -E "^([0-9a-f]{2}:?)+[ ]+[0-9.]+s[ ]+\([ 0-9]+\)[ ]+([0-9a-f]{2}:?)+[ ]+\[[^]]+\]" |\
		tr -d "s()[]" |\
		tr -s " " |\
		tr "ABCDEF" "abcdef" |\
		awk '{
			if ($1 == $4) {
				type="unk"
				if ($5 ~ /wlan/) type="wlan"
				if ($5 ~ /eth/) type="eth"
				if ($5 ~ /VPN/) type="vpn"
				if ($5 ~ /vpn/) type="vpn"
				quality=sprintf("%.2f",$3/255)
				print "{\"alias\":\""$1"\",\"type\":\"mac\",\"quality\":"quality",\"attributes\":{\"type\":\""type"\"}}"
			}
		}' |\
		comma
	echo "]"
	# /links

	# attributes
	echo ",\"attributes\":{"

	# contact
	echo "\"contact\":{"
	local CONTACT=$(uci get site.contact.name 2>/dev/null)
	local EMAIL=$(uci get site.contact.email 2>/dev/null)
	local TELEPHONE=$(uci get site.contact.telephone 2>/dev/null)
	echo "\"name\":\"${CONTACT}\""
	echo ",\"email\":\"${EMAIL}\""
	echo ",\"telephone\":\"${TELEPHONE}\""
	echo "}"
	# /contact

	# site
	echo ",\"site\":{"
	local DIRECTION=$(uci get site.location.direction)
	local TAGS=$(uci get site.location.tags)
	echo "\"direction\":\"${DIRECTION}\""
	echo ",\"tags\":\"${TAGS}\""
	echo "}"
	# /site

	# system
	echo ",\"system\":{"
	local HARDWARE=$(uci get board.model.name)
	local FIRMWARE=$(cat /etc/*release |\
		grep "^FIRMWARE_VERSION=" |\
		cut -d= -f2 |\
		tr -d "'\"")
	local DISTIBUTION=$(cat /etc/*release |\
		grep "^DISTRIB_DESCRIPTION=" |\
		cut -d= -f2 |\
		tr -d "'\"")
	local LINUX=$(uname -r)
	local FASTD=$(fastd -v | cut -d" " -f2)
	local MEMORY=$(cat /proc/meminfo |\
		grep -e "MemTotal:" |\
		awk -F" " '{print $2}')
	echo "\"hardware\":\"$HARDWARE\""
	echo ",\"firmware\":\"$FIRMWARE\""
	echo ",\"distribution\":\"$DISTIBUTION\""
	echo ",\"linux\":\"$LINUX\""
	echo ",\"fastd\":\"$FASTD\""
	echo ",\"memory\":$MEMORY"
	echo "}"
	# /system


	# load
	echo ",\"load\":{"
	local CPU_LOAD=$(cat /proc/loadavg | cut -d" " -f2)
	local MEMORY_FREE=$(cat /proc/meminfo |\
		grep -e "MemFree:" |\
		awk -F" " '{print $2}')
	local MEMORY_BUFFERS=$(cat /proc/meminfo |\
		grep -e "Buffers:" |\
		awk -F" " '{print $2}')
	local MEMORY_LOAD=$(echo $MEMORY $MEMORY_FREE $MEMORY_BUFFERS |\
		awk '{printf "%.2f",(($1-$2-$3)/$1)}')
 	local TRAFFIC_MESH=
	local TRAFFIC_WAN=
	if [ -f '/var/statistics/traffic' ]; then
		TRAFFIC_MESH=$(cat /var/statistics/traffic |\
			grep -e "^bat0 " |\
			awk '{ printf "[%.2f,%.2f]",$4/1024,$2/1024}')
		TRAFFIC_WAN=$(cat /var/statistics/traffic |\
			grep -E "^[^ ]*(VPN|vpn)[^ ]* " |\
			head -n1 |\
			awk '{ printf "[%.2f,%.2f]",$4/1024,$2/1024}')
	fi
	[ -n "$TRAFFIC_MESH" ] || TRAFFIC_MESH=[0,0]
	[ -n "$TRAFFIC_WAN" ] || TRAFFIC_WAN=[0,0]
	local CLIENTS=$(get_clients)
	echo "\"cpu\":$CPU_LOAD"
	echo ",\"memory\":$MEMORY_LOAD"
	echo ",\"clients\":$CLIENTS"
	echo ",\"traffic\":{"
	echo "\"mesh\":"$TRAFFIC_MESH
	echo ",\"wan\":"$TRAFFIC_WAN
	echo "}"
	echo "}"
	# /load

	# internet
	# get data from selected or (if unavailable) best connected gw
	echo ",\"internet\":{"
	batctl gwl |\
	awk -F" " 'BEGIN {
		gateway_sel=""
		via_sel=""
		quality_sel=0
		}
			/Gateway/ { next }
			/No gateways/ { next }
		{
			sub("^=>", "1", $0)
			sub("^  ", "0", $0)
			sub(" *\\( *", " ", $0)
			sub(" *\\) *", " ", $0)
			sub(" *\\[ *", " ", $0)
			sub(" *\\]: *", " ", $0)
			quality=sprintf("%.2f",$3/255)
			if ($1 == 1) {
				gateway_sel=$2
				via_sel=$4
				quality_sel=quality
				exit
			} else if (quality > quality_sel)  {
				gateway_sel=$2
				via_sel=$4
				quality_sel=quality
			}
		}
		END {
		print "\"alias\":\""gateway_sel"\""
		print ",\"type\":\"mac\""
		print ",\"quality\":"quality_sel
		print ",\"via\":{"
		print "\"alias\":\""via_sel"\""
		print ",\"type\":\"mac\""
		print "}"
	}'
	echo "}"
	# /gateway

	echo "}"
	# /attributes

	echo "}"
	# /json
}

report | $POSTPROC
