#!/bin/bash -x

# create namespaces
ip netns add vpn
ip netns add tor

# turn on loopback in each
ip netns exec vpn ip link set dev lo up
ip netns exec tor ip link set dev lo up

# create and assign veth pairs
ip link add eth-to-vpn type veth peer name vpn-to-eth
ip link set dev vpn-to-eth netns vpn
ip link set dev eth-to-vpn master br0

ip link add eth-to-tor type veth peer name tor-to-eth
ip link set dev tor-to-eth netns tor
ip link set dev eth-to-tor master br0

# bring up veth cards
ip netns exec vpn ip link set dev vpn-to-eth address 10:02:03:04:05:06
ip netns exec vpn ip link set vpn-to-eth up
ip link set dev eth-to-vpn address 10:20:30:40:50:60
ip link set dev eth-to-vpn up

ip netns exec tor ip link set dev tor-to-eth address 10:07:08:09:11:12
ip netns exec tor ip link set tor-to-eth up
ip link set dev eth-to-tor address 10:22:33:44:55:66
ip link set dev eth-to-tor up

# enable ICMP in each namespace
ip netns exec vpn sysctl -w net.ipv4.ping_group_range="0 1000"
ip netns exec tor sysctl -w net.ipv4.ping_group_range="0 1000"

# get an IP address for each namespace
ip netns exec vpn dhcpcd -n vpn-to-eth
ip netns exec tor dhcpcd -n tor-to-eth

# run OpenVPN in the vpn namespace
ip netns exec vpn openvpn /root/us-free-10.protonvpn.tcp.ovpn &

# run TOR in the tor namespace

