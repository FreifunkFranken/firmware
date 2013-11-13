#!/bin/ash

# string check
check() {
	local MODE="$1"
	local STRING="$2"
	local REGEXP=
	local STRING_VALID=
	[ -n "$2" ] || return 1
	case "$MODE" in
		binary)
			REGEXP="^[01]+$"
		;;

		bool)
			REGEXP="^[01]$"
		;;

		direction)
			REGEXP="^[NESW]{1,3}$"
		;;

		email)
			REGEXP="^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$"
		;;

		hostname)
			REGEXP="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$"
		;;

		httpurl)
			REGEXP="^http(s?):\/\/[^ \"\(\)\<\>]*$"
		;;

		integer)
			REGEXP="^[0-9]+$"
		;;

		numeric)
			REGEXP="^[0-9]+(\.[0-9]+)?$"
		;;
		
		regexp)
			REGEXP="$3"
		;;

		telephone)
			REGEXP="^\+?[-0-9./() ]+$"
		;;

		simplestring)
			REGEXP="^[-a-zA-Z0-9._ ]+$"
		;;

	esac
	STRING_VALID=$(echo -n "$STRING" | grep -E "$REGEXP")
	[ "$STRING" == "$STRING_VALID" ] || return 1
}

# command implementations
set_hostname() {
	local HOSTNAME="$1"
	check hostname "$HOSTNAME" || return 1
	uci set system.@system[0].hostname="$HOSTNAME"
	uci commit
	echo "$HOSTNAME" > /proc/sys/kernel/hostname
}

set_wanratelimit() {
	local UPLIMIT="$1"
	local DOWNLIMIT="$2"
	check integer "$UPLIMIT" || return 1
	check integer "$DOWNLIMIT" || return 1
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
	check httpurl "$URL" || return 1
	check regexp "$URL" "$BOARDNAME" || return 1
	check regexp "$URL" "upgrade" || return 1
	[ -n "$MD5SUM" ] || MD5SUM=$(wget -q -O - --no-check-certificate "$URL.md5" | cut -d" " -f1)
	[ -n "$MD5SUM" ] || return 1
	wget -q -O /tmp/firmware-sysupgrade.bin --no-check-certificate "$URL" || return 1
	local MD5SUM_VALID=$(md5sum /tmp/firmware-sysupgrade.bin | cut -d" " -f1)
	[ "$MD5SUM" == "$MD5SUM_VALID" ] || return 1
	sysupgrade /tmp/firmware-sysupgrade.bin
}

set_upgradepath() {
	local UPGRADEPATH="$1"
	check httpurl "$UPGRADEPATH" || return 1
	uci set firmware.upgrade=upgrade || return 1
	uci set firmware.upgrade.path="$UPGRADEPATH" || return 1
	uci commit
}

set_location() {
	local LATITUDE="$1"
	local LONGITUDE="$2"
	local ELEVATION="$3"
	check numeric "$LATITUDE" || return 1
	check numeric "$LONGITUDE" || return 1
	uci set site.location=location
	uci set site.location.latitude="$LATITUDE"
	uci set site.location.longitude="$LONGITUDE"
	check numeric "$ELEVATION" && uci set site.location.elevation="$ELEVATION"
	uci commit
}

set_outdoor() {
	local OUTDOOR="$1"
	check bool "$OUTDOOR" || return 1
	uci set site.location=location
	uci set site.location.outdoor="$OUTDOOR"
	uci commit
}

set_direction() {
	local DIRECTION="$@"
	DIRECTION=$(echo "$DIRECTION" | tr "nesw" "NESW") || return 1
	check direction "$DIRECTION" || return 1
	uci set site.location=location
	uci set site.location.direction="$DIRECTION"
	uci commit
}

set_tags() {
	local TAGS="$@"
	TAGS=$(echo $TAGS | tr -s " ")
	check simplestring "$TAGS" || return 1
	uci set site.location=location
	uci set site.location.tags="$TAGS"
	uci commit
}

set_email() {
	local EMAIL="$@"
	check email "$EMAIL" || return 1
	uci set site.contact=contact
	uci set site.contact.email="$EMAIL"
	uci commit
}

set_contact() {
	local CONTACT="$@"
	check simplestring "$CONTACT" || return 1
	uci set site.contact=contact
	uci set site.contact.name="$CONTACT"
	uci commit
}

set_telephone() {
	local TELEPHONE="$@"
	check telephone "$TELEPHONE" || return 1
	uci set site.contact=contact
	uci set site.contact.telephone="$TELEPHONE"
	uci commit
}

ACTION="$1"
shift

case "$ACTION" in
	hostname)
		set_hostname $@
	;;

	wanlimit)
		set_wanratelimit $@
	;;

	upgrade)
		upgrade_firmware $@
	;;
	
	upgradepath)
		set_upgradepath	 $@
	;;

	location)
		set_location $@
	;;

	outdoor)
		set_outdoor $@
	;;

	direction)
		set_direction $@
	;;

	tags)
		set_tags $@
	;;

	email)
		set_email $@
	;;

	contact)
		set_contact $@
	;;

	telephone)
		set_telephone $@
	;;

	*)
		echo "unknown action '$ACTION'"
		exit 1
	;;
esac

# dont add anything here so we get the exit status of the action

