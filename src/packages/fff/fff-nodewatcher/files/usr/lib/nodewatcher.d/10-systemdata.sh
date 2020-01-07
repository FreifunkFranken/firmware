#!/bin/sh
# Netmon Nodewatcher (C) 2010-2012 Freifunk Oldenburg
# License; GPL v3

SCRIPT_STATUS_FILE=$(uci get nodewatcher.@script[0].status_text_file)
SCRIPT_VERSION="56"

debug() {
	(>&2 echo "$1")
}

#Get system data from other locations
debug "$(date): Collecting basic system status data"
hostname="$(cat /proc/sys/kernel/hostname)"
mac=$(awk '{ mac=toupper($1); gsub(":", "", mac); print mac }' /sys/class/net/br-mesh/address 2>/dev/null)
[ "$hostname" = "OpenWrt" ] && hostname="$mac"
[ "$hostname" = "FFF" ] && hostname="$mac"
description="$(uci -q get fff.system.description)"
if [ -n "$description" ]; then
	description="<description><![CDATA[$description]]></description>"
fi
latitude="$(uci -q get fff.system.latitude)"
longitude="$(uci -q get fff.system.longitude)"
if [ -n "$longitude" -a -n "$latitude" ]; then
	geo="<geo><lat>$latitude</lat><lng>$longitude</lng></geo>";
fi
position_comment="$(uci -q get fff.system.position_comment)"
if [ -n "$position_comment" ]; then
	position_comment="<position_comment><![CDATA[$position_comment]]></position_comment>"
fi
contact="$(uci -q get fff.system.contact)"
if [ -n "$contact" ]; then
	contact="<contact>$contact</contact>"
fi
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
	/platform/ { printf "<chipset>"$2"</chipset>" }
' /proc/cpuinfo)
model="<model>$(cat /var/sysinfo/model)</model>"
local_time="$(date +%s)"
load=$(awk '{ printf "<loadavg>"$3"</loadavg><processes>"$4"</processes>" }' /proc/loadavg)

debug "$(date): Collecting version information"

batman_adv_version=$(cat /sys/module/batman_adv/version)
kernel_version=$(uname -r)
if [ -x /usr/bin/fastd ]; then
	fastd_version="<fastd_version>$(/usr/bin/fastd -v | awk '{ print $2 }')</fastd_version>"
fi
nodewatcher_version=$SCRIPT_VERSION
if [ -x /usr/sbin/babeld ]; then
	babel_version="<babel_version>$(/usr/sbin/babeld -V 2>&1)</babel_version>"
fi

if [ -f "$SCRIPT_STATUS_FILE" ]; then
	status_text="<status_text>$(cat "$SCRIPT_STATUS_FILE")</status_text>"
fi

# Checks if fastd is running
if pidof fastd >/dev/null ; then
	vpn_active="<vpn_active>1</vpn_active>"
else
	vpn_active="<vpn_active>0</vpn_active>"
fi

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

SYSTEM_DATA="<status>online</status>"
SYSTEM_DATA=$SYSTEM_DATA"$status_text"
SYSTEM_DATA=$SYSTEM_DATA"<hostname>$hostname</hostname>"
SYSTEM_DATA=$SYSTEM_DATA"${description}"
SYSTEM_DATA=$SYSTEM_DATA"${geo}"
SYSTEM_DATA=$SYSTEM_DATA"${position_comment}"
SYSTEM_DATA=$SYSTEM_DATA"${contact}"
SYSTEM_DATA=$SYSTEM_DATA"<hood>$(uci -q get "system.@system[0].hood")</hood>"
SYSTEM_DATA=$SYSTEM_DATA"<hoodid>$(uci -q get "system.@system[0].hoodid")</hoodid>"
SYSTEM_DATA=$SYSTEM_DATA"<distname>$distname</distname>"
SYSTEM_DATA=$SYSTEM_DATA"<distversion>$distversion</distversion>"
SYSTEM_DATA=$SYSTEM_DATA"$cpu"
SYSTEM_DATA=$SYSTEM_DATA"$model"
SYSTEM_DATA=$SYSTEM_DATA"$memory"
SYSTEM_DATA=$SYSTEM_DATA"$load"
SYSTEM_DATA=$SYSTEM_DATA"$uptime"
SYSTEM_DATA=$SYSTEM_DATA"<local_time>$local_time</local_time>"
SYSTEM_DATA=$SYSTEM_DATA"<batman_advanced_version>$batman_adv_version</batman_advanced_version>"
SYSTEM_DATA=$SYSTEM_DATA"<kernel_version>$kernel_version</kernel_version>"
SYSTEM_DATA=$SYSTEM_DATA"$fastd_version"
SYSTEM_DATA=$SYSTEM_DATA"<nodewatcher_version>$nodewatcher_version</nodewatcher_version>"
SYSTEM_DATA=$SYSTEM_DATA"$babel_version"
SYSTEM_DATA=$SYSTEM_DATA"<firmware_version>$FIRMWARE_VERSION</firmware_version>"
SYSTEM_DATA=$SYSTEM_DATA"<firmware_revision>$BUILD_DATE</firmware_revision>"
SYSTEM_DATA=$SYSTEM_DATA"<openwrt_core_revision>$OPENWRT_CORE_REVISION</openwrt_core_revision>"
SYSTEM_DATA=$SYSTEM_DATA"<openwrt_feeds_packages_revision>$OPENWRT_FEEDS_PACKAGES_REVISION</openwrt_feeds_packages_revision>"
SYSTEM_DATA=$SYSTEM_DATA"$vpn_active"

echo -n "<system_data>$SYSTEM_DATA</system_data>"

exit 0
