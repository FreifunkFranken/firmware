#!/bin/sh

SERVER="no"
#SERVERNAME="--servername--"

project="${VPN_PROJECT}"

test_ipv4_host1="mastersword.de"
test_ipv4_host2="109.163.229.254"
test_ipv6_host1="heise.de"

if [ "$SERVER" = "no" ]; then
	test -f /tmp/started || exit
fi

# Only do something with fastd when the router has internet connection
if ping -w5 -c3 "$test_ipv4_host1" &>/dev/null || 
   ping -w5 -c3 "$test_ipv4_host2" &>/dev/null ||
   ping6 -w5 -c3 "$test_ipv6_host1" &>/dev/null; then
	mac=$(awk '{ mac=toupper($1); gsub(":", "", mac); print mac }' /sys/class/net/br-mesh/address 2>/dev/null)
	if [ "$SERVER" = "no" ]; then
		hostname=$(cat /proc/sys/kernel/hostname)

		if [ "$hostname" = "OpenWrt" ]; then
			hostname=""
		fi

		if [ "$hostname" = "" ]; then
			hostname=$mac
		fi
	else
		hostname=$SERVERNAME
	fi

	if [ ! -d /etc/fastd ]; then
		mkdir /etc/fastd
	fi

	if [ ! -d /etc/fastd/$project ]; then
		mkdir /etc/fastd/$project

		mkdir /tmp/fastd_${project}_peers
		ln -s /tmp/fastd_${project}_peers /etc/fastd/$project/peers
		echo "#!/bin/sh" > /etc/fastd/$project/up.sh
		echo "ip link set up dev ${project}VPN" >> /etc/fastd/$project/up.sh
		echo "echo enable > /sys/devices/virtual/net/${project}VPN/batman_adv/no_rebroadcast" >> /etc/fastd/$project/up.sh
		echo "batctl if add ${project}VPN" >> /etc/fastd/$project/up.sh
		chmod +x /etc/fastd/$project/up.sh

		secret=$(fastd --generate-key 2>&1 | grep -i secret | awk '{ print $2 }')
		echo "include peers from \"/etc/fastd/$project/peers\";" >> /etc/fastd/${project}/${project}.conf
		echo "log to syslog level warn;" >> /etc/fastd/${project}/${project}.conf
		echo "method \"null\";" >> /etc/fastd/${project}/${project}.conf
#		http://lists.nord-west.net/pipermail/freifunk-ol-dev/2013-July/000322.html
#		echo "bind 0.0.0.0:10000;" >> /etc/fastd/${project}/${project}.conf
		echo "interface \"${project}VPN\";" >> /etc/fastd/${project}/${project}.conf
		echo "mtu 1426;" >> /etc/fastd/${project}/${project}.conf
		echo "secret \"$secret\";" >> /etc/fastd/${project}/${project}.conf
		echo "on up \"/etc/fastd/${project}/up.sh\";" >> /etc/fastd/${project}/${project}.conf
		echo "secure handshakes no;" >> /etc/fastd/${project}/${project}.conf
	fi

	if [ ! -d /tmp/fastd_${project}_peers ]; then
		mkdir /tmp/fastd_${project}_peers
	fi	

	pubkey=$(fastd -c /etc/fastd/$project/$project.conf --show-key --machine-readable)
#	port=666


#	fire up
	if [ "$(/sbin/ifconfig -a | grep -i ethernet | grep $project)" = "" ]; then
		/bin/rm /var/run/fastd.$project.pid
		fastd -c /etc/fastd/$project/$project.conf -d --pid-file /var/run/fastd.$project.pid
	fi

#	register
	wget -T15 "http://mastersword.de/~reddog/${project}/?mac=$mac&name=$hostname&port=$port&key=$pubkey" -O /tmp/fastd_${project}_output

	filenames=$(awk '/^####/ { gsub(/^####/, "", $0); gsub(/.conf/, "", $0); print $0; }' /tmp/fastd_${project}_output)
	for file in $filenames; do
		awk "{ if(a) print }; /^####$file.conf$/{a=1}; /^$/{a=0};" /tmp/fastd_${project}_output | sed 's/ float;/;/g' > /etc/fastd/$project/peers/$file
		echo 'float yes;' >> /etc/fastd/$project/peers/$file
	done

	#reload
	kill -HUP $(cat /var/run/fastd.$project.pid)
else
	echo "Der Router kann keine Verbindung zum Fastdserver aufbauen"
	echo "$0 macht nichts!"
fi

exit 0
# vim: noexpandtab
