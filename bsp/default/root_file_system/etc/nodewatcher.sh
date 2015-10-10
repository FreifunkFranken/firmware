#!/bin/sh
# Netmon Nodewatcher (C) 2010-2012 Freifunk Oldenburg
# License; GPL v3

SCRIPT_VERSION="31"

test -f /tmp/started || exit

#Get the configuration from the uci configuration file
#If it does not exists, then get it from a normal bash file with variables.
if [ -f /etc/config/nodewatcher ];then
	SCRIPT_ERROR_LEVEL=`uci get nodewatcher.@script[0].error_level`
	SCRIPT_LOGFILE=`uci get nodewatcher.@script[0].logfile`
	SCRIPT_DATA_FILE=`uci get nodewatcher.@script[0].data_file`
	MESH_INTERFACE=`uci get nodewatcher.@network[0].mesh_interface`
	CLIENT_INTERFACES=`uci get nodewatcher.@network[0].client_interfaces`
	IFACEBLACKLIST=`uci get nodewatcher.@network[0].iface_blacklist`
else
	. `dirname $0`/nodewatcher_config
fi

if [ $SCRIPT_ERROR_LEVEL -gt "1" ]; then
    err() {
        echo $1 >> $SCRIPT_LOGFILE
    }
else
    err() {
        :
    }
fi

#this method checks id the logfile has bekome too big and deletes the first X lines
delete_log() {
	if [ -f $SCRIPT_LOGFILE ]; then
		if [ `ls -la $SCRIPT_LOGFILE | awk '{ print $5 }'` -gt "6000" ]; then
			sed -i '1,60d' $SCRIPT_LOGFILE
            err "`date`: Logfile has been made smaller"
		fi
	fi
}

inArray() {
	local value
	for value in $1; do
		if [ "$value" = "$2" ]; then
			return 0
		fi
	done
	return 1
}

#this method generates the crawl data xml file that is beeing fetched by netmon
#and provided by a small local httpd
crawl() {
	#Get system data from other locations
    err "`date`: Collecting basic system status data"
    hostname="$(cat /proc/sys/kernel/hostname)"
	uptime=$(awk '{ printf "<uptime>"$1"</uptime><idletime>"$2"</idletime>" }' /proc/uptime)
	
    memory=$(awk '
        /^MemTotal/ { printf "<memory_total>"$2"</memory_total>" }
        /^Cached:/ { printf "<memory_caching>"$2"</memory_caching>" }
        /^Buffers/ { printf "<memory_buffering>"$2"</memory_buffering>" }
        /^MemFree/ { printf "<memory_free>"$2"</memory_free>" }
    ' /proc/meminfo)
	cpu=$(awk -F': ' '
        /model/ { printf "<cpu>"$2"</cpu>" }
        /system type/ { printf "<chipset>"$2"</chipset>" }
    ' /proc/cpuinfo)
	model="<model>$(uci get board.model.name)</model>"
	local_time="`date +%s`"
	load=$(awk '{ printf "<loadavg>"$3"</loadavg><processes>"$4"</processes>" }' /proc/loadavg)

    err "`date`: Collecting version information"
	
    batman_adv_version=$(cat /sys/module/batman_adv/version)
	kernel_version=$(uname -r)
	fastd_version=$(fastd -v | awk '{ print $2 }')
	nodewatcher_version=$SCRIPT_VERSION

    # example for /etc/openwrt_release:
    #DISTRIB_ID="OpenWrt"
    #DISTRIB_RELEASE="Attitude Adjustment"
    #DISTRIB_REVISION="r35298"
    #DISTRIB_CODENAME="attitude_adjustment"
    #DISTRIB_TARGET="atheros/generic"
    #DISTRIB_DESCRIPTION="OpenWrt Attitude Adjustment 12.09-rc1"
	. /etc/openwrt_release
    distname=$DISTRIB_ID
    distversion=$DISTRIB_RELEASE

    # example for /etc/firmware_release:
    #FIRMWARE_VERSION="95f36685e7b6cbf423f02cf5c7f1e785fd4ccdae-dirty"
    #BUILD_DATE="build date: Di 29. Jan 19:33:34 CET 2013"
    #OPENWRT_CORE_REVISION="35298"
    #OPENWRT_FEEDS_PACKAGES_REVISION="35298"
	. /etc/firmware_release
	SYSTEM_DATA="<status>online</status><hostname>$hostname</hostname><distname>$distname</distname><distversion>$distversion</distversion>$cpu$model$memory$load$uptime<local_time>$local_time</local_time><batman_advanced_version>$batman_adv_version</batman_advanced_version><kernel_version>$kernel_version</kernel_version><fastd_version>$fastd_version</fastd_version><nodewatcher_version>$nodewatcher_version</nodewatcher_version><firmware_version>$FIRMWARE_VERSION</firmware_version><firmware_revision>$BUILD_DATE</firmware_revision><openwrt_core_revision>$OPENWRT_CORE_REVISION</openwrt_core_revision><openwrt_feeds_packages_revision>$OPENWRT_FEEDS_PACKAGES_REVISION</openwrt_feeds_packages_revision>"

    err "`date`: Collecting information from network interfaces"

	#Get interfaces
	#IFACES=`cat /proc/net/dev | awk -F: '!/\|/ { gsub(/[[:space:]]*/, "", $1); split($2, a, " "); printf("%s=%s=%s ", $1, a[1], a[9]) }'`

	interface_data=""	
	#Loop interfaces
	#for entry in $IFACES; do
    for filename in `grep 'up\|unknown' /sys/class/net/*/operstate`; do
        ifpath=${filename%/operstate*}
        iface=${ifpath#/sys/class/net/}
        if inArray "$IFACEBLACKLIST" "$iface"; then
            continue
        fi
		
        #Get interface data
        addrs="$(ip addr show dev ${iface} | awk '
            /ether/ { printf "<mac_addr>"$2"</mac_addr>" }
            /inet / { split($2, a, "/"); printf "<ipv4_addr>"a[1]"</ipv4_addr>" }
            /inet6/ && /scope global/ { printf "<ipv6_addr>"$2"</ipv6_addr>" }
            /inet6/ && /scope link/ { printf "<ipv6_link_local_addr>"$2"</ipv6_link_local_addr>"}
            /mtu/ { printf "<mtu>"$5"</mtu>" }
        ')"
        #mac_addr="`cat $ifpath/address`"
        #ipv4_addr="`ip addr show dev ${iface} | awk '/inet / { split($2, a, "/"); print a[1] }'`"
        #ipv6_addr="`ip addr show dev ${iface} scope global | awk '/inet6/ { print $2 }'`"
        #ipv6_link_local_addr="`ip addr show dev ${iface} scope link | awk '/inet6/ { print $2 }'`"
        #mtu=`cat $ifpath/mtu`
        traffic_rx=`cat $ifpath/statistics/rx_bytes`
        traffic_tx=`cat $ifpath/statistics/tx_bytes`
        
        #interface_data=$interface_data"<$iface><name>$iface</name><mac_addr>$mac_addr</mac_addr><ipv4_addr>$ipv4_addr</ipv4_addr><ipv6_addr>$ipv6_addr</ipv6_addr><ipv6_link_local_addr>$ipv6_link_local_addr</ipv6_link_local_addr><traffic_rx>$traffic_rx</traffic_rx><traffic_tx>$traffic_tx</traffic_tx><mtu>$mtu</mtu>"
        interface_data=$interface_data"<$iface><name>$iface</name>$addrs<traffic_rx>$traffic_rx</traffic_rx><traffic_tx>$traffic_tx</traffic_tx>"
        

        interface_data=$interface_data$(iwconfig ${iface} 2>/dev/null | awk -F':' '
            /Mode/{ split($2, m, " "); printf "<wlan_mode>"m[1]"</wlan_mode>" }
            /Cell/{ split($0, c, " "); printf "<wlan_bssid>"c[5]"</wlan_bssid>" }
            /ESSID/ { split($0, e, "\""); printf "<wlan_essid>"e[2]"</wlan_essid>" }
            /Freq/{ split($3, f, " "); printf "<wlan_frequency>"f[1]f[2]"</wlan_frequency>" }
            /Tx-Power/{ split($0, p, "="); sub(/[[:space:]]*$/, "", p[2]); printf "<wlan_tx_power>"p[2]"</wlan_tx_power>" }
        ')"</$iface>"

        #if [ "`iwconfig ${iface} 2>/dev/null | grep IEEE`" != "" ]; then
        #    wlan_mode="`iwconfig $iface | awk -F':' '/Mode/{ split($2, m, " "); print m[1] }'`"
        #
        #    if [ $wlan_mode = "Master" ]; then	
        #        wlan_bssid="`iw $iface info | awk '/addr/{ print $2 }'`"
        #    elif [ $wlan_mode = "Ad-Hoc" ]; then	
        #        wlan_bssid="`iwconfig $iface | awk '/Cell/{ print $5 }'`"
        #    fi
        #    
        #    wlan_essid="`iwconfig ${iface} | awk -F'"' '/ESSID/ { print $2 }'`"
        #    wlan_frequency="`iwconfig $iface | awk -F':' '/Freq/{ split($3, f, " "); print f[1] }'`"
        #    wlan_tx_power="`iwconfig $iface | awk -F'=' '/Tx-Power/{ print $2 }'`"
        #
        #    interface_data=$interface_data"<wlan_mode>$wlan_mode</wlan_mode><wlan_frequency>$wlan_frequency</wlan_frequency><wlan_essid>$wlan_essid</wlan_essid><wlan_bssid>$wlan_bssid</wlan_bssid><wlan_tx_power>$wlan_tx_power</wlan_tx_power>"
        #fi
        #interface_data=$interface_data"</$iface>"
	done

    err "`date`: Collecting information from batman advanced and it´s interfaces"
	#B.A.T.M.A.N. advanced
    if [ -f /sys/module/batman_adv/version ]; then
        for iface in $(grep active /sys/class/net/*/batman_adv/iface_status); do
            status=${iface#*:}
            iface=${iface%/batman_adv/iface_status:active}
            iface=${iface#/sys/class/net/}
            BATMAN_ADV_INTERFACES=$BATMAN_ADV_INTERFACES"<$iface><name>$iface</name><status>$status</status></$iface>"
        done

        batman_adv_originators=$(awk \
            'BEGIN { FS=" "; i=0 }
            /O/ { next }
            /B/ { next }
            {   sub("\\(", "", $0)
                sub("\\)", "", $0)
                sub("\\[", "", $0)
                sub("\\]:", "", $0)
                sub("  ", " ", $0)
                printf "<originator_"i"><originator>"$1"</originator><link_quality>"$3"</link_quality><nexthop>"$4"</nexthop><last_seen>"$2"</last_seen><outgoing_interface>"$5"</outgoing_interface></originator_"i">"
                i++
            }' /sys/kernel/debug/batman_adv/bat0/originators)
        
		batman_adv_gateway_mode=$(batctl gw)
		
		batman_adv_gateway_list=$(awk \
			'BEGIN { FS=" "; i=0 }
			/Gateway/ { next }
			/No gateways/ { next }
			{	sub("=>", "true", $0)
				sub("  ", "false", $0)
				sub("\\(", "", $0)
				sub("\\)", "", $0)
				sub("\\[", "", $0)
				sub("\\]:", "", $0)
				sub("  ", " ", $0)
				printf "<gateway_"i"><selected>"$1"</selected><gateway>"$2"</gateway><link_quality>"$3"</link_quality><nexthop>"$4"</nexthop><outgoing_interface>"$5"</outgoing_interface><gw_class>"$6" "$7" "$8"</gw_class></gateway_"i">"
				i++
			}' /sys/kernel/debug/batman_adv/bat0/gateways)
    fi
    err "`date`: Collecting information about conected clients"
	#CLIENTS
    SEDDEV=$(brctl showstp $MESH_INTERFACE | awk '/\([0-9]\)/ {
            sub("\\(", "", $0)
            sub("\\)", "", $0)
            print "s/^  "$2"/"$1"/;"
        }')

    client_count=$(brctl showmacs $MESH_INTERFACE | sed -e "$SEDDEV" | egrep -c "(${CLIENT_INTERFACES// /|}).*no")

    err "`date`: Putting all information into a XML-File and save it at "$SCRIPT_DATA_FILE

	DATA="<?xml version='1.0' standalone='yes'?><data><system_data>$SYSTEM_DATA</system_data><interface_data>$interface_data</interface_data><batman_adv_interfaces>$BATMAN_ADV_INTERFACES</batman_adv_interfaces><batman_adv_originators>$batman_adv_originators</batman_adv_originators><batman_adv_gateway_mode>$batman_adv_gateway_mode</batman_adv_gateway_mode><batman_adv_gateway_list>$batman_adv_gateway_list</batman_adv_gateway_list><client_count>$client_count</client_count></data>"

	#write data to hxml file that provides the data on httpd
	echo $DATA | gzip > $SCRIPT_DATA_FILE
}

LANG=C

#Prüft ob das logfile zu groß geworden ist
err "`date`: Check logfile"
delete_log

#Erzeugt die statusdaten
err "`date`: Generate actual status data"
crawl

exit 0
