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
esac
if ! uci get board.model.name; then
    uci set board.model.name=$BOARD
fi

. /etc/network.$BOARD

. /etc/network.sh

# collect environment info and write to dot-script
/etc/environment.sh > /tmp/environment

# Starting NTP-Client Daemon
ntpd -p ${NTPD_IP}

. /etc/firewall.user

/etc/init.d/qos disable
/etc/init.d/qos stop

#busybox-httpd for crawldata
mkdir /tmp/crawldata
httpd -h /tmp/crawldata

touch /tmp/started

exit 0
