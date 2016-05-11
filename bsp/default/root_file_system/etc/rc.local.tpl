#!/bin/sh
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

BOARD=$(cat /var/sysinfo/board_name)

case "$BOARD" in
    tl-wr1043nd)
        BOARD=tl-wr1043nd-v1
        ;;
    tl-wr1043nd-v2)
        grep "v3" /var/sysinfo/model && BOARD=tl-wr1043nd-v3
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
        grep "v11" /var/sysinfo/model && BOARD=tl-wr841n-v11
        ;;
    nanostation-m)
        BOARD=ubnt-nano-m
        ;;
    bullet-m)
        BOARD=ubnt-bullet-m
        ;;
    loco-m-xw)
        BOARD=ubnt-loco-m-xw
        ;;
    tl-wa850re)
        BOARD=tl-wa850re-v1
        ;;
    tl-wa860re)
        BOARD=tl-wa860re-v1
        ;;
    tl-wdr3500)
        BOARD=tl-wdr3500-v1
        ;;
    tl-wdr4300)
        grep "3600" /var/sysinfo/model && BOARD=tl-wdr3600-v1
        grep "4300" /var/sysinfo/model && BOARD=tl-wdr4300-v1
        grep "4310" /var/sysinfo/model && BOARD=tl-wdr4310-v1
        ;;
    tl-mr3020)
        BOARD=tl-mr3020-v1
        ;;
    cpe510)
        grep "CPE210" /var/sysinfo/model && BOARD=cpe210
        ;;
esac

if ! uci get board.model.name; then
    uci set board.model.name=$BOARD
fi

. /etc/network.$BOARD

. /etc/network.sh

# Starting NTP-Client Daemon after 30s to ensure that the interface is up
( sleep 30 ; ntpd -p ${NTPD_IP} ) &

/etc/init.d/qos disable
/etc/init.d/qos stop

touch /tmp/started

exit 0
