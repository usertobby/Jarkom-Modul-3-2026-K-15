#!/bin/bash

echo "[*] Menginstal Nginx di Geto (jika belum ada)..."
apt-get update && apt-get install -y nginx

echo "[*] Menulis konfigurasi Nginx di Geto..."
cat << 'EOF' > /etc/nginx/sites-available/default
upstream api_workers {
    server 10.71.4.5; # Ganti dengan IP nanami
    server 10.71.4.6; # Ganti dengan IP todo
    server 10.71.4.7; # Ganti dengan IP kirara
}

server {
    listen 80;
    server_name _;

    location /api {
        proxy_pass http://api_workers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

echo "[*] Menguji dan me-restart Nginx Geto..."
nginx -t && service nginx restart
echo "[+] Konfigurasi Geto selesai!"