#!/bin/sh
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

/usr/sbin/configurenetwork

# Starting NTP-Client Daemon after 30s to ensure that the interface is up
( sleep 30 ; ntpd -p ${NTPD_IP} ) &

touch /tmp/started

exit 0
