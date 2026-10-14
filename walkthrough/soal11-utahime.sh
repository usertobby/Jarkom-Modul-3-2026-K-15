#!/bin/bash

# Update dan instalasi BIND9
apt-get update
apt-get install -y bind9 bind9utils dnsutils

# Konfigurasi named.conf.local untuk Master
cat << 'EOF' > /etc/bind/named.conf.local
zone "jujutsu.k15.com" {
    type master;
    file "/etc/bind/db.jujutsu.k15.com";
    allow-transfer { 10.71.1.3; }; # Sesuaikan IP Shoko jika berbeda
};
EOF

# Membuat file zona domain
cat << 'EOF' > /etc/bind/db.jujutsu.k15.com
$TTL 604800
@   IN  SOA ns1.jujutsu.k15.com. admin.jujutsu.k15.com. (
        2026101401 ; Serial
        60480       ; Refresh
        8640        ; Retry
        2419200     ; Expire
        604800 )    ; Negative Cache TTL

@   IN  NS  ns1.jujutsu.k15.com.
@   IN  NS  ns2.jujutsu.k15.com.

ns1 IN  A   10.71.1.2   ; Sesuaikan IP utahime
ns2 IN  A   10.71.1.3   ; Sesuaikan IP shoko
@   IN  A   10.71.1.4   ; Sesuaikan IP gojo
EOF

# Restart service BIND9 (menggunakan named)
service named restart