#!/bin/ash

[ $# -ge 2 ] || exit 1

CACHEDIR='/tmp/cache'

MAXAGE="$1"
shift 1
COMMAND="$@"

# generate an ID based on the command to be executed
ID=$(echo "$COMMAND" | md5sum | cut -d" " -f1) || exit 1

CACHED=false

# create directory for cached output
[ -d "$CACHEDIR" ] || mkdir -p "$CACHEDIR"
[ -d "$CACHEDIR" ] || exit 1

# if there is an entry for the command to be executed...
if [ -f "$CACHEDIR/$ID/timestamp" ]; then
	TIMESTAMP=$(cat "$CACHEDIR/$ID/timestamp")
	CURRENTTIME=$(date +%s)
	# ...check the timestamp and determine if it is sufficiently recent
	if [ -n "$TIMESTAMP" ] && [ $(($CURRENTTIME-$TIMESTAMP)) -lt $MAXAGE ] && [ -f "$CACHEDIR/$ID/output" ]; then
		CACHED=true
	fi
fi

# if there is cached output data just put it out...
if $CACHED; then
	cat "$CACHEDIR/$ID/output"
else
# ...if not execute the command and save the output and a timestamp
	[ -d "$CACHEDIR/$ID" ] || mkdir -p "$CACHEDIR/$ID"
	$COMMAND | tee "$CACHEDIR/$ID/output"
	date +%s > "$CACHEDIR/$ID/timestamp"
fi
