config 'system'
	option 'hostname' 'OpenWrt'
	option 'timezone' 'CET-1CEST,M3.5.0,M10.5.0/3'
	option 'factory' '1'

config 'led' 'status_led_green'
	option 'name' 'status'
	option 'sysfs' 'tp-link:green:system'
	option 'trigger' 'heartbeat'

config 'led' 'status_led_blue'
	option 'name' 'status'
	option 'sysfs' 'tp-link:blue:system'
	option 'trigger' 'heartbeat'

config 'led' 'led_vpn_green'
	option 'name' 'VPN'
	option 'sysfs' 'tp-link:green:qss'
	option 'trigger' 'netdev'
	option 'dev' '${VPN_PROJECT}VPN'
	option 'mode' 'link'

config 'led' 'led_vpn_blue'
	option 'name' 'VPN'
	option 'sysfs' 'tp-link:blue:qss'
	option 'trigger' 'netdev'
	option 'dev' '${VPN_PROJECT}VPN'
	option 'mode' 'link'

# vim: noexpandtab
