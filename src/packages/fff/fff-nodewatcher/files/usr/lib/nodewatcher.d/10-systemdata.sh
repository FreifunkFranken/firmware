#!/bin/sh
# Netmon Nodewatcher (C) 2010-2012 Freifunk Oldenburg
# License; GPL v3

SCRIPT_STATUS_FILE=$(uci get nodewatcher.@script[0].status_text_file)
SCRIPT_VERSION=$(cat /etc/nodewatcher_version)

debug() {
	(>&2 echo "nodewatcher: $1")
}

debug "Collecting basic system status data"

SYSTEM_DATA="<status>online</status>"

hostname="$(cat /proc/sys/kernel/hostname)"
mac=$(awk '{ mac=toupper($1); gsub(":", "", mac); print mac }' /sys/class/net/br-mesh/address 2>/dev/null)
[ "$hostname" = "OpenWrt" ] && hostname="$mac"
[ "$hostname" = "FFF" ] && hostname="$mac"
SYSTEM_DATA="$SYSTEM_DATA<hostname>$hostname</hostname>"

description="$(uci -q get fff.system.description)"
[ -n "$description" ] && SYSTEM_DATA="$SYSTEM_DATA<description><![CDATA[$description]]></description>"

latitude="$(uci -q get fff.system.latitude)"
longitude="$(uci -q get fff.system.longitude)"
if [ -n "$longitude" -a -n "$latitude" ]; then
	SYSTEM_DATA="$SYSTEM_DATA<geo><lat>$latitude</lat><lng>$longitude</lng></geo>"
fi

position_comment="$(uci -q get fff.system.position_comment)"
[ -n "$position_comment" ] && SYSTEM_DATA="$SYSTEM_DATA<position_comment><![CDATA[$position_comment]]></position_comment>"

contact="$(uci -q get fff.system.contact)"
[ -n "$contact" ] && SYSTEM_DATA="$SYSTEM_DATA<contact>$contact</contact>"

uptime=$(awk '{ printf "<uptime>"$1"</uptime><idletime>"$2"</idletime>" }' /proc/uptime)
SYSTEM_DATA="$SYSTEM_DATA$uptime"

memory=$(awk '
	/^MemTotal/ { printf "<memory_total>"$2"</memory_total>" }
	/^Cached:/ { printf "<memory_caching>"$2"</memory_caching>" }
	/^Buffers/ { printf "<memory_buffering>"$2"</memory_buffering>" }
	/^MemFree/ { printf "<memory_free>"$2"</memory_free>" }
' /proc/meminfo)
SYSTEM_DATA="$SYSTEM_DATA$memory"

cpu=$(awk -F': ' '
	/model/ { printf "<cpu>"$2"</cpu>" }
	/system type/ { printf "<chipset>"$2"</chipset>" }
	/platform/ { printf "<chipset>"$2"</chipset>" }
' /proc/cpuinfo)
SYSTEM_DATA="$SYSTEM_DATA$cpu"

SYSTEM_DATA="$SYSTEM_DATA<model>$(cat /var/sysinfo/model)</model>"

SYSTEM_DATA="$SYSTEM_DATA<local_time>$(date +%s)</local_time>"

load=$(awk '{ printf "<loadavg>"$3"</loadavg><processes>"$4"</processes>" }' /proc/loadavg)
SYSTEM_DATA="$SYSTEM_DATA$load"

debug "Collecting version information"

if [ -e /sys/module/batman_adv/version ]; then
	SYSTEM_DATA="$SYSTEM_DATA<batman_advanced_version>$(cat /sys/module/batman_adv/version)</batman_advanced_version>"
fi

SYSTEM_DATA="$SYSTEM_DATA<kernel_version>$(uname -r)</kernel_version>"
SYSTEM_DATA="$SYSTEM_DATA<nodewatcher_version>$SCRIPT_VERSION</nodewatcher_version>"

if [ -x /usr/bin/fastd ]; then
	SYSTEM_DATA="$SYSTEM_DATA<fastd_version>$(/usr/bin/fastd -v | awk '{ print $2 }')</fastd_version>"
fi

if [ -x /usr/sbin/babeld ]; then
	SYSTEM_DATA="$SYSTEM_DATA<babel_version>$(/usr/sbin/babeld -V 2>&1)</babel_version>"
fi

# example for /etc/openwrt_release:
#DISTRIB_ID="OpenWrt"
#DISTRIB_RELEASE="Attitude Adjustment"
#DISTRIB_REVISION="r35298"
#DISTRIB_CODENAME="attitude_adjustment"
#DISTRIB_TARGET="atheros/generic"
#DISTRIB_DESCRIPTION="OpenWrt Attitude Adjustment 12.09-rc1"
. /etc/openwrt_release
SYSTEM_DATA="$SYSTEM_DATA<distname>$DISTRIB_ID</distname>"
SYSTEM_DATA="$SYSTEM_DATA<distversion>$DISTRIB_RELEASE</distversion>"

# example for /etc/firmware_release:
#FIRMWARE_VERSION="95f36685e7b6cbf423f02cf5c7f1e785fd4ccdae-dirty"
#BUILD_DATE="build date: Di 29. Jan 19:33:34 CET 2013"
#OPENWRT_CORE_REVISION="35298"
#OPENWRT_FEEDS_PACKAGES_REVISION="35298"
. /etc/firmware_release
SYSTEM_DATA="$SYSTEM_DATA<firmware_version>$FIRMWARE_VERSION</firmware_version>"
SYSTEM_DATA="$SYSTEM_DATA<firmware_revision>$BUILD_DATE</firmware_revision>"
SYSTEM_DATA="$SYSTEM_DATA<openwrt_core_revision>$OPENWRT_CORE_REVISION</openwrt_core_revision>"
SYSTEM_DATA="$SYSTEM_DATA<openwrt_feeds_packages_revision>$OPENWRT_FEEDS_PACKAGES_REVISION</openwrt_feeds_packages_revision>"

debug "Collecting hood information and additional status data"

SYSTEM_DATA="$SYSTEM_DATA<hood>$(uci -q get "system.@system[0].hood")</hood>"
SYSTEM_DATA="$SYSTEM_DATA<hoodid>$(uci -q get "system.@system[0].hoodid")</hoodid>"

if [ -s "$SCRIPT_STATUS_FILE" ]; then
	SYSTEM_DATA="$SYSTEM_DATA<status_text>$(cat "$SCRIPT_STATUS_FILE")</status_text>"
fi

# Checks if fastd is running
vpn_active=0
pidof fastd >/dev/null && vpn_active=1
SYSTEM_DATA="$SYSTEM_DATA<vpn_active>$vpn_active</vpn_active>"

echo -n "<system_data>$SYSTEM_DATA</system_data>"

exit 0
