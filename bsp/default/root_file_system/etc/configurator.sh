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

if [[ $API_IPV4_ADRESS != "1" ]]; then
    netmon_api=$API_IPV4_ADRESS
else
    netmon_api="[$API_IPV6_ADRESS"%"$API_IPV6_INTERFACE]"
fi

if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
    err() {
        echo "$(date) [configurator]: $1" >> $SCRIPT_LOGFILE
    }
else
    err() {
        :
    }
fi

sync_hostname() {
	err "Syncing hostname"
    api_return=$(wget -T $API_TIMEOUT -q -O - "http://$netmon_api/api_csv_configurator.php?section=get_hostname&authentificationmethod=$CRAWL_METHOD&nickname=$CRAWL_NICKNAME&password=$CRAWL_PASSWORD&router_auto_update_hash=$CRAWL_UPDATE_HASH&router_id=$CRAWL_ROUTER_ID")
	netmon_hostname=${api_return%,*}
	netmon_hostname=${netmon_hostname#*,}
	if [ "$netmon_hostname" != "" ]; then
		if [ "$netmon_hostname" != "`cat /proc/sys/kernel/hostname`" ]; then
			err "Setting new hostname: $netmon_hostname"
			uci set system.@system[0].hostname=$netmon_hostname
			uci commit
			echo $netmon_hostname > /proc/sys/kernel/hostname
		else
		    err "Hostname is up to date"
		fi
	fi
}

assign_router() {
	hostname=`cat /proc/sys/kernel/hostname`
	
	#Choose right login String
    #Here maybe a ; to much at the end..??
    login_strings=$(awk '{ mac=toupper($1); gsub(":", "", mac); printf mac ";" }' /sys/class/net/br-mesh/address /sys/class/net/eth0/address /sys/class/net/ath0/address 2> /dev/null)
    ergebnis=$(wget -T $API_TIMEOUT -q -O - "http://$netmon_api/api_csv_configurator.php?section=test_login_strings&login_strings=$login_strings")
    router_auto_assign_login_string=${ergebnis#*;}
    ergebnis=${ergebnis%;*}
	if [ "$ergebnis" = "error" ]; then
		router_auto_assign_login_string=${login_strings%%;*}
        err "A router with this login string does not exist: $login_strings"
        err "Using $router_auto_assign_login_string as login string"
	fi

	#Try to assign Router with choosen login string
    ergebnis=$(wget -T $API_TIMEOUT -q -O - "http://$netmon_api/api_csv_configurator.php?section=router_auto_assign&router_auto_assign_login_string=$router_auto_assign_login_string&hostname=$hostname")
    ret=${ergebnis%%;*}
    errstr=${ergebnis#*;}
    errstr=${errstr%%;*}
	if [ "$ret" != "success" ]; then
        err "The router has not been assigned to a router in Netmon"
        err "Failure on router_auto_assign: $errstr. Exiting"
        exit 0
	elif [ "$ret" = "success" ]; then
        update_hash=${ergebnis%;*;*}
        update_hash=${update_hash##*;}
        api_key=${ergebnis##*;}
		#write new config
		uci set configurator.@crawl[0].router_id=$errstr
		uci set configurator.@crawl[0].update_hash=$update_hash
		uci set configurator.@api[0].api_key=$api_key
		#set also new router id for nodewatcher
		#uci set nodewatcher.@crawl[0].router_id=$errstr

        err "The router $errstr has been assigned with a router in Netmon"
		uci commit

		CRAWL_METHOD=`uci get configurator.@crawl[0].method`
		CRAWL_ROUTER_ID=$errstr
		CRAWL_UPDATE_HASH=$update_hash
		CRAWL_NICKNAME=`uci get configurator.@crawl[0].nickname`
		CRAWL_PASSWORD=`uci get configurator.@crawl[0].password`
	fi
}

autoadd_ipv6_address() {
	err "Doing IPv6 autoadd"
    ipv6_link_local_addr=$(ip addr show dev br-mesh scope link | awk '/inet6/{print $2}')
    ipv6_link_local_netmask=${ipv6_link_local_addr##*/}
    ipv6_link_local_addr=${ipv6_link_local_addr%%/*}
    ergebnis=$(wget -T $API_TIMEOUT -q -O - "http://$netmon_api/api_csv_configurator.php?section=autoadd_ipv6_address&authentificationmethod=$CRAWL_METHOD&nickname=$CRAWL_NICKNAME&password=$CRAWL_PASSWORD&router_auto_update_hash=$CRAWL_UPDATE_HASH&router_id=$CRAWL_ROUTER_ID&ip=$ipv6_link_local_addr&netmask=$ipv6_link_local_netmask")
    ret=${ergebnis%%,*}
	if [ "$ret" = "success" ]; then
		uci set configurator.@netmon[0].autoadd_ipv6_address='0'
		uci commit
		err "The IPv6 address of the router $CRAWL_ROUTER_ID has been added to the router in Netmon"
		err "IPv6 Autoadd has been disabled cause it is no longer necesarry"
	else
        routerid=${ergebnis##*,}
		if [ "$routerid" == "$CRAWL_ROUTER_ID" ]; then
			err "The IPv6 address already exists in Netmon on this router. Maybe because of a previos assignment"
			uci set configurator.@netmon[0].autoadd_ipv6_address='0'
			uci commit
			err "IPv6 Autoadd has been disabled cause it is no longer necesarry"
		else 
			err "The IPv6 address already exists in Netmon on another router $routerid"
		fi
	fi
}

if [ $CRAWL_METHOD == "login" ]; then
    err "Authentification method is: username and passwort"
elif [ $CRAWL_METHOD == "hash" ]; then
    err "Authentification method: autoassign and hash"
    err "Checking if the router is already assigned to a router in Netmon"
	if [ $CRAWL_UPDATE_HASH == "1" ]; then
        err "The router is not assigned to a router in Netmon"
        err "Trying to assign the router"
		assign_router
        if [[ $AUTOADD_IPV6_ADDRESS = "1" ]]; then
            autoadd_ipv6_address
        fi
	else
        err "The router is already assigned to a router in Netmon"
                if [[ $AUTOADD_IPV6_ADDRESS = "1" ]]; then                                                 
                	autoadd_ipv6_address                                                                   
       		fi                                                                                         
                                    
	fi
fi

if [[ $SCRIPT_SYNC_HOSTNAME = "1" ]]; then
    sync_hostname
fi

