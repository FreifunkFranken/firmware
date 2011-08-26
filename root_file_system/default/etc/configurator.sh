#!/bin/sh
# Netmon Configurator (C) 2010-2011 Freifunk Oldenburg
# Lizenz: GPL

Put 

SCRIPT_DIR=`dirname $0`

if [ -f /etc/config/configurator ];then
	API_IPV4_ADRESS=`uci get configurator.@api[0].ipv4_address`
	API_IPV6_ADRESS=`uci get configurator.@api[0].ipv6_address`
	API_IPV6_INTERFACE=`uci get configurator.@api[0].ipv6_interface`
	API_TIMEOUT=`uci get configurator.@api[0].timeout`
	API_RETRY=`uci get configurator.@api[0].retry`
	SCRIPT_VERSION=`uci get configurator.@script[0].version`
	SCRIPT_ERROR_LEVEL=`uci get configurator.@script[0].error_level`
	SCRIPT_LOGFILE=`uci get configurator.@script[0].logfile`
	SCRIPT_SYNC_HOSTNAME=`uci get configurator.@script[0].sync_hostname`
	CRAWL_METHOD=`uci get configurator.@crawl[0].method`
	CRAWL_ROUTER_ID=`uci get configurator.@crawl[0].router_id`
	CRAWL_UPDATE_HASH=`uci get configurator.@crawl[0].update_hash`
	CRAWL_NICKNAME=`uci get configurator.@crawl[0].nickname`
	CRAWL_PASSWORD=`uci get configurator.@crawl[0].password`
	UPDATE_AUTOUPDATE=`uci get configurator.@update[0].autoupdate`
	MESH_INTERFACE=`uci get configurator.@network[0].mesh_interface`
	CLIENT_INTERFACES=`uci get configurator.@network[0].client_interfaces`
	AUTOADD_IPV6_ADDRESS=`uci get configurator.@netmon[0].autoadd_ipv6_address`
else
	. $SCRIPT_DIR/configurator_config
fi

API_RETRY=$(($API_RETRY - 1))

get_url() {
	if [[ $API_IPV4_ADRESS != "1" ]]; then
		url=$API_IPV4_ADRESS
	else
		url="[$API_IPV6_ADRESS"%"$API_IPV6_INTERFACE]"
	fi
	echo $url
}

sync_hostname() {
	if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
		echo "`date`: Syncing hostname" >> $SCRIPT_LOGFILE
	fi
	netmon_api=`get_url`
	command="wget -q -O - http://$netmon_api/api_csv_configurator.php?section=get_hostname&authentificationmethod=$CRAWL_METHOD&nickname=$CRAWL_NICKNAME&password=$CRAWL_PASSWORD&router_auto_update_hash=$CRAWL_UPDATE_HASH&router_id=$CRAWL_ROUTER_ID"
	api_return=`$command&sleep $API_TIMEOUT; kill $!`
	netmon_hostname=`echo $api_return| cut '-d,' -f2`
	if [ "$netmon_hostname" != "" ]; then
		if [ "$netmon_hostname" != "`cat /proc/sys/kernel/hostname`" ]; then
			if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
				echo "`date`: Setze neuen Hostname: $netmon_hostname" >> $SCRIPT_LOGFILE
			fi
			uci set system.@system[0].hostname=$netmon_hostname
			uci commit
			echo $netmon_hostname > /proc/sys/kernel/hostname
		else
			if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
				echo "`date`: Hostname ist aktuell" >> $SCRIPT_LOGFILE
			fi
		fi
	fi
}

assign_router() {
	netmon_api=`get_url`
	hostname=`cat /proc/sys/kernel/hostname`
	
	#Choose right login String
	login_strings="$(ifconfig br-mesh | grep HWaddr | awk '{ print $5 }'|sed -e 's/://g');$(ifconfig eth0 | grep HWaddr | awk '{ print $5 }'|sed -e 's/://g');$(ifconfig ath0 | grep HWaddr | awk '{ print $5 }'|sed -e 's/://g')"
	command="wget -q -O - http://$netmon_api/api_csv_configurator.php?section=test_login_strings&login_strings=$login_strings"
	ergebnis=`$command&sleep $API_TIMEOUT; kill $!`
	if [ `echo $ergebnis| cut '-d;' -f1` = "success" ]; then
		router_auto_assign_login_string=`echo $ergebnis| cut '-d;' -f2`
		if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
			echo "`date`: Es existiert ein Router mit dem Login String $router_auto_assign_login_string" >> $SCRIPT_LOGFILE
		fi
	elif [ `echo $ergebnis| cut '-d;' -f1` = "error" ]; then
		router_auto_assign_login_string=`echo $login_strings| cut '-d;' -f1`
		if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
			echo "`date`: Es existiert kein Router mit einem der Login Strings: $login_strings" >> $SCRIPT_LOGFILE
			echo "`date`: Nutze $router_auto_assign_login_string als login string" >> $SCRIPT_LOGFILE
		fi
	fi

	#Try to assign Router with choosen login string
	command="wget -q -O - http://$netmon_api/api_csv_configurator.php?section=router_auto_assign&router_auto_assign_login_string=$router_auto_assign_login_string&hostname=$hostname"
	ergebnis=`$command&sleep $API_TIMEOUT; kill $!`
	if [ `echo $ergebnis| cut '-d;' -f1` != "success" ]; then
		if [ `echo $ergebnis| cut '-d;' -f2` = "already_assigned" ]; then
			if [ $SCRIPT_ERROR_LEVEL -gt "0" ]; then
				echo "`date`: Der Login String `echo $ergebnis| cut '-d;' -f3` ist bereits mit einem Router verknüpft, beende" >> $SCRIPT_LOGFILE
				exit 0
			fi
		elif [ `echo $ergebnis| cut '-d;' -f2` = "autoassign_not_allowed" ]; then
			if [ $SCRIPT_ERROR_LEVEL -gt "0" ]; then
				echo "`date`: Der dem Login String `echo $ergebnis| cut '-d;' -f3` zugewiesene Router erlaubt autoassign nicht, beende" >> $SCRIPT_LOGFILE
				exit 0
			fi
		elif [ `echo $ergebnis| cut '-d;' -f2` = "new_not_assigned" ]; then
			if [ $SCRIPT_ERROR_LEVEL -gt "0" ]; then
				echo "`date`: Router wurde der Liste der nicht zugewiesenen Router hinzugefügt, beende" >> $SCRIPT_LOGFILE
				exit 0
			fi
		elif [ `echo $ergebnis| cut '-d;' -f2` = "updated_not_assigned" ]; then
			if [ $SCRIPT_ERROR_LEVEL -gt "0" ]; then
				echo "`date`: Router auf der Liste der nicht zugewiesenen Router wurde geupdated, beende" >> $SCRIPT_LOGFILE
				exit 0
			fi
		fi
		if [ $SCRIPT_ERROR_LEVEL -gt "0" ]; then
			echo "`date`: Der Router wurde nicht mit Netmon verknüpft" >> $SCRIPT_LOGFILE
		fi
	elif [ `echo $ergebnis| cut '-d;' -f1` = "success" ]; then
		#write new config
		uci set configurator.@crawl[0].router_id=`echo $ergebnis| cut '-d;' -f2`
		uci set configurator.@crawl[0].update_hash=`echo $ergebnis| cut '-d;' -f3`
		if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
			echo "`date`: Der Router wurde mit Netmon verknüpft" >> $SCRIPT_LOGFILE
		fi
		uci commit

		CRAWL_METHOD=`uci get configurator.@crawl[0].method`
		CRAWL_ROUTER_ID=`uci get configurator.@crawl[0].router_id`
		CRAWL_UPDATE_HASH=`uci get configurator.@crawl[0].update_hash`
		CRAWL_NICKNAME=`uci get configurator.@crawl[0].nickname`
		CRAWL_PASSWORD=`uci get configurator.@crawl[0].password`
	fi
}

autoadd_ipv6_address() {
	echo "`date`: Führe IPv6 Address autoadd durch" >> $SCRIPT_LOGFILE
	ipv6_link_local_addr="`ifconfig br-mesh | grep 'inet6 addr:' | grep 'Scope:Link' | awk '{ print $3}'`"
	command="wget -q -O - http://$netmon_api/api_csv_configurator.php?section=autoadd_ipv6_address&&authentificationmethod=$CRAWL_METHOD&nickname=$CRAWL_NICKNAME&password=$CRAWL_PASSWORD&router_auto_update_hash=$CRAWL_UPDATE_HASH&router_id=$CRAWL_ROUTER_ID&ip=$ipv6_link_local_addr"
	ergebnis=`$command&sleep $API_TIMEOUT; kill $!`
	if [ `echo $ergebnis| cut '-d,' -f1` = "success" ]; then
		uci set configurator.@netmon[0].autoadd_ipv6_address='0'
		uci commit
		echo "`date`: Die IPv6-Adresse wurde Netmon hinzugefügt" >> $SCRIPT_LOGFILE
		echo "`date`: IPv6 Autoadd wurde abgestellt um zu starke Belastung der Netmon API zu vermeiden" >> $SCRIPT_LOGFILE
	else
		echo "`date`: Die IPv6-Adresse existiert bereits in Netmon (auf Router-ID `echo $ergebnis| cut '-d,' -f3`)" >> $SCRIPT_LOGFILE
	fi
}

if [ $CRAWL_METHOD == "login" ]; then
	if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then  
		echo "`date`: Authentifizierungsmethode ist: Username und Passwort" >> $SCRIPT_LOGFILE
	fi
elif [ $CRAWL_METHOD == "hash" ]; then
	if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
		echo "`date`: Authentifizierungsmethode ist: Autoassign und Hash" >> $SCRIPT_LOGFILE
		echo "`date`: Prüfe ob Roter schon mit Netmon verknüpft ist" >> $SCRIPT_LOGFILE
	fi
	if [ $CRAWL_UPDATE_HASH == "1" ]; then
		can_crawl=0
		if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
			echo "`date`: Der Router ist noch NICHT mit Netmon verknüpft" >> $SCRIPT_LOGFILE
			echo "`date`: Versuche verknüpfung herzustellen" >> $SCRIPT_LOGFILE
		fi
		assign_router
		sync_hostname
	else
		if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
			echo "`date`: Der Router ist bereits mit Netmon verknüpft" >> $SCRIPT_LOGFILE
		fi
	fi
fi

if [[ $AUTOADD_IPV6_ADDRESS = "1" ]]; then
	autoadd_ipv6_address
fi

tmp=${1-text}
if [[ $tmp = "sync_hostname" ]]; then
	#Sync Hostname
	if [[ $SCRIPT_SYNC_HOSTNAME = "1" ]]; then
		sync_hostname
	fi
fi