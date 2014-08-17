if ! uci get nodewatcher.@network[0].client_interfaces; then
    echo "Setting nodewatchers client interfaces to: $CLIENTIF"
    uci set nodewatcher.@network[0].client_interfaces="$CLIENTIF"
    uci commit
fi

if ! uci get network.$SWITCHDEV.ifname; then

    SWITCHHW=$(swconfig list | awk '{ print $4 }')

    uci set network.$SWITCHDEV=switch
    uci set network.$SWITCHDEV.name=$SWITCHHW
    uci set network.$SWITCHDEV.enable=1
    uci set network.$SWITCHDEV.reset=1
    uci set network.$SWITCHDEV.enable_vlan=1

    uci set network.${SWITCHDEV}_1=switch_vlan
    uci set network.${SWITCHDEV}_1.device=$SWITCHHW
    uci set network.${SWITCHDEV}_1.vlan=1
    uci set network.${SWITCHDEV}_1.ports="$CLIENT_PORTS"

    echo "# Allow IPv6 RAs on WAN Port" >> /etc/sysctl.conf

    if [[ "$WANDEV" = "$SWITCHDEV" ]]; then
        uci set network.${SWITCHDEV}_2=switch_vlan
        uci set network.${SWITCHDEV}_2.device=$SWITCHHW
        uci set network.${SWITCHDEV}_2.vlan=2
        uci set network.${SWITCHDEV}_2.ports="$WAN_PORTS"

        echo "net.ipv6.conf.$WANDEV.2.accept_ra_defrtr = 1" >> /etc/sysctl.conf
        echo "net.ipv6.conf.$WANDEV.2.accept_ra_pinfo = 1" >> /etc/sysctl.conf
        echo "net.ipv6.conf.$WANDEV.2.autoconf = 1" >> /etc/sysctl.conf
        echo "net.ipv6.conf.$WANDEV.2.accept_ra_rtr_pref = 1" >> /etc/sysctl.conf
    else
        echo "net.ipv6.conf.$WANDEV.accept_ra_defrtr = 1" >> /etc/sysctl.conf
        echo "net.ipv6.conf.$WANDEV.accept_ra_pinfo = 1" >> /etc/sysctl.conf
        echo "net.ipv6.conf.$WANDEV.autoconf = 1" >> /etc/sysctl.conf
        echo "net.ipv6.conf.$WANDEV.accept_ra_rtr_pref = 1" >> /etc/sysctl.conf
    fi
    
    uci set network.${SWITCHDEV}_3=switch_vlan
    uci set network.${SWITCHDEV}_3.device=$SWITCHHW
    uci set network.${SWITCHDEV}_3.vlan=3
    uci set network.${SWITCHDEV}_3.ports="$BATMAN_PORTS"

    uci set network.mesh.ifname="$SWITCHDEV.1 bat0"

    uci set network.ethmesh.ifname="$SWITCHDEV.3"

    if [[ "$WANDEV" = "$SWITCHDEV" ]]; then
        uci set network.wan.ifname=$WANDEV.2
    else
        uci set network.wan.ifname=$WANDEV
    fi

    uci commit
    /etc/init.d/network restart
fi

if [[ -n "$ETHMESHMAC" ]]; then
    if uci get network.ethmesh.macaddr
    then
        echo "MAC for ethmesh is set already"
    else
        echo "Fixing MAC on eth0.3 (ethmesh)"
        sleep 10
        NEW_MACADDR=$(cat /sys/class/net/$ETHMESHMAC/address)
        uci set network.ethmesh.macaddr=$NEW_MACADDR
        uci commit
        ifconfig eth0.3 down
        ifconfig eth0.3 hw ether $NEW_MACADDR
        ifconfig eth0.3 up
        /etc/init.d/network restart
    fi
fi

if [[ -n "$ROUTERMAC" ]]; then
    if uci get network.mesh.macaddr
    then
        echo "MAC for mesh is set already"
    else
        echo "Fixing MAC on br-mesh (mesh)"
        sleep 10
        NEW_MACADDR=$(cat /sys/class/net/$ROUTERMAC/address)
        uci set network.mesh.macaddr=$NEW_MACADDR
        uci commit
        ifconfig br-mesh down
        ifconfig br-mesh hw ether $NEW_MACADDR
        ifconfig br-mesh up
        /etc/init.d/network restart
    fi
fi
