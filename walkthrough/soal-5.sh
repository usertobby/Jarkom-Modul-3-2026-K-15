#!/bin/bash

# MAC Address Divisi A
MAC_ITADORI="02:42:61:e0:c8:00"
MAC_FUSHIGURO="02:42:66:fb:59:00"
MAC_ZENIN="02:42:a6:5e:d1:00"
MAC_OKKOTSU="02:42:7c:c6:8b:00"

# MAC Address Divisi B
MAC_INO="02:42:67:1f:ac:00"
MAC_KUSAKABE="02:42:4c:8d:e1:00"
MAC_MIWA="02:42:f6:6d:6f:00"

cat << DHCP_CONF > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;
authoritative;

# Global DHCP Options
option domain-name-servers 10.71.1.2, 10.71.1.3;
option domain-name "k15.com";
option domain-search "k15.com";

# ----------------------------------------------------
# 1. Deklarasi DHCP Class Divisi A (Network 2)
# ----------------------------------------------------
class "Dev" { match hardware; }
class "Support" { match hardware; }

subclass "Dev" 1:${MAC_ITADORI};
subclass "Dev" 1:${MAC_FUSHIGURO};
subclass "Support" 1:${MAC_ZENIN};
subclass "Support" 1:${MAC_OKKOTSU};

# ----------------------------------------------------
# 2. Deklarasi DHCP Class Divisi B (Network 3)
# ----------------------------------------------------
class "ShortLease" { match hardware; }
class "LongLease" { match hardware; }

subclass "ShortLease" 1:${MAC_INO};
subclass "ShortLease" 1:${MAC_KUSAKABE};
subclass "LongLease" 1:${MAC_MIWA};

# ----------------------------------------------------
# 3. Subnet Data Center (Network 4)
# ----------------------------------------------------
subnet 10.71.4.0 netmask 255.255.255.0 {
}

# ----------------------------------------------------
# 4. Scope Network 2 (Divisi A)
# ----------------------------------------------------
subnet 10.71.2.0 netmask 255.255.255.0 {
    option routers 10.71.2.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.71.2.255;

    # Pool 1 (Dev)
    pool {
        allow members of "Dev";
        range 10.71.2.10 10.71.2.35;
    }

    # Pool 2 (Support)
    pool {
        allow members of "Support";
        range 10.71.2.70 10.71.2.95;
    }
}

# ----------------------------------------------------
# 5. Scope Network 3 (Divisi B)
# ----------------------------------------------------
subnet 10.71.3.0 netmask 255.255.255.0 {
    option routers 10.71.3.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.71.3.255;

    # Pool Short Lease (1800s / 30m) - ino & kusakabe
    pool {
        allow members of "ShortLease";
        range 10.71.3.10 10.71.3.89;
        default-lease-time 1800;
        max-lease-time 1800;
    }

    # Pool Long Lease (43200s / 12j) - miwa
    pool {
        allow members of "LongLease";
        range 10.71.3.100 10.71.3.199;
        default-lease-time 43200;
        max-lease-time 43200;
    }
}
DHCP_CONF

service isc-dhcp-server restart