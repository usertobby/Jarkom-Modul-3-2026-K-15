#!/bin/bash

# 1. Menambahkan CNAME www pada file zona utama utahime
# (Pastikan nomor serial di dalam file zona sudah dinaikkan, misal dari 2026101401 ke 2026101402)
cat << 'EOF' >> /etc/bind/db.jujutsu.k15.com

www     IN  CNAME   jujutsu.k15.com.
EOF

# 2. Mendaftarkan zona Reverse DNS (PTR) di named.conf.local
cat << 'EOF' >> /etc/bind/named.conf.local

zone "1.71.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.71.1";
};
EOF

# 3. Membuat file zona Reverse DNS (PTR) untuk IP gojo (10.71.1.4)
cat << 'EOF' > /etc/bind/db.10.71.1
$TTL 604800
@   IN  SOA ns1.jujutsu.k15.com. admin.jujutsu.k15.com. (
        2026101401 ; Serial
        60480       ; Refresh
        8640        ; Retry
        2419200     ; Expire
        604800 )    ; Negative Cache TTL

@   IN  NS  ns1.jujutsu.k15.com.
4   IN  PTR jujutsu.k15.com.
EOF

# 4. Mengaktifkan DNS Forwarder dan Rekursi pada named.conf.options
cat << 'EOF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";

    forwarders {
        192.168.122.1;
    };

    recursion yes;
    allow-recursion { any; };

    dnssec-validation auto;
    listen-on { any; };
};
EOF

# 5. Restart layanan BIND9
service named restart