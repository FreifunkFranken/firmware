#!/bin/sh
# This disables PoE passthrough permanently

uci -q set "fff.poe_passthrough=fff"
uci -q set "fff.poe_passthrough.active=0"
uci -q commit fff

if uci -q get "system.poe_passthrough" > /dev/null ; then
	uci -q set "system.poe_passthrough.value=0"
	uci -q commit system
	/etc/init.d/gpio_switch restart
fi
