# Ini maksudnya saya masukin satu per satu melalui edit config di GNS3

# jichi (Router Utama & DHCP Relay)
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
up sysctl -w net.ipv4.ip_forward=1
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

auto eth1
iface eth1 inet static
    address 10.71.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.71.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 10.71.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 10.71.4.1
    netmask 255.255.255.0
EOF

# Host Network 1 (DMZ) — Gateway: 10.71.1.1
# utahime (DNS Master)
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.71.1.2
    netmask 255.255.255.0
    gateway 10.71.1.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

# shoko (DNS Slave)
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.71.1.3
    netmask 255.255.255.0
    gateway 10.71.1.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

# gojo (Public Reverse Proxy)
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.71.1.4
    netmask 255.255.255.0
    gateway 10.71.1.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

# Host Network 4 (Data Center) — Gateway: 10.71.4.1
# geto (Internal Load Balancer)
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.71.4.2
    netmask 255.255.255.0
    gateway 10.71.4.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

# maki (Worker Frontend 1)
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.71.4.3
    netmask 255.255.255.0
    gateway 10.71.4.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

# panda (Worker Frontend 2)
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.71.4.4
    netmask 255.255.255.0
    gateway 10.71.4.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

# nanami (Worker API Utama 1)
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.71.4.5
    netmask 255.255.255.0
    gateway 10.71.4.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

# todo (Worker API Utama 2)
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.71.4.6
    netmask 255.255.255.0
    gateway 10.71.4.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

# kirara (Worker API Cadangan)
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.71.4.7
    netmask 255.255.255.0
    gateway 10.71.4.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

# tengen (DHCP Server)
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.71.4.10
    netmask 255.255.255.0
    gateway 10.71.4.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

# yaga (Database Master)
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.71.4.8
    netmask 255.255.255.0
    gateway 10.71.4.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

# inumaki (Database Slave)
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.71.4.9
    netmask 255.255.255.0
    gateway 10.71.4.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

# Untuk saat ini Host Network 2 & 3 di isi berikut saja
# Berlaku untuk:
# itadori, fushiguro (Klien DHCP Pool 1)
# zenin, okkotsu (Klien DHCP Pool 2)
# ino, kusakabe (Klien short lease)
# miwa (Klien long lease)
# kugisaki (Klien fixed address)
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF