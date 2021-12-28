#!/bin/sh
ipv4dest=$(uci -q get fff.latency.ipv4)
ipv6dest=$(uci -q get fff.latency.ipv6)
if [ -n "$ipv4dest" ] || [ -n "$ipv6dest" ] ; then
        printf "<latency>"

        if [ -n "$ipv4dest" ] ; then
                ipv4latency=$(ping -qc3 -4 $ipv4dest 2>&1 | awk -F'/' 'END{ print (/^round-trip/? $4:"0") }')
                printf "<ipv4latency>$ipv4latency</ipv4latency><ipv4dest>$ipv4dest</ipv4dest>"
        fi

        if [ -n "$ipv6dest" ] ; then
                ipv6latency=$(ping -qc3 -6 $ipv6dest 2>&1 | awk -F'/' 'END{ print (/^round-trip/? $4:"0") }')
                printf "<ipv6latency>$ipv6latency</ipv6latency><ipv6dest>$ipv6dest</ipv6dest>"
        fi

        printf "</latency>"
fi
exit 0
