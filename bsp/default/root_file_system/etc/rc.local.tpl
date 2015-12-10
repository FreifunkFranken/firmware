#!/bin/sh
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

BOARD=$(cat /var/sysinfo/board_name)

case "$BOARD" in
    tl-wr1043nd)
        BOARD=tl-wr1043nd-v1
        ;;
    tl-wr741nd)
        grep "Atheros AR7240 rev 2" /proc/cpuinfo && BOARD=tl-wr741nd-v2 || BOARD=tl-wr741nd-v4
        ;;
    tl-wr741nd-v4)
        grep 740 /var/sysinfo/model && BOARD=tl-wr740n-v4
        ;;
    tl-wr841n-v7)
        BOARD=tl-wr841nd-v7
        ;;
    tl-wr841n-v9)
        grep "v10" /var/sysinfo/model && BOARD=tl-wr841n-v10
        ;;
    nanostation-m)
        BOARD=ubnt-nano-m
        ;;
esac

if ! uci get board.model.name; then
    uci set board.model.name=$BOARD
fi

. /etc/network.$BOARD

. /etc/network.sh

# Starting NTP-Client Daemon after 30s to ensure that the interface is up
( sleep 30 ; ntpd -p ${NTPD_IP} ) &

. /etc/firewall.user

/etc/init.d/qos disable
/etc/init.d/qos stop

#busybox-httpd for crawldata
mkdir /tmp/crawldata
httpd -h /tmp/crawldata

touch /tmp/started

exit 0
