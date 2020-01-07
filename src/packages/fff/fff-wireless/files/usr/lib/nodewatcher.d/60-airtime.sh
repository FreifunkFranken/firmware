#!/bin/sh
# Netmon Nodewatcher (C) 2010-2012 Freifunk Oldenburg
# License; GPL v3

w2dump="$(iw dev w2ap survey dump 2> /dev/null | sed '/Survey/,/\[in use\]/d')"
if [ -n "$w2dump" ] ; then
	w2_ACT="$(ACTIVE=$(echo "$w2dump" | grep "active time:"); set ${ACTIVE:-0 0 0 0 0}; echo -e "${4}")"
	w2_BUS="$(BUSY=$(echo "$w2dump" | grep "busy time:"); set ${BUSY:-0 0 0 0 0}; echo -e "${4}")"
	echo -n "$dataair<airtime2><active>$w2_ACT</active><busy>$w2_BUS</busy></airtime2>"
fi
w5dump="$(iw dev w5ap survey dump 2> /dev/null | sed '/Survey/,/\[in use\]/d')"
if [ -n "$w5dump" ] ; then
	w5_ACT="$(ACTIVE=$(echo "$w5dump" | grep "active time:"); set ${ACTIVE:-0 0 0 0 0}; echo -e "${4}")"
	w5_BUS="$(BUSY=$(echo "$w5dump" | grep "busy time:"); set ${BUSY:-0 0 0 0 0}; echo -e "${4}")"
	echo -n "$dataair<airtime5><active>$w5_ACT</active><busy>$w5_BUS</busy></airtime5>"
fi

exit 0
