#!/bin/sh
# Netmon Nodewatcher (C) 2010-2011 Freifunk Oldenburg
# Lizenz: GPL

SCRIPT_DIR=`dirname $0`

if [ -f /etc/config/nodewatcher ];then
	API_IPV4_ADRESS=`uci get nodewatcher.@api[0].ipv4_address`
	API_IPV6_ADRESS=`uci get nodewatcher.@api[0].ipv6_address`
	API_IPV6_INTERFACE=`uci get nodewatcher.@api[0].ipv6_interface`
	API_TIMEOUT=`uci get nodewatcher.@api[0].timeout`
	API_RETRY=`uci get nodewatcher.@api[0].retry`
	SCRIPT_VERSION=`uci get nodewatcher.@script[0].version`
	SCRIPT_ERROR_LEVEL=`uci get nodewatcher.@script[0].error_level`
	SCRIPT_LOGFILE=`uci get nodewatcher.@script[0].logfile`
	SCRIPT_SYNC_HOSTNAME=`uci get nodewatcher.@script[0].sync_hostname`
	CRAWL_METHOD=`uci get nodewatcher.@crawl[0].method`
	CRAWL_ROUTER_ID=`uci get nodewatcher.@crawl[0].router_id`
	CRAWL_UPDATE_HASH=`uci get nodewatcher.@crawl[0].update_hash`
	CRAWL_NICKNAME=`uci get nodewatcher.@crawl[0].nickname`
	CRAWL_PASSWORD=`uci get nodewatcher.@crawl[0].password`
	UPDATE_AUTOUPDATE=`uci get nodewatcher.@update[0].autoupdate`
	MESH_INTERFACE=`uci get nodewatcher.@network[0].mesh_interface`
	CLIENT_INTERFACES=`uci get nodewatcher.@network[0].client_interfaces`
else
	. $SCRIPT_DIR/nodewatcher_config
fi

#Set default values if nothing is set
if [ -n $API_TIMEOUT ]; then
	API_TIMEOUT="5"
fi
if [ -n $API_RETRY ]; then
	API_RETRY="5"
fi
if [ -n $MESH_INTERFACE ]; then
	MESH_INTERFACE="br-mesh"
fi
if [ -n $CLIENT_INTERFACES ]; then
	CLIENT_INTERFACES="ath0"
fi
if [ -n $SCRIPT_SYNC_HOSTNAME ]; then
	SCRIPT_SYNC_HOSTNAME="1"
fi

API_RETRY=$(($API_RETRY - 1))

delete_log() {
	if [ -f $logfile ]; then
		if [ `ls -la $logfile | awk '{ print $5 }'` -gt "6000" ]; then
			sed -i '1,60d' $logfile
			if [ $error_level -gt "1" ]; then
				echo "`date`: Logfile wurde verkleinert" >> $logfile
			fi
		fi
	fi
}

get_url() {
	if [[ $API_IPV4_ADRESS != "1" ]]; then
		url=$API_IPV4_ADRESS
	else
		url="[$API_IPV6_ADRESS"%"$API_IPV6_INTERFACE]"
	fi
	echo $url
}

get_curl() {
	if [[ $API_IPV4_ADRESS != "1" ]]; then
		curl="http://$API_IPV4_ADRESS"
	else
		numeric_scope_id=`ip addr | grep $API_IPV6_INTERFACE | awk '{ print $1 }' | sed 's/://'`
		curl="-g http://$API_IPV6_ADRESS%$numeric_scope_id"
	fi
	echo $curl
}

do_ping() {
	if [[ $API_IPV4_ADRESS != "1" ]]; then
		command="ping -c 2 "$API_IPV4_ADRESS
	else
		command="ping -c 2 -I "$API_IPV6_INTERFACE" "$API_IPV6_ADRESS
	fi

	if [ $error_level -gt "1" ]; then
		echo "`date`: Pinging..." >> $logfile
	fi
	
	ping_return=`$command`

	if [ $error_level -gt "2" ]; then
		echo $ping_return
	fi
}

update() {
	if [ $error_level -gt "1" ]; then
		echo "`date`: Suche neue Version" >> $logfile
	fi
	netmon_api=`get_url`
	command="wget -q -O - http://$netmon_api/api_nodewatcher.php?section=version&nodewatcher_version=$SCRIPT_VERSION"
	ergebnis=`$command&sleep $API_TIMEOUT; kill $!`
	return=`echo $ergebnis| cut '-d;' -f1`
	version=`echo $ergebnis| cut '-d;' -f2`

	if [[ "$return" = "success" ]]; then
		if [[ $version -gt $SCRIPT_VERSION ]]; then
			if [ $error_level -gt "1" ]; then
				echo "`date`: Eine neue Version ist Verfügbar, script wird geupdated" >> $logfile
			fi
			wget -q -O $SCRIPT_DIR/nodewatcher.sh "http://$netmon_api/api_nodewatcher.php?section=update&nodewatcher_version=$SCRIPT_VERSION"
			uci set nodewatcher.@script[0].version=$version
			uci commit
		else
			if [ $error_level -gt "1" ]; then
				echo "`date`: Das Script ist aktuell" >> $logfile
			fi
		fi
	else
		if [ $error_level -gt "0" ]; then
			echo "`date`: Beim Update ist ein Fehler aufgetreten: $ergebnis" >> $logfile
		fi
	fi
}

assign() {
	netmon_api=`get_url`
	hostname=`cat /proc/sys/kernel/hostname`
	
	#Choose right login String
	login_strings="$(ifconfig br-mesh | grep HWaddr | awk '{ print $5 }'|sed -e 's/://g');$(ifconfig eth0 | grep HWaddr | awk '{ print $5 }'|sed -e 's/://g');$(ifconfig ath0 | grep HWaddr | awk '{ print $5 }'|sed -e 's/://g')"
	command="wget -q -O - http://$netmon_api/api_nodewatcher.php?section=test_login_strings&login_strings=$login_strings"
	ergebnis=`$command&sleep $API_TIMEOUT; kill $!`
	if [ `echo $ergebnis| cut '-d;' -f1` = "success" ]; then
		router_auto_assign_login_string=`echo $ergebnis| cut '-d;' -f2`
		if [ $error_level -gt "1" ]; then
			echo "`date`: Es existiert ein Router mit dem Login String $router_auto_assign_login_string" >> $logfile
		fi
	elif [ `echo $ergebnis| cut '-d;' -f1` = "error" ]; then
		router_auto_assign_login_string=`echo $login_strings| cut '-d;' -f1`
		if [ $error_level -gt "1" ]; then
			echo "`date`: Es existiert kein Router mit einem der Login Strings: $login_strings" >> $logfile
			echo "`date`: Nutze $router_auto_assign_login_string als login string" >> $logfile
		fi
	fi

	#Try to assign Router with choosen login string
	command="wget -q -O - http://$netmon_api/api_nodewatcher.php?section=router_auto_assign&router_auto_assign_login_string=$router_auto_assign_login_string&hostname=$hostname"
	ergebnis=`$command&sleep $API_TIMEOUT; kill $!`
	if [ `echo $ergebnis| cut '-d;' -f1` != "success" ]; then
		if [ `echo $ergebnis| cut '-d;' -f2` = "already_assigned" ]; then
			if [ $error_level -gt "0" ]; then
				echo "`date`: Der Login String `echo $ergebnis| cut '-d;' -f3` ist bereits mit einem Router verknüpft" >> $logfile
			fi
		elif [ `echo $ergebnis| cut '-d;' -f2` = "autoassign_not_allowed" ]; then
			if [ $error_level -gt "0" ]; then
				echo "`date`: Der dem Login String `echo $ergebnis| cut '-d;' -f3` zugewiesene Router erlaubt autoassign nicht" >> $logfile
			fi
		elif [ `echo $ergebnis| cut '-d;' -f2` = "new_not_assigned" ]; then
			if [ $error_level -gt "0" ]; then
				echo "`date`: Router wurde der Liste der nicht zugewiesenen Router hinzugefügt" >> $logfile
			fi
		elif [ `echo $ergebnis| cut '-d;' -f2` = "updated_not_assigned" ]; then
			if [ $error_level -gt "0" ]; then
				echo "`date`: Router auf der Liste der nicht zugewiesenen Router wurde geupdated" >> $logfile
			fi
		fi
		if [ $error_level -gt "0" ]; then
			echo "`date`: Der Router wurde nicht mit Netmon verknüpft" >> $logfile
		fi
	elif [ `echo $ergebnis| cut '-d;' -f1` = "success" ]; then
		#write new config
		uci set nodewatcher.@crawl[0].router_id=`echo $ergebnis| cut '-d;' -f2`
		uci set nodewatcher.@crawl[0].update_hash=`echo $ergebnis| cut '-d;' -f3`
		if [ $error_level -gt "1" ]; then
			echo "`date`: Der Router wurde mit Netmon verknüpft" >> $logfile
		fi
		uci commit

		CRAWL_METHOD=`uci get nodewatcher.@crawl[0].method`
		CRAWL_ROUTER_ID=`uci get nodewatcher.@crawl[0].router_id`
		CRAWL_UPDATE_HASH=`uci get nodewatcher.@crawl[0].update_hash`
		CRAWL_NICKNAME=`uci get nodewatcher.@crawl[0].nickname`
		CRAWL_PASSWORD=`uci get nodewatcher.@crawl[0].password`

		configure

		can_crawl=1
	fi
}

configure() {
	netmon_api=`get_url`
	authentificationmethod=$CRAWL_METHOD
	router_id=$CRAWL_ROUTER_ID
	router_auto_update_hash=$CRAWL_UPDATE_HASH
	
	command="wget -q -O - http://$netmon_api/api_nodewatcher.php?section=get_standart_data&authentificationmethod=$authentificationmethod&router_auto_update_hash=$router_auto_update_hash&router_id=$router_id"
	ergebnis=`$command&sleep $API_TIMEOUT; kill $!`

	if [ `echo $ergebnis| cut '-d;' -f1` = "success" ]; then
		#uci set freifunk.contact.location=`echo $ergebnis| cut '-d;' -f3`

		if [[ $SCRIPT_SYNC_HOSTNAME = "1" ]]; then		
			if [ $error_level -gt "1" ]; then
				echo "`date`: Setze Hostname" >> $logfile
			fi
			uci set system.@system[0].hostname=`echo $ergebnis| cut '-d;' -f4`
			echo `echo $ergebnis| cut '-d;' -f4` > /proc/sys/kernel/hostname

#			uci get system.@system[0].latitude=
#			uci get system.@system[0].longitude=
#			uci get freifunk.community.ssid=
#			uci get freifunk.contact.nickname=
#			uci get freifunk.contact.mail=
#			uci get freifunk.community.prefix=
#			uci get freifunk.contact.note=
			
			uci commit
		fi
		if [ $error_level -gt "1" ]; then
			echo "`date`: Der Router wurde konfiguriert" >> $logfile
		fi
	else
		if [ $error_level -gt "0" ]; then
			echo "`date`: Fehler bei der Konfiguration: $ergebnis" >> $logfile
		fi
	fi
}

crawl() {
	#Get API and authentication configuration
	netmon_api=`get_url`
	authentificationmethod=$CRAWL_METHOD
	nickname=$CRAWL_NICKNAME
	password=$CRAWL_PASSWORD
	router_id=$CRAWL_ROUTER_ID
	router_auto_update_hash=$CRAWL_UPDATE_HASH

	#Get system data from UCI
	if which uci >/dev/null; then
		if [ $error_level -gt "1" ]; then
			echo "`date`: UCI is installed, trying to collect extra data UCI" >> $logfile
		fi
		location="`uci get freifunk.contact.location`"
		latitude="`uci get system.@system[0].latitude`"
		longitude="`uci get system.@system[0].longitude`"
		
		community_essid="`uci get freifunk.community.ssid`"
		community_nickname="`uci get freifunk.contact.nickname`"
		community_email="`uci get freifunk.contact.mail`"
		community_prefix="`uci get freifunk.community.prefix`"
		description="`uci get freifunk.contact.note`"
	fi

	#Get system data from LUA	
	if which lua >/dev/null; then
		if [ $error_level -gt "1" ]; then
			echo "`date`: LUA is installed, trying to collect extra data LUA" >> $logfile
		fi
		luciname=`lua -l luci.version -e 'print(luci.version.luciname)'`
		lucversion=`lua -l luci.version -e 'print(luci.version.luciversion)'`
	fi
	
	#Get system data from other locations
	hostname="`cat /proc/sys/kernel/hostname`"
	uptime=`cat /proc/uptime | awk '{ print $1 }'`
	idletime=`cat /proc/uptime | awk '{ print $2 }'`
	
	memory_total=`cat /proc/meminfo | grep 'MemTotal' | awk '{ print $2 }'`
	memory_caching=`cat /proc/meminfo | grep -m 1 'Cached:' | awk '{ print $2 }'`
	memory_buffering=`cat /proc/meminfo | grep 'Buffers' | awk '{ print $2 }'`
	memory_free=`cat /proc/meminfo | grep 'MemFree' | awk '{ print $2 }'`
	cpu=`grep -m 1 "cpu model" /proc/cpuinfo | cut -d ":" -f 2`
	if [ -n $cpu ]; then
		cpu=`grep -m 1 "model name" /proc/cpuinfo | cut -d ":" -f 2`
	fi

	chipset=`grep -m 1 "system type" /proc/cpuinfo | cut -d ":" -f 2`
	local_time="`date +%s`"
	processes=`cat /proc/loadavg | awk '{ print $4 }'`
	loadavg=`cat /proc/loadavg | awk '{ print $1 }'`

	if which batctl >/dev/null; then
		batman_adv_version=`batctl -v | awk '{ print $2 }'`
	fi
	kernel_version=`uname -r`
	nodewatcher_version=$SCRIPT_VERSION

	openwrt_version_file="/etc/openwrt_release"
	if [ -f $openwrt_version_file ]; then
		. $openwrt_version_file

		distname=$DISTRIB_ID
		distversion=$DISTRIB_RELEASE
	fi

	firmware_version_file="/etc/firmware_release"
	if [ -f $firmware_version_file ]; then
		. $firmware_version_file

		firmware_version=$FIRMWARE_VERSION
	fi

	#Get interfaces
	IFACES=`cat /proc/net/dev | awk -F: '!/\|/ { gsub(/[[:space:]]*/, "", $1); split($2, a, " "); printf("%s=%s=%s ", $1, a[1], a[9]) }'`

	int=""	
	#Loop interfaces
	for entry in $IFACES; do
		iface=`echo $entry | cut -d '=' -f 1`
		rcv=`echo $entry | cut -d '=' -f 2`
		xmt=`echo $entry | cut -d '=' -f 3`
		
		wlan_mode=""
		wlan_bssid=""
		wlan_essid=""
		wlan_frequency=""
		wlan_tx_power=""
		
		if [ "$iface" != "lo" ]; then
			if [ "`ifconfig ${iface} | grep UP`" != "" ]; then
				#Get interface data
				name="${iface}"
				mac_addr="`ifconfig ${iface} | grep 'HWaddr' | awk '{ print $5}'`"
				ipv4_addr="`ifconfig ${iface} | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`"
				ipv6_addr="`ifconfig ${iface} | grep 'inet6 addr:' | grep 'Scope:Global' | awk '{ print $3}'`"
				ipv6_link_local_addr="`ifconfig ${iface} | grep 'inet6 addr:' | grep 'Scope:Link' | awk '{ print $3}'`"
				mtu="`ifconfig ${iface} | grep 'MTU' | cut -d: -f2 | awk '{ print $1}'`"
				traffic_rx="$rcv"
				traffic_tx="$xmt"
				
				int=$int"<$name><mac_addr>$mac_addr</mac_addr><ipv4_addr>$ipv4_addr</ipv4_addr><ipv6_addr>$ipv6_addr</ipv6_addr><ipv6_link_local_addr>$ipv6_link_local_addr</ipv6_link_local_addr><traffic_rx>$traffic_rx</traffic_rx><traffic_tx>$traffic_tx</traffic_tx><mtu>$mtu</mtu>"
				
				if [ "`iwconfig ${iface} 2>/dev/null | grep Frequency | awk '{ print $2 }' | cut -d ':' -f 2`" != "" ]; then
					wlan_mode="`iwconfig ${iface} 2>/dev/null | grep 'Mode' | awk '{ print $1 }' | cut -d ':' -f 2`"
				
					if [ $wlan_mode = "Master" ]; then	
						wlan_bssid="`iwconfig ${iface} 2>/dev/null | grep 'Access Point' | awk '{ print $6 }'`"
					elif [ $wlan_mode = "Ad-Hoc" ]; then	
						wlan_bssid="`iwconfig ${iface} 2>/dev/null | grep Cell | awk '{ print $5 }'`"
					fi
					
					wlan_essid="`iwconfig ${iface} 2>/dev/null | grep ESSID | awk '{ split($4, a, \"\\"\"); printf(\"%s\", a[2]); }'`"
					wlan_frequency="`iwconfig ${iface} 2>/dev/null | grep Frequency | awk '{ print $2 }' | cut -d ':' -f 2`"
					wlan_tx_power="`iwconfig ${iface} 2>/dev/null | grep 'Tx-Power' | awk '{ print $4 }' | cut -d '=' -f 2`"
					int=$int"<wlan_mode>$wlan_mode</wlan_mode><wlan_frequency>$wlan_frequency</wlan_frequency><wlan_essid>$wlan_essid</wlan_essid><wlan_bssid>wlan_bssid</wlan_bssid><wlan_tx_power>$wlan_tx_power</wlan_tx_power>"
				fi
				int=$int"</$name>"
			fi
		fi
	done

	#B.A.T.M.A.N. advanced
	mv /etc/bat-hosts /etc/bat-hosts.tmp
	if which batctl >/dev/null; then
        	batman_check_running=`batctl if | grep 'Error'`
		if [ "$batman_check_running" == "" ]; then
			has_active_interface="0"
			BAT_ADV_IFACES=`batctl if | awk '{ print $1 }' | cut -d ':' -f 1`
			for device_name in $BAT_ADV_IFACES; do
				if [ "`batctl if | grep $device_name | grep active`" != "" ]; then
					status='active'
					has_active_interface="1"
				else
					status='inactive'
				fi

				BATMAN_ADV_INTERFACES=$BATMAN_ADV_INTERFACES"<$device_name><status>$status</status></$device_name>"
			done
			
			if [ $has_active_interface = "1" ]; then
				BAT_ADV_ORIGINATORS=`batctl o | grep 'No batman nodes in range'`
				if [ "$BAT_ADV_ORIGINATORS" == "" ]; then
					OLDIFS=$IFS
					IFS="
"
					BAT_ADV_ORIGINATORS=`batctl o | awk '/O/ {next} /B/ {next} {print}'`
					for row in $BAT_ADV_ORIGINATORS; do
						originator=`echo $row | awk '{print $1}'`
						last_seen=`echo $row | awk '{print $2}'`
						last_seen="${last_seen//s/}"
						link_quality=`echo $row | awk '{print $3}'`
						link_quality="${link_quality//(/}"
						link_quality="${link_quality//)/}"
						
						batman_adv_originators=$batman_adv_originators"<originator_data><originator>$originator</originator><link_quality>$link_quality</link_quality><last_seen>$last_seen</last_seen></originator_data>"
					done
					IFS=$OLDIFS
				fi
			fi
		fi
	fi
	mv /etc/bat-hosts.tmp /etc/bat-hosts

	#CLIENTS
	SEDDEV=`brctl showstp $MESH_INTERFACE | egrep '\([0-9]\)' | sed -e "s/(//;s/)//" | awk '{ print "s/^  "$2"/"$1"/;" }'`

	for entry in $CLIENT_INTERFACES; do
	CLIENT_MACS=$CLIENT_MACS`brctl showmacs $MESH_INTERFACE | sed -e "$SEDDEV" | awk '{if ($3 != "yes" && $1 == "'"$entry"'") print $2}'`" "
	done

	i=0
	for client in $CLIENT_MACS; do
		i=`expr $i + 1`  #Zähler um eins erhöhen
	done
	client_count=$i

	AUTHENTIFICATION_DATA="<authentificationmethod>$authentificationmethod</authentificationmethod><nickname>$nickname</nickname><password>$password</password><router_auto_update_hash>$router_auto_update_hash</router_auto_update_hash><router_id>$router_id</router_id>"
	SYSTEM_DATA="<status>online</status><hostname>$hostname</hostname><description>$description</description><location>$location</location><latitude>$latitude</latitude><longitude>$longitude</longitude><luciname>$luciname</luciname><luciversion>$luciversion</luciversion><distname>$distname</distname><distversion>$distversion</distversion><chipset>$chipset</chipset><cpu>$cpu</cpu><memory_total>$memory_total</memory_total><memory_caching>$memory_caching</memory_caching><memory_buffering>$memory_buffering</memory_buffering><memory_free>$memory_free</memory_free><loadavg>$loadavg</loadavg><processes>$processes</processes><uptime>$uptime</uptime><idletime>$idletime</idletime><local_time>$local_time</local_time><community_essid>$community_essid</community_essid><community_nickname>$community_nickname</community_nickname><community_email>$community_email</community_email><community_prefix>$community_prefix</community_prefix><batman_advanced_version>$batman_adv_version</batman_advanced_version><kernel_version>$kernel_version</kernel_version><nodewatcher_version>$nodewatcher_version</nodewatcher_version><firmware_version>$firmware_version</firmware_version>"
	INTERFACE_DATA="$int"
	BATMAN_ADV_ORIGINATORS="$batman_adv_originators"
	CLIENT_DATA="$client_count"

	DATA="<?xml version='1.0' standalone='yes'?><data><authentification_data>$AUTHENTIFICATION_DATA</authentification_data><system_data>$SYSTEM_DATA</system_data><interface_data>$INTERFACE_DATA</interface_data><batman_adv_interfaces>$BATMAN_ADV_INTERFACES</batman_adv_interfaces><batman_adv_originators>$BATMAN_ADV_ORIGINATORS</batman_adv_originators><client_data>$CLIENT_DATA</client_data></data>"

	#Send system data
	echo $DATA > /tmp/node.data
	if [[ $SCRIPT_SYNC_HOSTNAME = "1" ]]; then
		netmon_hostname="`echo $api_return | cut '-d;' -f2`"
		if [ "$netmon_hostname" != "`cat /proc/sys/kernel/hostname`" ]; then
				if [ $error_level -gt "1" ]; then
					echo "`date`: Setze neuen Hostname (Hostname synchronisation)" >> $logfile
				fi
				uci set system.@system[0].hostname=$netmon_hostname
				uci commit
				echo $netmon_hostname > /proc/sys/kernel/hostname
		fi
	fi
}



LANG=C

SCRIPT_DIR=`dirname $0`
error_level=$SCRIPT_ERROR_LEVEL
logfile=$SCRIPT_LOGFILE

if [[ $UPDATE_AUTOUPDATE == '1' ]]; then
	if [ $error_level -gt "1" ]; then
		echo "`date`: Autoupdate ist an" >> $logfile
	fi
	update
else
	if [ $error_level -gt "1" ]; then
		echo "`date`: Autoupdate ist aus" >> $logfile
	fi
fi

if [[ "$1" == "update" ]]; then
	if [ $error_level -gt "1" ]; then
		echo "`date`: Führe manuelles update aus" >> $logfile
	fi
	update
	exit 1
fi


if [ $error_level -gt "1" ]; then
	echo "`date`: Prüfe Authentifizierungsmethode" >> $logfile
fi

can_crawl=1
if [ $CRAWL_METHOD == "login" ]; then
	if [ $error_level -gt "1" ]; then  
		echo "`date`: Authentifizierungsmethode ist: Username und Passwort" >> $logfile
	fi
elif [ $CRAWL_METHOD == "hash" ]; then
	if [ $error_level -gt "1" ]; then
		echo "`date`: Authentifizierungsmethode ist: Autoassign und Hash" >> $logfile
		echo "`date`: Prüfe ob Roter schon mit Netmon verknüpft ist" >> $logfile
	fi
	if [ $CRAWL_UPDATE_HASH == "1" ]; then
		can_crawl=0
		if [ $error_level -gt "1" ]; then
			echo "`date`: Der Router ist noch NICHT mit Netmon verknüpft" >> $logfile
			echo "`date`: Versuche verknüpfung herzustellen" >> $logfile
		fi
		assign
	else
		if [ $error_level -gt "1" ]; then
			echo "`date`: Der Router ist bereits mit Netmon verknüpft" >> $logfile
		fi
	fi
fi

if [ $can_crawl == 1 ]; then
 	if [ $error_level -gt "1" ]; then
		echo "`date`: Prüfe Logfile" >> $logfile
	fi
	delete_log

 	if [ $error_level -gt "1" ]; then
		echo "`date`: Sende aktuelle Statusdaten" >> $logfile
	fi
	crawl
fi
exit 0
