#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Harap jalankan script ini sebagai root (sudo)!"
  exit 1
fi

echo "[1/4] Menginstal Nginx dan PHP 8.4-FPM..."
apt update
apt install -y nginx php8.4-fpm

echo "[2/4] Membersihkan file default dan membuat index.php..."
rm -f /var/www/html/index.nginx-debian.html
cat << 'EOF' > /var/www/html/index.php
<?php
echo "Frontend Worker - Hostname: " . gethostname();
?>
EOF

echo "[3/4] Mengonfigurasi Nginx & Restriksi Akses (Hanya izinkan gojo)..."
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.php index.html index.htm;

    server_name _;

    # Restriksi: Blokir akses langsung dari luar, izinkan gojo
    allow 10.71.1.4;  # Ganti dengan IP gojo jika berbeda
    deny all;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
EOF

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "[4/4] Menyalakan dan merestart layanan..."
systemctl start nginx && systemctl enable nginx
systemctl start php8.4-fpm && systemctl enable php8.4-fpm
nginx -t && systemctl restart nginx && systemctl restart php8.4-fpm

echo "=== Selesai! Frontend Worker $(hostname) siap digunakan ==="