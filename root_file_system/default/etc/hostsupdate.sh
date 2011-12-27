#!/bin/sh

wget -T15 http://$(cat /etc/config/nodewatcher | grep url | awk '{ print $3 }' | sed -e "s/\]'//g" -e "s/'\[//g")/api_nodewatcher.php?section=get_hostnames_and_mac -O - | grep -v -e "^..-..-" | sort -u > /etc/bat-hosts
