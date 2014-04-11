
if ! uci get network.$SWITCHDEV.ifname; then
    uci set network.$SWITCHDEV=switch
    uci set network.$SWITCHDEV.enable=1
    uci set network.$SWITCHDEV.reset=1
    uci set network.$SWITCHDEV.enable_vlan=1

    uci set network.${SWITCHDEV}_1=switch_vlan
    uci set network.${SWITCHDEV}_1.device=$SWITCHDEV
    uci set network.${SWITCHDEV}_1.vlan=1
    uci set network.${SWITCHDEV}_1.ports="$CLIENT_PORTS"

    echo "# Allow IPv6 RAs on WAN Port" >> /etc/sysctl.conf

    if [[ "$WANDEV" = "$SWITCHDEV" ]]; then
        uci set network.${SWITCHDEV}_2=switch_vlan
        uci set network.${SWITCHDEV}_2.device=$SWITCHDEV
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
    uci set network.${SWITCHDEV}_3.device=$SWITCHDEV
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
    /etc/init.d/network reload
fi
