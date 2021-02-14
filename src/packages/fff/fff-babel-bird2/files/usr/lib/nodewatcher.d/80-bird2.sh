#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-only

set -e
set -o pipefail


if ! birdc show status >/dev/null 2>&1; then
	# bird daemon not running or unavailable. exit.
	exit 0
fi

neighbours="$(birdc -r show babel neighbors |
		tail -n +5 |
		awk '{ printf "<neighbour><ip>%s</ip><outgoing_interface>%s</outgoing_interface><link_cost>%s</link_cost></neighbour>", $1, $2, $3 }'
	)"

echo -n "<babel_neighbours>$neighbours</babel_neighbours>"

exit 0
