#!/bin/ash

# config
STATSDIR="/tmp/statistics"

# functions
paste_variables() {
	local VAR1="$1"
	local VAR2="$2"
	local TMP1=$(mktemp) || return 1
	local TMP2=$(mktemp) || return 1
	echo "$VAR1" > "$TMP1"
	echo "$VAR2" > "$TMP2"
	paste -d" " "$TMP1" "$TMP2"
	rm "$TMP1" "$TMP2"
}

get_trafficdata() {
	cat /proc/net/dev | tail -n +3 | tr ":" " " | sed -e 's/^[ ]\+//g' | tr -s " " | cut -d" " -f 1,2,3,10,11 || return 1
}

update_traffic() {
	local TIME=$(date +%s)
	local DATA=$(get_trafficdata)
	local DATATMP=
	local REFERENCE=
	local REFERENCETMP=
	local REFERENCE_TIME=
	local DELTA=
	local DEVICES=
	if  [ -f "$STATSDIR/traffic_reference_time" ] && [ -f "$STATSDIR/traffic_reference" ]; then
		REFERENCE_TIME=$(cat "$STATSDIR/traffic_reference_time")
		REFERENCE=$(cat "$STATSDIR/traffic_reference")
	fi
	if [ -n "$TIME" ] && [ -n "$REFERENCE_TIME" ]; then
		DELTA=$(($TIME-$REFERENCE_TIME))
	fi
	if [ -n "$DATA" ] && [ -n "$REFERENCE" ] && [ -n "$DELTA" ]; then
		echo "#device rx[b/s] rx[p/s] tx[b/s] tx[p/s]" > "$STATSDIR/traffic.tmp"
		DEVICES=$(echo "$DATA" | cut -d" " -f1 | sort -u) || return 1
		echo "$DEVICES" | while read DEVICE; do
			if [ -n "$DEVICE" ]
			then
				DATATMP=$(echo "$DATA" | grep "^$DEVICE " | cut -d" " -f 2- | tr "\n" " ") || return 1
				REFERENCETMP=$(echo "$REFERENCE" | grep "^$DEVICE " | cut -d" " -f 2- | tr "\n" " ") || return 1
				echo "$DEVICE $DATATMP $REFERENCETMP" | tr -s " " | awk -F" " -v DELTA=$DELTA '{printf "%s %.0f %.0f %.0f %.0f\n",$1,($2-$6)/DELTA,($3-$7)/DELTA,($4-$8)/DELTA,($5-$9)/DELTA}' >> "$STATSDIR/traffic.tmp" || return 1
			fi
			done
		mv "$STATSDIR/traffic.tmp" "$STATSDIR/traffic"
	fi
	echo "$DATA" > "$STATSDIR/traffic_reference"
	echo "$TIME" > "$STATSDIR/traffic_reference_time"
}

# secure dot-scripts
[ -e "$STATSDIR" ] || mkdir -p "$STATSDIR"
[ -d "$STATSDIR" ] || exit 1
chown -R root "$STATSDIR"
chmod -R 700 "$STATSDIR"

# update values
update_traffic



