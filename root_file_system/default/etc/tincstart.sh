#!/bin/sh

#DEBUG="--debug=2"
DEBUG=""
SERVER="no"
SERVERNAME="batgw"

project="batvpn"

test_internet_host1="mastersword.de"
test_internet_host2="78.46.215.78"

#Only do something with tinc when the router has internet connection
if ping -w5 -c3 "$test_internet_host1" &>/dev/null || ping -w5 -c3 "$test_internet_host2" &>/dev/null
then

if [ "$SERVER" == "no" ]
then
	hostname=$(cat /proc/sys/kernel/hostname)

	if [ "$hostname" == "OpenWrt" ]
	then
		hostname=""
	fi

	if [ "$hostname" == "" ]
	then
	  hostname=$(ifconfig br-mesh | grep HWaddr | awk '{ print $5 }'|sed -e 's/://g')
	fi

	if [ "$hostname" == "" ]
	then
		hostname=$(ifconfig eth0 | grep HWaddr | awk '{ print $5 }'|sed -e 's/://g')
	fi

	if [ "$hostname" == "" ]
	then
		hostname=$(ifconfig ath0 | grep HWaddr | awk '{ print $5 }'|sed -e 's/://g')
	fi
else
	hostname=$SERVERNAME
fi

if [ ! -d /etc/tinc ]
then
	mkdir /etc/tinc
fi

if [ ! -d /etc/tinc/$project ]
then
	mkdir /etc/tinc/$project
	ln -s /tmp/tinc_$project.conf /etc/tinc/$project/tinc.conf

	echo -n -e "\n\n" | tincd --pidfile=/var/run/tinc_$project.pid -n $project -K
	kill -HUP $(cat /var/run/tinc_$project.pid)
	sleep 3
	mkdir /tmp/tinc_${project}_hosts
	ln -s /tmp/tinc_${project}_hosts /etc/tinc/$project/hosts
	echo "ifconfig \$INTERFACE up" > /etc/tinc/$project/tinc-up
	if [ "$SERVER" == "no" ]
	then
		echo "brctl addif br-mesh \$INTERFACE" >> /etc/tinc/$project/tinc-up
	fi
	chmod +x /etc/tinc/$project/tinc-up
fi

if [ ! -d /tmp/tinc_${project}_hosts ]
then
	mkdir /tmp/tinc_${project}_hosts
fi	

pubkey=$(for line in $(cat /etc/tinc/$project/rsa_key.pub | sed -e 's/$/%0a/g' | sed -e 's/+/%2b/g' | sed -e 's/ /%20/g'); do echo -n $line; done)
port=666

cat <<EOF > /etc/tinc/$project/tinc.conf
Name = $hostname
Mode = Switch
#PingTimeout = 30
Hostnames = yes
#GraphDumpFile = /tmp/vpn-graph.dot
#TCPOnly = yes
EOF

# we need this only for first startup
if [ ! -f /etc/tinc/$project/hosts/$hostname ]
then
cat <<EOF > /etc/tinc/$project/hosts/$hostname
Address = 0.0.0.0
Port = $port
EOF
cat /etc/tinc/$project/rsa_key.pub >> /etc/tinc/$project/hosts/$hostname
fi

# fire up
if [ "$(ps aux | grep tincd | grep -v grep)" == "" ]
then
	tincd -c /etc/tinc/$project --pidfile=/var/run/tinc_$project.pid --logfile=/var/log/tinc_$project.log $DEBUG
#	sleep 1
#	brctl addif br-mesh tap0
fi

# register
wget -T15 "http://mastersword.de/~reddog/tinc/?name=$hostname&port=$port&key=$pubkey" -O /tmp/tinc_${project}_output

filenames=$(cat /tmp/tinc_${project}_output| grep ^#### | sed -e 's/^####//' | sed -e 's/.conf//g')
for file in $filenames
do
grep -A100 $file /tmp/tinc_${project}_output | grep -v $file | grep -m1 ^### -B100 | grep -v ^### > /etc/tinc/$project/hosts/$file.new
if [ "$(diff /etc/tinc/$project/hosts/$file.new /etc/tinc/$project/hosts/$file 2>&1)" == "" ]
then
/bin/rm /etc/tinc/$project/hosts/$file.new
else
/bin/mv /etc/tinc/$project/hosts/$file.new /etc/tinc/$project/hosts/$file
fi
echo "ConnectTo=$file" >> /etc/tinc/$project/tinc.conf
done

if [ ! -f /etc/tinc/$project/hosts/$hostname ]
then
cat <<EOF > /etc/tinc/$project/hosts/$hostname
Address = 0.0.0.0
Port = $port
EOF
cat /etc/tinc/$project/rsa_key.pub >> /etc/tinc/$project/hosts/$hostname
fi

#reload
kill -HUP $(cat /var/run/tinc_$project.pid)

else
	echo "Der Router kann keine Verbindung zum Tincserver aufbauen"
	echo "Tincstart macht nichts!"
fi

exit 0
