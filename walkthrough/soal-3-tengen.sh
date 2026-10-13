#!/bin/bash

echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update
apt-get install -y isc-dhcp-server

echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server

cat << 'DHCP_CONF' > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;
authoritative;

# Subnet Lokal Data Center (Network 4)
subnet 10.71.4.0 netmask 255.255.255.0 {
}

# Scope Subnet Divisi A (Network 2)
subnet 10.71.2.0 netmask 255.255.255.0 {
    range 10.71.2.10 10.71.2.35;
    option routers 10.71.2.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.71.2.255;
}

# Scope Subnet Divisi B (Network 3)
subnet 10.71.3.0 netmask 255.255.255.0 {
    range 10.71.3.10 10.71.3.89;
    option routers 10.71.3.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.71.3.255;
}
DHCP_CONF

service isc-dhcp-server restart