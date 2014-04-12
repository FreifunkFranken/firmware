
config system
	option hostname 'OpenWrt'
	option timezone 'CET-1CEST,M3.5.0,M10.5.0/3'

config rdate
	option interface 'wan'

config led 'status_led'
	option name 'status'
	option sysfs 'tp-link:green:system'
	option trigger 'heartbeat'

config led 'led_vpn'
	option name 'VPN'
	option sysfs 'tp-link:green:qss'
	option trigger 'netdev'
	option dev '${VPN_PROJECT}VPN'
	option mode 'link'
