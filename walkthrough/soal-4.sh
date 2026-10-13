#!/bin/bash

# 1. DNS Resolver untuk instalasi paket
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# 2. Update & Install isc-dhcp-server
apt-get update
apt-get install -y isc-dhcp-server

# 3. Set Interface DHCP
echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server

# 4. MAC Address Client Divisi A
MAC_ITADORI="02:42:61:e0:c8:00"
MAC_FUSHIGURO="02:42:66:fb:59:00"
MAC_ZENIN="02:42:a6:5e:d1:00"
MAC_OKKOTSU="02:42:7c:c6:8b:00"

# 5. Tulis file konfigurasi dhcpd.conf
cat << DHCP_CONF > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;
authoritative;

# Deklarasi DHCP Class berbasis MAC Address
class "Dev" {
    match hardware;
}
class "Support" {
    match hardware;
}

# Subclass MAC Address (diwakili prefix 1: untuk Ethernet)
subclass "Dev" 1:${MAC_ITADORI};
subclass "Dev" 1:${MAC_FUSHIGURO};

subclass "Support" 1:${MAC_ZENIN};
subclass "Support" 1:${MAC_OKKOTSU};

# Subnet Lokal Data Center (Network 4)
subnet 10.71.4.0 netmask 255.255.255.0 {
}

# Scope Network 2 (Divisi A)
subnet 10.71.2.0 netmask 255.255.255.0 {
    option routers 10.71.2.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.71.2.255;

    # Pool 1 (Dev): 10.71.2.10 - 10.71.2.35
    pool {
        allow members of "Dev";
        range 10.71.2.10 10.71.2.35;
    }

    # Pool 2 (Support): 10.71.2.70 - 10.71.2.95
    pool {
        allow members of "Support";
        range 10.71.2.70 10.71.2.95;
    }
}

# Scope Network 3 (Divisi B)
subnet 10.71.3.0 netmask 255.255.255.0 {
    range 10.71.3.10 10.71.3.89;
    option routers 10.71.3.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.71.3.255;
}
DHCP_CONF

# 6. Restart Layanan DHCP Server
service isc-dhcp-server restart