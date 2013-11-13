#!/bin/ash

[ $# -ge 3 ] || exit 1

PORT="$1"
DELAY="$2"
shift 2
COMMAND="$@"

while true; do
	(nc -l -p $PORT -e $COMMAND) > /dev/null 2>&1
	sleep $DELAY
done
