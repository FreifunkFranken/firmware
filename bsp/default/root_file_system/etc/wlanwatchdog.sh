#!/bin/ash
	
test -f /tmp/started || exit

# environment
. "/tmp/environment" || exit 1

# constants
MINUTE=60
HOUR=3600
DAY=86400
TIMEOUT_SHORT=$((4*$MINUTE))
TIMEOUT_MEDIUM=$((29*$MINUTE))
TIMEOUT_LONG=$DAY
ORIGINATOR_QUALITY_MIN=50
CLIENT_AGE_MAX=60
STATEFILE="/tmp/wlanwatchdogstate"
DEBUGFILE="/root/wlanwatchdog_debug.log.gz"

# variables
STATE=
SINCE=

# functions
debug_output() {
	echo "==== DEBUG OUTPUT ===="
	echo "date: $(date)"
	echo "=== INTERFACES ==="
	ifconfig 2>&1
	echo "=== BATMAN ==="
	echo "== ORIGINATORS =="
	batctl o 2>&1
	echo "== STATISTICS =="
	batctl s 2>&1
	echo "== GATEWAYS =="
	batctl gwl 2>&1
	echo "=== BRIDGE ==="
	echo "== $BRIDGE_INTERFACE =="
	brctl showmacs $BRIDGE_INTERFACE 2>&1
	echo "=== CONNECTIVITY TESTS ==="
	echo "== PING GATEWAY OVER MESH =="
	ping -6 -c3 $(uci get configurator.@api[0].ipv6_address)%$(uci get configurator.@api[0].ipv6_interface) 2>&1
	echo "== PING HOST OVER INTERNET =="
	ping -4 -c3 freifunk-ol.de 2>&1
	echo "=== WLAN ==="
	echo "== $WLAN_CLIENT_INTERFACE =="
	iw dev $WLAN_CLIENT_INTERFACE station dump 2>&1
	echo "== $WLAN_MESH_INTERFACE =="
	iw dev $WLAN_MESH_INTERFACE station dump 2>&1
	echo "== SCAN =="
	iwlist scanning 2>&1
	echo "=== WATCHDOG LOG ==="
	cat "/var/log/wlanwatchdog.log"
}

get_time() {
	date +%s
}

count_originators() {
	local COUNT=0
	if [ -n "$BATMAN_INTERFACE" ]; then
		COUNT=$(tail -n +3 /sys/kernel/debug/batman_adv/$BATMAN_INTERFACE/originators 2> /dev/null | \
			grep "$1" | \
			grep -o "^\([0-9a-f]\{2\}:\?\)\+[[:space:]]\+[0-9.]\+s[[:space:]]\+([ 0-9]\+)" | \
			cut -d\( -f2 | \
			cut -d\) -f1 | \
			tr -d " " | \
			awk -vlimit=$ORIGINATOR_QUALITY_MIN '$1>=limit{print $1}' | \
			wc -l)
	fi
	echo $COUNT
}

count_clients() {
	local COUNT=0
	local NUMBER=
	if [ -n "$BRIDGE_INTERFACE" ] && [ -n "$WLAN_CLIENT_INTERFACE" ]; then
		NUMBER=$(brctl showstp $BRIDGE_INTERFACE 2> /dev/null | \
			grep -e "^$WLAN_CLIENT_INTERFACE " | \
			cut -d" " -f2 | \
			tr -d "()")
	fi
	if [ -n "$BRIDGE_INTERFACE" ] && [ -n "$NUMBER" ]; then
		COUNT=$(brctl showmacs "^$BRIDGE_INTERFACE " 2> /dev/null | \
			grep -o "^[[:space:]]*$NUMBER[[:space:]]\+\([0-9a-f]\{2\}:\?\)\+[[:space:]]\+no[[:space:]]\+[0-9]\+" | \
				tr "\t" " " | \
				tr -s " " | \
				cut -d" " -f5 | \
				awk -vlimit=$CLIENT_AGE_MAX '$1<=limit{print $1}' | \
				wc -l)
	fi
	echo $COUNT
}

count_neighbours() {
	count_originators "$WLAN_MESH_INTERFACE"
}

scan_wlan() {
	#FIXME: if you can; is there an easier way to get the current frequency?
	#FIXME: this should reanimate the wlan driver; do passive and active scanning the job equally well?
	local FREQUENCY=$(iwlist $WLAN_MESH_INTERFACE frequency 2> /dev/null | \
		grep -o "Current Frequency=[0-9.]\+ GHz" | \
		grep -o "[0-9.]*" | \
		tr -d ".")
	[ -n "$FREQUENCY" ] && iw $WLAN_MESH_INTERFACE scan freq $FREQUENCY passive 1> /dev/null 2> /dev/null
}

fsm_load() {
	if [ -f "$STATEFILE" ]; then
		STATE=""
		SINCE=""
		. "$STATEFILE" || return 1
	fi
}

fsm_save() {
	echo -e "STATE=${STATE}\nSINCE=${SINCE}" > "$STATEFILE" || return 1
}

fsm_entry() {
	SINCE=$(get_time)
	case $STATE in
		pending)
			scan_wlan
		;;
		error)
			if [ -n "$DEBUG" ] && [ $DEBUG -eq 1 ]; then
				debug_output | gzip > ${DEBUGFILE}
			fi
			reboot
		;;
	esac
}

fsm_transition() {
	local AGE=-1
	[ -n "$SINCE" ] && AGE=$(( $(get_time) - $SINCE ))
	local OLDSTATE=$STATE
	case $STATE in
		working)
			if [ $(count_neighbours) -eq 0 ] && [ $(count_clients) -eq 0 ]; then
				STATE=pending
			fi
		;;
		pending)
			if [ $AGE -ge $TIMEOUT_MEDIUM ]; then
				STATE=error
			elif [ $(count_originators) -eq 0 ] && [ $AGE -ge $TIMEOUT_SHORT ]; then
				STATE=error
			elif [ $(count_neighbours) -gt 0 ] || [ $(count_clients) -gt 0 ]; then
				STATE=working
			fi
		;;
		*)
			if [ $AGE -ge $TIMEOUT_LONG ]; then
				STATE=error
			elif [ $(count_neighbours) -gt 0 ] || [ $(count_clients) -gt 0 ]; then
				STATE=working
			fi
		;;
	esac
	if [ ! "$OLDSTATE" == "$STATE" ]; then
		echo "$(date) '$OLDSTATE' -> '$STATE'"
		fsm_entry
	fi
}

# program
fsm_load
fsm_transition
fsm_save

