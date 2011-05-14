#!/bin/sh
# Netmon Nodewatcher (C) 2010-2011 Freifunk Oldenburg
# Lizenz: GPL

if [ -f /etc/config/nodewatcher ];then
	API_IPV4_ADRESS=`uci get nodewatcher.@api[0].ipv4_address`
	API_IPV6_ADRESS=`uci get nodewatcher.@api[0].ipv6_address`
	API_IPV6_INTERFACE=`uci get nodewatcher.@api[0].ipv6_interface`
	API_TIMEOUT=`uci get nodewatcher.@api[0].timeout`
	API_RETRY=`uci get nodewatcher.@api[0].retry`
	SCRIPT_VERSION=`uci get nodewatcher.@script[0].version`
	SCRIPT_ERROR_LEVEL=`uci get nodewatcher.@script[0].error_level`
	SCRIPT_LOGFILE=`uci get nodewatcher.@script[0].logfile`
	CRAWL_METHOD=`uci get nodewatcher.@crawl[0].method`
	CRAWL_ROUTER_ID=`uci get nodewatcher.@crawl[0].router_id`
	CRAWL_UPDATE_HASH=`uci get nodewatcher.@crawl[0].update_hash`
	CRAWL_NICKNAME=`uci get nodewatcher.@crawl[0].nickname`
	CRAWL_PASSWORD=`uci get nodewatcher.@crawl[0].password`
	UPDATE_AUTOUPDATE=`uci get nodewatcher.@update[0].autoupdate`
else
	. /etc/nodewatcher_config
fi

#Set default values if nothing is set
if [ -n $API_TIMEOUT ]; then
	API_TIMEOUT="3"
fi
if [ -n $API_RETRY ]; then
	API_RETRY="3"
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

urlencode() {
	arg="$1"
	i=0
	while [ $i -lt ${#arg} ]; do
		c=${arg:$i:1}

		if echo "$c" | grep -q '[a-zA-Z/:_\.\-]'; then
			echo -n "$c"
		else
			echo -n "%"
			printf "%X" "'$c'"
		fi
		i=$((i+1))
	done
}

convert_space() {
	arg="$1"
	echo $1 | sed "s/ /%20/g"
}

get_url() {
	if [[ $API_IPV4_ADRESS != "1" ]]; then
		url=$API_IPV4_ADRESS
	else
		url="[$API_IPV6_ADRESS"%"$API_IPV6_INTERFACE]"
	fi
	echo $url
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
	command="wget -q -O - http://$netmon_api/api_nodewatcher.php?section=version"
	ergebnis=`$command&sleep $API_TIMEOUT; kill $!`
	return=`echo $ergebnis| cut '-d;' -f1`
	version=`echo $ergebnis| cut '-d;' -f2`

	if [[ "$return" = "success" ]]; then
		if [[ $version -gt $SCRIPT_VERSION ]]; then
			if [ $error_level -gt "1" ]; then
				echo "`date`: Eine neue Version ist Verfügbar, script wird geupdated" >> $logfile
			fi
			wget -q -O $SCRIPT_DIR/nodewatcher.sh http://$netmon_api/api_nodewatcher.php?section=update
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
		
		uci set system.@system[0].hostname=`echo $ergebnis| cut '-d;' -f4`
		echo `echo $ergebnis| cut '-d;' -f4` > /proc/sys/kernel/hostname

#		uci get system.@system[0].latitude=
#		uci get system.@system[0].longitude=
#		uci get freifunk.community.ssid=
#		uci get freifunk.contact.nickname=
#		uci get freifunk.contact.mail=
#		uci get freifunk.community.prefix=
#		uci get freifunk.contact.note=

		uci commit
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
		location=`urlencode "$location"`
		latitude="`uci get system.@system[0].latitude`"
		longitude="`uci get system.@system[0].longitude`"
		
		community_essid="`uci get freifunk.community.ssid`"
		community_nickname="`uci get freifunk.contact.nickname`"
		community_email="`uci get freifunk.contact.mail`"
		community_prefix="`uci get freifunk.community.prefix`"
		description="`uci get freifunk.contact.note`"
		description=`urlencode "$description"`
	fi

	#Get system data from LUA	
	if which lua >/dev/null; then
		if [ $error_level -gt "1" ]; then
			echo "`date`: LUA is installed, trying to collect extra data LUA" >> $logfile
		fi
		luciname=`lua -l luci.version -e 'print(luci.version.luciname)'`
		luciname=`urlencode "$luciname"`
		lucversion=`lua -l luci.version -e 'print(luci.version.luciversion)'`
		lucversion=`urlencode "$lucversion"`
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
	cpu=`urlencode "$cpu"`

	chipset=`grep -m 1 "system type" /proc/cpuinfo | cut -d ":" -f 2`
	chipset=`urlencode "$chipset"`
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

	#Send system data
	command="http://$netmon_api/api_nodewatcher.php?section=insert_crawl_system_data&authentificationmethod=$authentificationmethod&nickname=$nickname&password=$password&router_auto_update_hash=$router_auto_update_hash&router_id=$router_id&status=online&hostname=$hostname&description=$description&location=$location&latitude=$latitude&longitude=$longitude&luciname=$luciname&luciversion=$luciversion&distname=$distname&distversion=$distversion&chipset=$chipset&cpu=$cpu&memory_total=$memory_total&memory_caching=$memory_caching&memory_buffering=$memory_buffering&memory_free=$memory_free&loadavg=$loadavg&processes=$processes&uptime=$uptime&idletime=$idletime&local_time=$local_time&community_essid=$community_essid&community_nickname=$community_nickname&community_email=$community_email&community_prefix=$community_prefix&batman_advanced_version=$batman_adv_version&kernel_version=$kernel_version&nodewatcher_version=$nodewatcher_version&firmware_version=$firmware_version"
	command="wget -q -O - "$command
	if [ "$1" = "debug" ]; then
		echo $command
	else
		i=0
		while [ $i -le $API_RETRY ]
		do
			return_interface=`$command&sleep $API_TIMEOUT; kill $!`

			if [ "`echo $return_interface | cut '-d;' -f1`" = "success" ]; then
				if [ $error_level -gt "1" ]; then
					echo "`date`: Das Senden der System und Batman Statusdaten war nach dem `expr $i + 1`. Mal erfolgreich" >> $logfile
				fi
				break;
			else
				if [ $error_level -gt "0" ]; then
					echo "`date`: Error! Das Senden der System und Batman Statusdaten war nach dem `expr $i + 1`. Mal nicht erfolgreich: $return_interface" >> $logfile
				fi
			fi

			i=`expr $i + 1`  #Zähler um eins erhöhen
		done
	fi

	#Get interfaces
	IFACES=`cat /proc/net/dev | awk -F: '!/\|/ { gsub(/[[:space:]]*/, "", $1); split($2, a, " "); printf("%s=%s=%s ", $1, a[1], a[9]) }'`
	
	#Loop interfaces
	for entry in $IFACES; do
		int=""
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
				
				int=$int"int[$name][name]=$name&int[$name][mac_addr]=$mac_addr&int[$name][ipv4_addr]=$ipv4_addr&int[$name][ipv6_addr]=$ipv6_addr&int[$name][ipv6_link_local_addr]=$ipv6_link_local_addr&int[$name][traffic_rx]=$traffic_rx&int[$name][traffic_tx]=$traffic_tx&int[$name][mtu]=$mtu&"
				
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
					int=$int"int[$name][wlan_mode]=$wlan_mode&int[$name][wlan_frequency]=$wlan_frequency&int[$name][wlan_essid]=$wlan_essid&int[$name][wlan_bssid]=$wlan_bssid&int[$name][wlan_tx_power]=$wlan_tx_power&"
				fi

				#Send interface status data 
				command="http://$netmon_api/api_nodewatcher.php?section=insert_crawl_interfaces_data&authentificationmethod=$authentificationmethod&nickname=$nickname&password=$password&router_auto_update_hash=$router_auto_update_hash&router_id=$router_id&$int"
				command="wget -q -O - "$command

				if [ "$1" = "debug" ]; then
					echo $command
				else
					i=0
					while [ $i -le $API_RETRY ]
					do
						return_interface=`$command&sleep $API_TIMEOUT; kill $!`
						if [ "`echo $return_interface | cut '-d;' -f1`" = "success" ]; then
							if [ $error_level -gt "1" ]; then
								echo "`date`: Das Senden der Interface Statusdaten ($name) war nach dem `expr $i + 1`. Mal erfolgreich" >> $logfile
							fi
							break;
						else
							if [ $error_level -gt "0" ]; then
								echo "`date`: Error! Das Senden der Interface Statusdaten ($name) war nach dem `expr $i + 1`. Mal nicht erfolgreich: $return_interface" >> $logfile
							fi
						fi
						i=`expr $i + 1`  #Zähler um eins erhöhen
					done
				fi
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

				command="http://$netmon_api/api_nodewatcher.php?section=insert_batman_adv_interfaces&authentificationmethod=$authentificationmethod&nickname=$nickname&password=$password&router_auto_update_hash=$router_auto_update_hash&router_id=$router_id&bat_adv_int[$device_name][name]=$device_name&bat_adv_int[$device_name][status]=$status"
				command="wget -q -O - "$command
				if [ "$1" = "debug" ]; then
					echo $command
				else
					i=0
					while [ $i -le $API_RETRY ]
					do
						return_interface="`$command&sleep $API_TIMEOUT; kill $!`"
						
						if [ "`echo $return_interface | cut '-d;' -f1`" = "success" ]; then
							if [ $error_level -gt "1" ]; then
								echo "`date`: Das Senden des Batman Advanced Interfaces ($device_name) war nach dem `expr $i + 1`. Mal erfolgreich" >> $logfile
							fi
							break;
						else
							if [ $error_level -gt "0" ]; then
								echo "`date`: Error! Das Senden des Batman Advanced Interfaces ($device_name) war nach dem `expr $i + 1`. Mal nicht erfolgreich: $return_interface" >> $logfile
							fi
						fi
						
						i=`expr $i + 1`  #Zähler um eins erhöhen
					done
				fi
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
						
						batman_adv_originators=$batman_adv_originators"bat_adv_orig[$originator][originator]=$originator&bat_adv_orig[$originator][link_quality]=$link_quality&bat_adv_orig[$originator][last_seen]=$last_seen&"
					done
					IFS=$OLDIFS

					command="wget -q -O - http://$netmon_api/api_nodewatcher.php?section=insert_batman_adv_originators&authentificationmethod=$authentificationmethod&nickname=$nickname&password=$password&router_auto_update_hash=$router_auto_update_hash&router_id=$router_id&$batman_adv_originators"
					if [ "$1" = "debug" ]; then
						echo $command
					else
						i=0
						while [ $i -le $API_RETRY ]
						do
							return_interface="`$command&sleep $API_TIMEOUT; kill $!`"
				
							if [ "`echo $return_interface | cut '-d;' -f1`" = "success" ]; then
								if [ $error_level -gt "1" ]; then
									echo "`date`: Das Senden der Batman Advaned Originator Daten war nach dem `expr $i + 1`. Mal erfolgreich" >> $logfile
								fi
								break;
							else
								if [ $error_level -gt "0" ]; then
									echo "`date`: Error! Das Senden der Batman Advaned Originator Daten war nach dem `expr $i + 1`. Mal nicht erfolgreich: $return_interface" >> $logfile
								fi
							fi
				
							i=`expr $i + 1`  #Zähler um eins erhöhen
						done
					fi
				fi
			fi
		fi
	fi
	mv /etc/bat-hosts.tmp /etc/bat-hosts

	#CLIENTS
	MESHDEVICE='br-mesh'
	CLIENTDEVICE='ath0'
	SEDDEV=`brctl showstp $MESHDEVICE | egrep '\([0-9]\)' | sed -e "s/(//;s/)//" | awk '{ print "s/^  "$2"/"$1"/;" }'`
	CLIENT_MACS=`brctl showmacs $MESHDEVICE | sed -e "$SEDDEV" | awk '{if ($3 != "yes" && $1 == "ath0") print $2}'`
	i=0
	for client in $CLIENT_MACS; do
#		clients=$clients"clients[$i][mac_addr]=$client&"
		i=`expr $i + 1`  #Zähler um eins erhöhen
	done
	client_count=$i

	command="wget -q -O - http://$netmon_api/api_nodewatcher.php?section=insert_clients&authentificationmethod=$authentificationmethod&nickname=$nickname&password=$password&router_auto_update_hash=$router_auto_update_hash&router_id=$router_id&client_count=$client_count"
	if [ "$1" = "debug" ]; then
		echo $command
		else
		i=0
		while [ $i -le $API_RETRY ]
		do
			return_interface="`$command&sleep $API_TIMEOUT; kill $!`"
			if [ "`echo $return_interface | cut '-d;' -f1`" = "success" ]; then
				if [ $error_level -gt "1" ]; then
					echo "`date`: Das Senden der Client Daten war nach dem `expr $i + 1`. Mal erfolgreich" >> $logfile
				fi
				break;
			else
				if [ $error_level -gt "0" ]; then
					echo "`date`: Error! Das Senden der Client Daten war nach dem `expr $i + 1`. Mal nicht erfolgreich: $return_interface" >> $logfile
				fi
			fi
			i=`expr $i + 1`  #Zähler um eins erhöhen
		done
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