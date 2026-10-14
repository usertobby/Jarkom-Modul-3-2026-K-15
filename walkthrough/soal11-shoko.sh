#!/bin/bash

# Update dan instalasi BIND9
apt-get update
apt-get install -y bind9 bind9utils dnsutils

# Konfigurasi named.conf.local untuk Slave
cat << 'EOF' > /etc/bind/named.conf.local
zone "jujutsu.k15.com" {
    type slave;
    file "/var/cache/bind/db.jujutsu.k15.com";
    masters { 10.71.1.2; }; # Sesuaikan IP Utahime
};
EOF

# Restart service BIND9 (menggunakan named)
service named restart