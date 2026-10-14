#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Harap jalankan script ini sebagai root (sudo)!"
  exit 1
fi

echo "[1/3] Menginstal Nginx..."
apt update
apt install -y nginx

echo "[2/3] Mengonfigurasi Nginx sebagai Reverse Proxy untuk Frontend (maki & panda)..."
cat << 'EOF' > /etc/nginx/sites-available/default
upstream web_frontend {
    server 10.71.x.x:80;  # Ganti dengan IP worker maki
    server 10.71.x.x:80;  # Ganti dengan IP worker panda
}

server {
    listen 80;
    server_name jujutsu.k15.com www.jujutsu.k15.com; # Sesuaikan domain jika ada

    location / {
        proxy_pass http://web_frontend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

echo "[3/3] Menyalakan dan merestart Nginx..."
systemctl start nginx && systemctl enable nginx
nginx -t && systemctl restart nginx

echo "=== Selesai! Node Gojo (Public Reverse Proxy) siap digunakan ==="