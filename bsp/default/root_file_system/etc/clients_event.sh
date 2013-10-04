#!/bin/sh

i=`/etc/clients.sh`
wget -q -O - http://status.kreativitaet-trifft-technik.de/update/ff\?bootup=`date +%s`\&clients_count=$i

while read LINE
do
	if [ "`echo $LINE | grep 'wlan0: new station'`" != "" ]; then
		i=`expr $i + 1`
		wget -q -O - http://status.kreativitaet-trifft-technik.de/update/ff\?client_associated=`date +%s`\&clients_count=$i
        fi
        if [ "`echo $LINE | grep 'wlan0: unknown event 20'`" != "" ]; then
                i=`expr $i - 1`
                wget -q -O - http://status.kreativitaet-trifft-technik.de/update/ff\?client_disassociated=`date +%s`\&clients_count=$i
        fi
done


