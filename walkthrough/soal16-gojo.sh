#!/bin/bash

# --- KONFIGURASI KELOMPOK K15 ---
# Sesuaikan IP address node maki, panda, dan geto berikut dengan topologi GNS3 kamu
IP_MAKI="10.71.4.3"
IP_PANDA="10.71.4.4"
IP_GETO="10.71.7.2"

# Domain disesuaikan untuk kelompok k15
DOMAIN="jujutsu.k15.com"
WWW_DOMAIN="www.jujutsu.k15.com"

CONFIG_FILE="/etc/nginx/sites-available/jujutsu"
SYMLINK_FILE="/etc/nginx/sites-enabled/jujutsu"

echo "[*] Memulai konfigurasi Path-Based Routing Nginx di gojo untuk K15..."

# 1. Membuat file konfigurasi Nginx
cat <<EOF > "$CONFIG_FILE"
upstream frontend_cluster {
    server $IP_MAKI:80;
    server $IP_PANDA:80;
}

upstream backend_api {
    server $IP_GETO:80;
}

server {
    listen 80;
    server_name $DOMAIN $WWW_DOMAIN;

    # Routing untuk root (/) ke frontend cluster (Round Robin: maki & panda)[cite: 10, 15]
    location / {
        proxy_pass http://frontend_cluster;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # Routing untuk path (/api) langsung ke internal load balancer (geto)[cite: 10, 15]
    location /api {
        proxy_pass http://backend_api;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

echo "[+] File konfigurasi berhasil dibuat di $CONFIG_FILE"

# 2. Membuat symlink ke sites-enabled dan menghapus default
if [ ! -L "$SYMLINK_FILE" ]; then
    ln -s "$CONFIG_FILE" "$SYMLINK_FILE"
    echo "[+] Symlink berhasil dibuat."
fi

if [ -f "/etc/nginx/sites-enabled/default" ]; then
    rm -f "/etc/nginx/sites-enabled/default"
    echo "[+] Konfigurasi default Nginx dihapus."
fi

# 3. Uji sintaks dan restart layanan Nginx
echo "[*] Menguji validasi konfigurasi Nginx..."
nginx -t

if [ $? -eq 0 ]; then
    echo "[+] Sintaks Nginx valid. Melakukan restart service..."
    service nginx restart
    echo "[SUCCESS] Konfigurasi Soal 16 pada node gojo berhasil diterapkan!"
else
    echo "[-] ERROR: Terdapat kesalahan pada sintaks konfigurasi Nginx."
    exit 1
fi