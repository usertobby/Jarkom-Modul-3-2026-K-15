#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Harap jalankan script ini sebagai root (sudo)!"
  exit 1
fi

echo "[1/3] Menginstal Nginx..."
apt update
apt install -y nginx

echo "[2/3] Mengonfigurasi Nginx sebagai Weighted Load Balancer (nanami & todo)..."
cat << 'EOF' > /etc/nginx/sites-available/default
upstream api_backend {
    server 10.71.x.x:80 weight=3;  # Ganti dengan IP worker nanami (bobot 3)
    server 10.71.x.x:80 weight=1;  # Ganti dengan IP worker todo (bobot 1)
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

echo "[3/3] Menyalakan dan merestart Nginx..."
systemctl start nginx && systemctl enable nginx
nginx -t && systemctl restart nginx

echo "=== Selesai! Node Geto (Internal Load Balancer) siap digunakan ==="