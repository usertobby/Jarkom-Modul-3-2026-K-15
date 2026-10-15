#!/bin/bash

# ==========================================
# Script Konfigurasi Frontend Node (Maki & Panda)
# ==========================================

echo "[*] Menginstal Nginx di Node Frontend..."
apt-get update
apt-get install -y nginx

echo "[*] Membuat direktori web root..."
mkdir -p /var/www/html

echo "[*] Membuat halaman sambutan HTML..."
# Kamu bisa menyesuaikan isi pesan HTML ini sesuai identitas nodenya (maki atau panda)
HOSTNAME=$(hostname)
cat << EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Shibuya Project - Frontend ($HOSTNAME)</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; background-color: #f4f4f9; }
        h1 { color: #333; }
        p { color: #666; }
    </style>
</head>
<body>
    <h1>Welcome to Shibuya Project Frontend</h1>
    <p>Served successfully by node: <strong>$HOSTNAME</strong></p>
</body>
</html>
EOF

echo "[*] Mengonfigurasi Nginx..."
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    root /var/www/html;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

echo "[*] Menguji dan me-restart Nginx..."
nginx -t
service nginx restart

echo "[+] Konfigurasi Frontend ($HOSTNAME) selesai!"