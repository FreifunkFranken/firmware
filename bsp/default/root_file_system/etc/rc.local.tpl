# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

# collect environment info and write to dot-script
/etc/environment.sh > /tmp/environment

. /etc/rc.local.board

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
