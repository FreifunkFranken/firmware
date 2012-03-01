#!/bin/sh

while read LINE
do
	if [ "`echo $LINE | grep 'wlan0:'`" != "" ]; then
		wget -q -O - http://status.kreativitaet-trifft-technik.de/update/ff\?client_associated=`date +%s`\&clients_count=`/etc/clients.sh` & sleep 3; kill $!
                #echo http://status.kreativitaet-trifft-technik.de/update/ff\?client_associated=`date +%s`\&clients_count=`/etc/clients.sh` & sleep 3; kill $!

	fi
	#echo `echo $LINE | grep 'wlan0:' | awk '{ print $4 }'` >> /var/log/clients_event.log
done


