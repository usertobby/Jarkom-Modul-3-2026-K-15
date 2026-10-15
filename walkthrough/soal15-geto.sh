#!/bin/bash

# Pastikan variabel IP node worker disesuaikan
IP_NANAMI="10.71.4.5"
IP_TODO="10.71.4.6"

CONFIG_FILE="/etc/nginx/sites-available/api"
SYMLINK_FILE="/etc/nginx/sites-enabled/api"

echo "[*] Membuat file konfigurasi Nginx upstream..."
cat <<EOF > "$CONFIG_FILE"
upstream api_cluster {
    server $IP_NANAMI:80 weight=3;
    server $IP_TODO:80 weight=1;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

echo "[*] Membuat symbolic link ke sites-enabled..."
if [ ! -L "$SYMLINK_FILE" ]; then
    ln -s "$CONFIG_FILE" "$SYMLINK_FILE"
fi

echo "[*] Melakukan testing konfigurasi Nginx..."
nginx -t

if [ $? -eq 0 ]; then
    echo "[*] Konfigurasi valid, merestart Nginx..."
    service nginx restart
    echo "[+] Nginx berhasil direstart!"
    
    echo "[*] Menjalankan uji coba load balancing (8 request)..."
    for i in {1..8}; do 
        curl -s http://localhost/api.php
        echo ""
    done
else
    echo "[-] Konfigurasi Nginx gagal, silakan periksa kembali."
fi