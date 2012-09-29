#!/bin/sh
# This script needs to be enabled within the rc.local with:
# iw event -f | /etc/clients_event.sh &

API_IPV4_ADRESS=`uci get configurator.@api[0].ipv4_address`
API_IPV6_ADRESS=`uci get configurator.@api[0].ipv6_address`
API_IPV6_INTERFACE=`uci get configurator.@api[0].ipv6_interface`
CRAWL_ROUTER_ID=`uci get configurator.@crawl[0].router_id`

get_url() {
	if [[ $API_IPV4_ADRESS != "1" ]]; then
		url=$API_IPV4_ADRESS
	else
		url="[$API_IPV6_ADRESS"%"$API_IPV6_INTERFACE]"
	fi
	echo $url
}

netmon_api=`get_url`								

while read LINE
do
	if [ "`echo $LINE | grep 'wlan0: new station'`" != "" ]; then
		mac_addr="`echo $LINE | grep 'wlan0: new station' | cut -d' ' -f4`"

		command="wget -q -O - http://$netmon_api/api_csv_variable_splash.php?section=insert_client&router_id=$CRAWL_ROUTER_ID&mac_addr=$mac_addr"
		api_return=`$command` 
		echo "$api_return"
        fi
done


