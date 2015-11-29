#!/bin/sh
# Netmon Configurator (C) 2010-2012 Freifunk Oldenburg
# Lizenz: GPL v3

test -f /tmp/started || exit

#Get the configuration from the uci configuration file
#If it does not exists, then get it from a normal bash file with variables.
if [ -f /etc/config/configurator ];then
	API_IPV4_ADRESS=`uci get configurator.@api[0].ipv4_address`
	API_IPV6_ADRESS=`uci get configurator.@api[0].ipv6_address`
	API_IPV6_INTERFACE=`uci get configurator.@api[0].ipv6_interface`
	API_TIMEOUT=`uci get configurator.@api[0].timeout`
	SCRIPT_ERROR_LEVEL=`uci get configurator.@script[0].error_level`
	SCRIPT_LOGFILE=`uci get configurator.@script[0].logfile`
	SCRIPT_SYNC_HOSTNAME=`uci get configurator.@script[0].sync_hostname`
	CRAWL_METHOD=`uci get configurator.@crawl[0].method`
	CRAWL_ROUTER_ID=`uci get configurator.@crawl[0].router_id`
	CRAWL_UPDATE_HASH=`uci get configurator.@crawl[0].update_hash`
	CRAWL_NICKNAME=`uci get configurator.@crawl[0].nickname`
	CRAWL_PASSWORD=`uci get configurator.@crawl[0].password`
else
	. `dirname $0`/configurator_config
fi

if [ "$API_IPV4_ADRESS" != "1" ]; then
	netmon_api=$API_IPV4_ADRESS
else
	netmon_api="[$API_IPV6_ADRESS"%"$API_IPV6_INTERFACE]"
fi

if [ "$SCRIPT_ERROR_LEVEL" -gt "1" ]; then
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
	ret=${api_return%%,*}
	if [ "$ret" != "success" ]; then
		err "Ther was an error fetching the hostname"
		exit 0
	elif [ "$ret" = "success" ]; then
		netmon_hostname=${api_return%,*}
		netmon_hostname=${netmon_hostname#*,}
		
		#check for valid hostname as specified in rfc 1123
		#see http://stackoverflow.com/a/3824105
		regex='^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])'
		regex=$regex'(\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]))*$'
		if [ "${#netmon_hostname}" -le "255" ]; then
			if echo -n $netmon_hostname | egrep -q "$regex"; then
				if [ "$netmon_hostname" != "`cat /proc/sys/kernel/hostname`" ]; then
					err "Setting new hostname: $netmon_hostname"
					uci set system.@system[0].hostname=$netmon_hostname
					uci commit
					echo $netmon_hostname > /proc/sys/kernel/hostname
				else
					err "Hostname is up to date"
				fi
			else
				err "Hostname ist malformed"
				exit 0
			fi
		else
			err "Hostname exceeds the maximum length of 255 characters"
			exit 0
		fi
	fi
}

if [ "$SCRIPT_SYNC_HOSTNAME" = "1" ]; then
	sync_hostname
fi
