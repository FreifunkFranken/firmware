#!/bin/sh
# This enables PoE passthrough so it is persistent through reboots,
# but reset after firmware upgrade

if uci -q get "system.poe_passthrough" > /dev/null ; then
	uci -q set "system.poe_passthrough.value=1"
	uci -q commit system
	/etc/init.d/gpio_switch restart
fi
