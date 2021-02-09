#!/bin/sh
# This enables PoE passthrough permanently, so it is persistent
# during firmware upgrades

uci -q set "fff.poe_passthrough=fff"
uci -q set "fff.poe_passthrough.active=1"
uci -q commit fff

/usr/lib/fff-support/activate_poe_passthrough.sh
