#!/bin/sh

wget -T15 http://[`uci get configurator.@api[0].ipv6_address`%`uci get configurator.@api[0].ipv6_interface`]/api_nodewatcher.php?section=get_hostnames_and_mac -O - | grep -v -e "^..-..-" | sort -u > /tmp/bat-hosts