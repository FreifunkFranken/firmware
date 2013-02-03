#!/bin/sh

SERVER="no"
#SERVERNAME="--servername--"

project="ffol"

test_internet_host1="mastersword.de"
test_internet_host2="109.163.229.254"

#Only do something with fastd when the router has internet connection
if ping -w5 -c3 "$test_internet_host1" &>/dev/null || ping -w5 -c3 "$test_internet_host2" &>/dev/null; then
    if [ "$SERVER" == "no" ]; then
        hostname=$(cat /proc/sys/kernel/hostname)

        if [ "$hostname" == "OpenWrt" ]; then
            hostname=""
        fi

        if [ "$hostname" == "" ]; then
            hostname=$(awk '{ if (mac) next; mac=toupper($1); gsub(":", "", mac); print mac }' /sys/class/net/br-mesh/address /sys/class/net/eth0/address /sys/class/net/ath0/address 2>/dev/null)
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
        echo '#!/bin/sh' > /etc/fastd/$project/up.sh
        echo 'ip link set up dev $1' >> /etc/fastd/$project/up.sh
        
        if [ "$SERVER" == "no" ]; then
            echo 'batctl if add $1' >> /etc/fastd/$project/up.sh
            
            secret=$(fastd --generate-key 2>&1 | grep -i secret | awk '{ print $2 }')
            echo "" >> /etc/config/fastd
            echo "config fastd $project" >> /etc/config/fastd
            echo "	option enabled 1" >> /etc/config/fastd
            echo "	list config_peer_dir '/etc/fastd/$project/peers'" >> /etc/config/fastd
            echo "	option syslog_level 'verbose'" >> /etc/config/fastd
            echo "	option method null" >> /etc/config/fastd
            echo "	option mode 'tap'" >> /etc/config/fastd
            echo "	option bind '0.0.0.0:10000'" >> /etc/config/fastd
            echo "	option interface '${project}VPN'" >> /etc/config/fastd
            echo "	option mtu 1426" >> /etc/config/fastd
            echo "	option secret '$secret'" >> /etc/config/fastd
            echo "	option up '/etc/fastd/${project}/up.sh \$1'" >> /etc/config/fastd
        fi
        chmod +x /etc/fastd/$project/up.sh
    fi

    if [ ! -d /tmp/fastd_${project}_peers ]; then
        mkdir /tmp/fastd_${project}_peers
    fi	

    pubkey=$(/etc/init.d/fastd show_key $project)
    #port=666


    # fire up
    if [ "$(/sbin/ifconfig -a | grep -i ethernet | grep $project)" == "" ]; then
        /etc/init.d/fastd start $project
    fi

    # register
    wget -T15 "http://mastersword.de/~reddog/fastd/?name=$hostname&port=$port&key=$pubkey" -O /tmp/fastd_${project}_output

    filenames=$(awk '/^####/ { gsub(/^####/, "", $0); gsub(/.conf/, "", $0); print $0; }' /tmp/fastd_${project}_output)
    for file in $filenames; do
        awk "{ if(a) print }; /^####$file.conf$/{a=1}; /^$/{a=0};" /tmp/fastd_fff_output > /etc/fastd/$project/peers/$file
    done

    #reload
    kill -HUP $(cat /var/run/fastd.$project.pid)
else
	echo "Der Router kann keine Verbindung zum Fastdserver aufbauen"
	echo "$0 macht nichts!"
fi

exit 0
