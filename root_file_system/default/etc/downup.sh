ipv6_link_local_addr="`ifconfig br-mesh | grep 'inet6 addr:' | grep 'Scope:Link' | awk '{ print $3}'`"

ipv6_link_local_addr="`echo $ipv6_link_local_addr | cut -d/ -f1`"

ping_result="`ping6 -I br-mesh $ipv6_link_local_addr`"

ping_result="`echo $ping_result | grep 'bad address'`"

ping_result="`$ping_result | awk '{ print $2}'`"

echo $ping_result

if [ "$ping_result"=="ping6\: sendto\: Cannot assign requested address" ]; then
	echo "down"
	ifconfig br-mesh down
	ifconfig br-mesh up
else
	echo "up"
fi
