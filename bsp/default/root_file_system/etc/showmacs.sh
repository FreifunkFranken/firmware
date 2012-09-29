#!/bin/sh
#
# SHOWMACS need br-ctl! NO BUSYBOX!
#
# Version 0.2
#
# by Tim Niemeyer (reddog@mastersword.de)
#

DEV=$1

SEDDEV=`brctl showstp $DEV | egrep '\([0-9]\)' | sed -e "s/(//;s/)//" | awk '{ print "s/^  "$2"/"$1"/;" }'`
SEDMAC=`cat /etc/bat-hosts | sed -e "s/^/s\//;s/$/\/;/;s/ /\//"`

brctl showmacs $DEV | sed -e "$SEDMAC" | sed -e "$SEDDEV" 
