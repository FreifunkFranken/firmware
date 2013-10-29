#!/bin/ash

# functions
#FIXME: define here your favorite methods to get the values
get_wlan_client_interface() {
	echo "wlan0"
}

get_wlan_mesh_interface() {
	echo "wlan0-1"
}

get_eth_client_interface() {
	echo ""
}

get_eth_mesh_interface() {
	echo ""
}

get_bridge_interface() {
	echo "br-mesh"
}

get_batman_interface() {
	echo "bat0"
}

get_vpn_interface() {
	test -f /etc/fastdstart.sh || exit;
	local $(grep -o project=.* /etc/fastdstart.sh)
	echo ${project}VPN | tr -d '"'
}

get_debug_level() {
	echo "0"
}

print_definitions() {
	echo "# interfaces"
	echo "WLAN_CLIENT_INTERFACE=$(get_wlan_client_interface)"
	echo "WLAN_MESH_INTERFACE=$(get_wlan_mesh_interface)"
	echo "ETH_CLIENT_INTERFACE=$(get_eth_client_interface)"
	echo "ETH_MESH_INTERFACE=$(get_eth_mesh_interface)"
	echo "BRIDGE_INTERFACE=$(get_bridge_interface)"
	echo "BATMAN_INTERFACE=$(get_batman_interface)"
	echo "VPN_INTERFACE=$(get_vpn_interface)"
	echo ""
	echo "# variables"
	echo "DEBUG=$(get_debug_level)"
}

# program
print_definitions
