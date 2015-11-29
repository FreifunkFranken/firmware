#!/bin/sh
# Freifunk Franken Random Number Script
# Tim Niemeyer
# 29.11.2015
# License GPLv2

FROM=${1:-0}
UNTIL=${2:-100}

diff=$(( UNTIL - FROM ))
numbers=$(( $(echo $diff | wc -c) -1 ))

rand=$(</dev/urandom tr -dc 0-9 | head -c $numbers | sed -e 's/^0*//g')

echo $(( (rand % diff) + FROM ))

