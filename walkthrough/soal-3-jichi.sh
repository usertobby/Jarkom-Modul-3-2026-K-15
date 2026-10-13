#!/bin/bash

# IP Forwarding & NAT Masquerade
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# Install isc-dhcp-relay
apt-get update
apt-get install -y isc-dhcp-relay

# Konfigurasi Relay menuju tengen (10.71.4.10)
cat << 'RELAY_CONF' > /etc/default/isc-dhcp-relay
SERVERS="10.71.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
RELAY_CONF

# Restart Service Relay
service isc-dhcp-relay restart