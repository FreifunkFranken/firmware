#!/bin/sh
# Netmon Configurator (C) 2010-2012 Freifunk Oldenburg
# Lizenz: GPL v3

#Get the configuration from the uci configuration file
#If it does not exists, then get it from a normal bash file with variables.
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
	AUTOADD_IPV6_ADDRESS=`uci get configurator.@netmon[0].autoadd_ipv6_address`
else
	. `dirname $0`/configurator_config
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
				echo "`date`: Setting new hostname: $netmon_hostname" >> $SCRIPT_LOGFILE
			fi
			uci set system.@system[0].hostname=$netmon_hostname
			uci commit
			echo $netmon_hostname > /proc/sys/kernel/hostname
		else
			if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
				echo "`date`: Hostname is up to date" >> $SCRIPT_LOGFILE
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
			echo "`date`: There alredy exists a router with this login string: $router_auto_assign_login_string" >> $SCRIPT_LOGFILE
		fi
	elif [ `echo $ergebnis| cut '-d;' -f1` = "error" ]; then
		router_auto_assign_login_string=`echo $login_strings| cut '-d;' -f1`
		if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
			echo "`date`: A router with this login string does not exist: $login_strings" >> $SCRIPT_LOGFILE
			echo "`date`: Using $router_auto_assign_login_string as login string" >> $SCRIPT_LOGFILE
		fi
	fi

	#Try to assign Router with choosen login string
	command="wget -q -O - http://$netmon_api/api_csv_configurator.php?section=router_auto_assign&router_auto_assign_login_string=$router_auto_assign_login_string&hostname=$hostname"
	ergebnis=`$command&sleep $API_TIMEOUT; kill $!`
	if [ `echo $ergebnis| cut '-d;' -f1` != "success" ]; then
		if [ `echo $ergebnis| cut '-d;' -f2` = "already_assigned" ]; then
			if [ $SCRIPT_ERROR_LEVEL -gt "0" ]; then
				echo "`date`: The login string `echo $ergebnis| cut '-d;' -f3` is already assigned to a router. Exiting" >> $SCRIPT_LOGFILE
				exit 0
			fi
		elif [ `echo $ergebnis| cut '-d;' -f2` = "autoassign_not_allowed" ]; then
			if [ $SCRIPT_ERROR_LEVEL -gt "0" ]; then
				echo "`date`: The router with the login string `echo $ergebnis| cut '-d;' -f3` does not allow autoassign. Exiting" >> $SCRIPT_LOGFILE
				exit 0
			fi
		elif [ `echo $ergebnis| cut '-d;' -f2` = "new_not_assigned" ]; then
			if [ $SCRIPT_ERROR_LEVEL -gt "0" ]; then
				echo "`date`: Router has been added to the list of not assigned routers. Exiting" >> $SCRIPT_LOGFILE
				exit 0
			fi
		elif [ `echo $ergebnis| cut '-d;' -f2` = "updated_not_assigned" ]; then
			if [ $SCRIPT_ERROR_LEVEL -gt "0" ]; then
				echo "`date`: The list of not assigned routers has been updated. Exiting" >> $SCRIPT_LOGFILE
				exit 0
			fi
		fi
		if [ $SCRIPT_ERROR_LEVEL -gt "0" ]; then
			echo "`date`: The router has not been assigned to a router in Netmon" >> $SCRIPT_LOGFILE
		fi
	elif [ `echo $ergebnis| cut '-d;' -f1` = "success" ]; then
		#write new config
		uci set configurator.@crawl[0].router_id=`echo $ergebnis| cut '-d;' -f2`
		uci set configurator.@crawl[0].update_hash=`echo $ergebnis| cut '-d;' -f3`

		#set also new router id for nodewatcher
		uci set nodewatcher.@crawl[0].router_id=`echo $ergebnis| cut '-d;' -f2`

		if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
			echo "`date`: The router `echo $ergebnis| cut '-d;' -f2` has been assigned with a router in Netmon" >> $SCRIPT_LOGFILE
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
	netmon_api=`get_url`
	echo "`date`: Doing IPv6 autoadd" >> $SCRIPT_LOGFILE
	ipv6_link_local_addr="`ifconfig br-mesh | grep 'inet6 addr:' | grep 'Scope:Link' | awk '{ print $3}'`"
	command="wget -q -O - http://$netmon_api/api_csv_configurator.php?section=autoadd_ipv6_address&authentificationmethod=$CRAWL_METHOD&nickname=$CRAWL_NICKNAME&password=$CRAWL_PASSWORD&router_auto_update_hash=$CRAWL_UPDATE_HASH&router_id=$CRAWL_ROUTER_ID&ip=$ipv6_link_local_addr"
	ergebnis=`$command&sleep $API_TIMEOUT; kill $!`
	if [ `echo $ergebnis| cut '-d,' -f1` = "success" ]; then
		uci set configurator.@netmon[0].autoadd_ipv6_address='0'
		uci commit
		echo "`date`: The IPv6 address of the router $CRAWL_ROUTER_ID has been added to the router in Netmon" >> $SCRIPT_LOGFILE
		echo "`date`: IPv6 Autoadd has been disabled cause it is no longer necesarry" >> $SCRIPT_LOGFILE
	else
		if [ `echo $ergebnis| cut '-d,' -f3` == "$CRAWL_ROUTER_ID" ]; then
			echo "`date`: The IPv6 address already exists in Netmon on this router. Maybe because of a previos assignment" >> $SCRIPT_LOGFILE
			uci set configurator.@netmon[0].autoadd_ipv6_address='0'
			uci commit
			echo "`date`: IPv6 Autoadd has been disabled cause it is no longer necesarry" >> $SCRIPT_LOGFILE
		else 
			echo "`date`: The IPv6 address already exists in Netmon on another router `echo $ergebnis| cut '-d,' -f3`" >> $SCRIPT_LOGFILE
		fi
	fi
}

if [ $CRAWL_METHOD == "login" ]; then
	if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then  
		echo "`date`: Authentification method is: username and passwort" >> $SCRIPT_LOGFILE
	fi
elif [ $CRAWL_METHOD == "hash" ]; then
	if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
		echo "`date`: Authentification method: autoassign and hash" >> $SCRIPT_LOGFILE
		echo "`date`: Checking if the router is already assigned to a router in Netmon" >> $SCRIPT_LOGFILE
	fi
	if [ $CRAWL_UPDATE_HASH == "1" ]; then
		can_crawl=0
		if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
			echo "`date`: The router is not assigned to a router in Netmon" >> $SCRIPT_LOGFILE
			echo "`date`: Trying to assign the router" >> $SCRIPT_LOGFILE
		fi
		assign_router
		sync_hostname
	else
		if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
			echo "`date`: The router is alredy assigned to a router in Netmon" >> $SCRIPT_LOGFILE
		fi
               	if [[ $AUTOADD_IPV6_ADDRESS = "1" ]]; then
       			autoadd_ipv6_address
              	fi
	fi
fi


tmp=${1-text}
if [[ $tmp = "sync_hostname" ]]; then
	#Sync Hostname
	if [[ $SCRIPT_SYNC_HOSTNAME = "1" ]]; then
		sync_hostname
	fi
fi
