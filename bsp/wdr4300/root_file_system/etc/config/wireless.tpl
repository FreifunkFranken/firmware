config wifi-device  radio0
	option type     mac80211
	option channel  ${BATMAN_CHANNEL}
	option phy      phy0
	option hwmode   11g
	option htmode   HT20
	option country  DE

config wifi-iface 'w2mesh'
	option device   radio0
	option network  w2mesh
	option ifname   w2mesh
	option mode     adhoc
	option bssid    '${BSSID_MESH}'
	option ssid     '${ESSID_MESH}'
	option mcast_rate 6000
	option 'encryption' 'none'
	option 'hidden' '1'

config wifi-iface 'w2ap'
	option device   radio0
	option network  mesh
	option ifname   w2ap
	option mode     ap
	option ssid     '${ESSID_AP}'
	option 'encryption' 'none'

config wifi-device  radio1
	option type     mac80211
	option channel  ${BATMAN_CHANNEL_5GHZ}
	option phy      phy1
	option hwmode   11a
	option htmode   HT40+
	option country  DE

config wifi-iface 'w5mesh'
	option device   radio1
	option network  w5mesh
	option ifname   w5mesh
	option mode     adhoc
	option bssid    '${BSSID_MESH}'
	option ssid     '${ESSID_MESH}'
	option mcast_rate 6000
	option 'encryption' 'none'
	option 'hidden' '1'

config wifi-iface 'w5ap'
	option device   radio1
	option network  mesh
	option ifname   w5ap
	option mode     ap
	option ssid     '${ESSID_AP}'
	option 'encryption' 'none'

# vim: noexpandtab