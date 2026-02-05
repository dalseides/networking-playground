#!/bin/bash -x

ip netns add vpn
ip netns add tor

ip netns exec vpn ip link set dev lo up
ip netns exec tor ip link set dev lo up

ip link add eth-to-vpn type veth peer name vpn-to-eth
ip link set dev vpn-to-eth netns vpn
ip link add eth-to-tor type veth peer name tor-to-eth
ip link set dev tor-to-eth netns tor

ip link set dev eth-to-vpn master br0
ip link set dev eth-to-tor master br0

# ip addr add 10.10.10.1/24 dev eth-to-vpn
# ip addr add 10.10.100.1/24 dev eth-to-tor
# 
# ip netns exec vpn ip addr add 10.10.10.2/24 dev vpn-to-eth
# ip netns exec tor ip addr add 10.10.100.2/24 dev tor-to-eth
# 
# ip netns exec vpn ip route add default via 10.10.10.1 dev vpn-to-eth
# ip netns exec tor ip route add default via 10.10.100.1 dev tor-to-eth

ip netns exec vpn ip link set vpn-to-eth up
ip netns exec tor ip link set tor-to-eth up

ip link set dev eth-to-vpn up
ip link set dev eth-to-tor up

ip netns exec vpn sysctl -w net.ipv4.ping_group_range="0 1000"
ip netns exec tor sysctl -w net.ipv4.ping_group_range="0 1000"

ip netns exec vpn dhclient vpn-to-eth -v
ip netns exec tor dhclient tor-to-eth -v

