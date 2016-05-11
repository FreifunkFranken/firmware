if [ "$(cat /var/sysinfo/model)" = "TP-Link CPE210 v1.1" ] ; then
  echo 20 > /sys/class/gpio/export
  echo out > /sys/class/gpio/gpio20/direction
  echo 1 > /sys/class/gpio/gpio20/value
fi
