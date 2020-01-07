#!/bin/sh

if pgrep babeld >/dev/null; then
	neighbours="$(echo dump | nc ::1 33123 | grep '^add neighbour' |
		awk '{
				for (i=2; i < NF; i += 2) {
					vars[$i] = $(i+1)
				}
			}
			{
				printf "<neighbour><ip>%s</ip><outgoing_interface>%s</outgoing_interface><link_cost>%s</link_cost></neighbour>", vars["address"], vars["if"], vars["cost"]
			}')"
	echo -n "<babel_neighbours>$neighbours</babel_neighbours>"
fi

exit 0
