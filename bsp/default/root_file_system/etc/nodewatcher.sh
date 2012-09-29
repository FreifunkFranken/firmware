#!/bin/sh
# Netmon Nodewatcher (C) 2010-2012 Freifunk Oldenburg
# License; GPL v3

#Get the configuration from the uci configuration file
#If it does not exists, then get it from a normal bash file with variables.
if [ -f /etc/config/nodewatcher ];then
	SCRIPT_VERSION=`uci get nodewatcher.@script[0].version`
	SCRIPT_ERROR_LEVEL=`uci get nodewatcher.@script[0].error_level`
	SCRIPT_LOGFILE=`uci get nodewatcher.@script[0].logfile`
	SCRIPT_DATA_FILE=`uci get nodewatcher.@script[0].data_file`
	MESH_INTERFACE=`uci get nodewatcher.@network[0].mesh_interface`
	CLIENT_INTERFACES=`uci get nodewatcher.@network[0].client_interfaces`
else
	. `dirname $0`/nodewatcher_config
fi

#this method checks id the logfile has bekome too big and deletes the first X lines
delete_log() {
	if [ -f $SCRIPT_LOGFILE ]; then
		if [ `ls -la $SCRIPT_LOGFILE | awk '{ print $5 }'` -gt "6000" ]; then
			sed -i '1,60d' $SCRIPT_LOGFILE
			if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
				echo "`date`: Logfile has been made smaller" >> $SCRIPT_LOGFILE
			fi
		fi
	fi
}

#this method generates the crawl data xml file that is beeing fetched by netmon
#and provided by a small local httpd
crawl() {
	#Get system data from UCI
	if which uci >/dev/null; then
		if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
			echo "`date`: UCI is installed, trying to collect extra data from UCI" >> $SCRIPT_LOGFILE
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
		if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
			echo "`date`: LUA is installed, trying to collect extra data from LUA" >> $SCRIPT_LOGFILE
		fi
		luciname=`lua -l luci.version -e 'print(luci.version.luciname)'`
		lucversion=`lua -l luci.version -e 'print(luci.version.luciversion)'`
	fi
	
	#Get system data from other locations
	if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
		echo "`date`: Collecting basic system status data" >> $SCRIPT_LOGFILE
	fi
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

	if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
		echo "`date`: Collecting version information" >> $SCRIPT_LOGFILE
	fi
	if which batctl >/dev/null; then
		batctl_adv_version=`batctl -v | awk '{ print $2 }'`
		batman_adv_version=`batctl o -n|head -n1|awk '{ print $3 }'|sed 's/,//'`
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
	fi

	if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
		echo "`date`: Collecting information from network interfaces" >> $SCRIPT_LOGFILE
	fi
	#Get interfaces
	IFACES=`cat /proc/net/dev | awk -F: '!/\|/ { gsub(/[[:space:]]*/, "", $1); split($2, a, " "); printf("%s=%s=%s ", $1, a[1], a[9]) }'`

	interface_data=""	
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
				
				interface_data=$interface_data"<$name><name>$name</name><mac_addr>$mac_addr</mac_addr><ipv4_addr>$ipv4_addr</ipv4_addr><ipv6_addr>$ipv6_addr</ipv6_addr><ipv6_link_local_addr>$ipv6_link_local_addr</ipv6_link_local_addr><traffic_rx>$traffic_rx</traffic_rx><traffic_tx>$traffic_tx</traffic_tx><mtu>$mtu</mtu>"
				
				if [ "`iwconfig ${iface} 2>/dev/null | grep Frequency | awk '{ print $2 }' | cut -d ':' -f 2`" != "" ]; then
					wlan_mode="`iwconfig ${iface} 2>/dev/null | grep 'Mode' | awk '{ print $1 }' | cut -d ':' -f 2`"
				
					if [ $wlan_mode = "Master" ]; then	
						wlan_bssid="`iwconfig ${iface} 2>/dev/null | grep 'Access Point' | awk '{ print $6 }'`"
					elif [ $wlan_mode = "Ad-Hoc" ]; then	
						wlan_bssid="`iwconfig ${iface} 2>/dev/null | grep Cell | awk '{ print $5 }'`"
					fi
					
					wlan_essid="`iwconfig ${iface} 2>/dev/null | grep ESSID | awk '{ split($4, a, \"\\"\"); printf(\"%s\", a[2]); }'`"
					wlan_frequency="`iwconfig ${iface} 2>/dev/null | grep Frequency | awk '{ print $2 }' | cut -d ':' -f 2`"
					wlan_tx_power="`iwconfig ${iface} 2>/dev/null | grep 'Tx-Power' | awk '{ print $4 }' | cut -d ':' -f 2`"
					interface_data=$interface_data"<wlan_mode>$wlan_mode</wlan_mode><wlan_frequency>$wlan_frequency</wlan_frequency><wlan_essid>$wlan_essid</wlan_essid><wlan_bssid>$wlan_bssid</wlan_bssid><wlan_tx_power>$wlan_tx_power</wlan_tx_power>"
				fi
				interface_data=$interface_data"</$name>"
			fi
		fi
	done

	if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
		echo "`date`: Collecting information from batman advanced and it´s interfaces" >> $SCRIPT_LOGFILE
	fi
	#B.A.T.M.A.N. advanced
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

				BATMAN_ADV_INTERFACES=$BATMAN_ADV_INTERFACES"<$device_name><name>$device_name</name><status>$status</status></$device_name>"
			done
			
			if [ $has_active_interface = "1" ]; then
				BAT_ADV_ORIGINATORS=`batctl o -n | grep 'No batman nodes in range'`
				if [ "$BAT_ADV_ORIGINATORS" == "" ]; then
					OLDIFS=$IFS
					IFS="
"
					BAT_ADV_ORIGINATORS=`batctl o -n | awk '/O/ {next} /B/ {next} {print}'`
					count=0;
					for row in $BAT_ADV_ORIGINATORS; do
						originator=`echo $row | awk '{print $1}'`
						last_seen=`echo $row | awk '{print $2}'`
						last_seen="${last_seen//s/}"
						link_quality=`echo $row | awk '{print $3}'`
						link_quality="${link_quality//(/}"
						link_quality="${link_quality//)/}"
                                                outgoing_interface=`echo $row | awk '{print $6}'`
                                                outgoing_interface="${outgoing_interface//]:/}"
						nexthop=`echo $row | awk '{print $4}'`

						batman_adv_originators=$batman_adv_originators"<originator_$count><originator>$originator</originator><link_quality>$link_quality</link_quality><nexthop>$nexthop</nexthop><last_seen>$last_seen</last_seen><outgoing_interface>$outgoing_interface</outgoing_interface></originator_$count>"
						count=`expr $count + 1`
					done
					IFS=$OLDIFS
				fi
			fi
		fi
	fi

	if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
		echo "`date`: Collecting information about conected clients" >> $SCRIPT_LOGFILE
	fi
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

	if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
		echo "`date`: Putting all information into a XML-File and save it at "$SCRIPT_DATA_FILE >> $SCRIPT_LOGFILE
	fi
	SYSTEM_DATA="<status>online</status><hostname>$hostname</hostname><description>$description</description><location>$location</location><latitude>$latitude</latitude><longitude>$longitude</longitude><luciname>$luciname</luciname><luciversion>$luciversion</luciversion><distname>$distname</distname><distversion>$distversion</distversion><chipset>$chipset</chipset><cpu>$cpu</cpu><memory_total>$memory_total</memory_total><memory_caching>$memory_caching</memory_caching><memory_buffering>$memory_buffering</memory_buffering><memory_free>$memory_free</memory_free><loadavg>$loadavg</loadavg><processes>$processes</processes><uptime>$uptime</uptime><idletime>$idletime</idletime><local_time>$local_time</local_time><community_essid>$community_essid</community_essid><community_nickname>$community_nickname</community_nickname><community_email>$community_email</community_email><community_prefix>$community_prefix</community_prefix><batman_advanced_version>$batman_adv_version</batman_advanced_version><kernel_version>$kernel_version</kernel_version><nodewatcher_version>$nodewatcher_version</nodewatcher_version><firmware_version>$FIRMWARE_VERSION</firmware_version><firmware_revision>$FIRMWARE_REVISION</firmware_revision><openwrt_core_revision>$OPENWRT_CORE_REVISION</openwrt_core_revision><openwrt_feeds_packages_revision>$OPENWRT_FEEDS_PACKAGES_REVISION</openwrt_feeds_packages_revision>"

	DATA="<?xml version='1.0' standalone='yes'?><data><system_data>$SYSTEM_DATA</system_data><interface_data>$interface_data</interface_data><batman_adv_interfaces>$BATMAN_ADV_INTERFACES</batman_adv_interfaces><batman_adv_originators>$batman_adv_originators</batman_adv_originators><client_count>$client_count</client_count></data>"

	#write data to hxml file that provides the data on httpd
	echo $DATA > $SCRIPT_DATA_FILE
}

LANG=C

#Prüft ob das logfile zu groß geworden ist
if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
	echo "`date`: Check logfile" >> $SCRIPT_LOGFILE
fi
delete_log

#Erzeugt die statusdaten
if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
	echo "`date`: Generate actual status data" >> $SCRIPT_LOGFILE
fi
crawl

exit 0
