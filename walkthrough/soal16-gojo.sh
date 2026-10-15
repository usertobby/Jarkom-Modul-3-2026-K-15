#!/bin/bash

echo "[*] Menginstal Nginx di Gojo (jika belum ada)..."
apt-get update && apt-get install -y nginx

echo "[*] Menulis konfigurasi Nginx di Gojo..."
cat << 'EOF' > /etc/nginx/sites-available/default
upstream frontend_cluster {
    server 10.71.4.3; # Ganti dengan IP maki
    server 10.71.4.4; # Ganti dengan IP panda
}

upstream api_gateway {
    server 10.71.4.2; # Ganti dengan IP geto
}

server {
    listen 80;
    server_name jujutsu.k15.com www.jujutsu.k15.com;

    # Routing ke frontend cluster secara round-robin
    location / {
        proxy_pass http://frontend_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Routing path /api diteruskan ke internal load balancer (geto)
    location /api {
        proxy_pass http://api_gateway;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

echo "[*] Menguji dan me-restart Nginx Gojo..."
nginx -t && service nginx restart
echo "[+] Konfigurasi Gojo selesai!"