#!/bin/sh
#
# SHOWMACS need br-ctl! NO BUSYBOX!
#
# Version 0.2
#
# by Tim Niemeyer (reddog@mastersword.de)

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#

DEV=$1

SEDDEV=`brctl showstp $DEV | egrep '\([0-9]\)' | sed -e "s/(//;s/)//" | awk '{ print "s/^  "$2"/"$1"/;" }'`
SEDMAC=`cat /etc/bat-hosts | sed -e "s/^/s\//;s/$/\/;/;s/ /\//"`

brctl showmacs $DEV | sed -e "$SEDMAC" | sed -e "$SEDDEV" 
