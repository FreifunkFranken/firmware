#!/bin/ash

# input check functions
check_hostname() {
	local STRING="$@"
	[ -n "$STRING" ] || return 1
	local STRING_VALID=$(echo -n "$STRING" | grep -E "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$")
	[ "$STRING" == "$STRING_VALID" ] || return 1
}

check_integer() {
	local STRING="$@"
	[ -n "$STRING" ] || return 1
	local STRING_VALID=$(echo -n "$STRING" | grep -E "^[0-9]+$")
	[ "$STRING" == "$STRING_VALID" ] || return 1
}

check_httpurl() {
	local STRING="$@"
	[ -n "$STRING" ] || return 1
	local STRING_VALID=$(echo -n "$STRING" | grep -E "http(s?):\/\/[^ \"\(\)\<\>]*")
	[ "$STRING" == "$STRING_VALID" ] || return 1
}

check_contains() {
	local STRING="$1"
	local STRING2="$2"
	local STRING_VALID=$(echo -n "$STRING" | grep -E "$STRING2")
	[ "$STRING" == "$STRING_VALID" ] || return 1
}

# command implementations
set_hostname() {
	local HOSTNAME="$1"
	check_hostname "$HOSTNAME" || return 1
	uci set system.@system[0].hostname="$HOSTNAME"
	uci commit
	echo "$HOSTNAME" > /proc/sys/kernel/hostname
}

set_wanratelimit() {
	local UPLIMIT="$1"
	local DOWNLIMIT="$2"
	check_integer "$UPLIMIT" || return 1
	check_integer "$DOWNLIMIT" || return 1
	if [ "$UPLIMIT" -gt 0 ] && [ "$DOWNLIMIT" -gt 0 ]; then
		uci set qos.wan.upload="$UPLIMIT"
		uci set qos.wan.download="$DOWNLIMIT"
		uci commit
		/etc/init.d/qos stop
		/etc/init.d/qos enable
		/etc/init.d/qos start
	else
		/etc/init.d/qos stop
		/etc/init.d/qos disable
	fi
}

upgrade_firmware() {
	local URL="$1"
	local MD5SUM="$2"
	local BOARDNAME=$(uci get board.model.name)
	[ -n "$BOARDNAME" ] || return 1
	if [ -z "$URL" ]; then
		local UPGRADEPATH=$(uci get firmware.upgrade.path)
		URL="${UPGRADEPATH}/${BOARDNAME}.bin"
	fi
	check_httpurl "$URL" || return 1
	check_contains "$URL" "$BOARDNAME" || return 1
	check_contains "$URL" "upgrade" || return 1
	[ -n "$MD5SUM" ] || MD5SUM=$(wget -q -O - --no-check-certificate "$URL.md5" | cut -d" " -f1)
	[ -n "$MD5SUM" ] || return 1
	wget -q -O /tmp/firmware-sysupgrade.bin --no-check-certificate "$URL" || return 1
	local MD5SUM_VALID=$(md5sum /tmp/firmware-sysupgrade.bin | cut -d" " -f1)
	[ "$MD5SUM" == "$MD5SUM_VALID" ] || return 1
	sysupgrade /tmp/firmware-sysupgrade.bin
}

ACTION="$1"
shift

case "$ACTION" in
	hostname)
		set_hostname $@
	;;

	wanratelimit)
		set_wanratelimit $@
	;;

	upgrade)
		upgrade_firmware $@
	;;
	
	*)
		echo "unknown action"
	;;
esac
