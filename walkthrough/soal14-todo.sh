#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Harap jalankan script ini sebagai root (sudo)!"
  exit 1
fi

echo "[1/4] Menginstal Nginx, PHP 8.4-FPM, dan Ekstensi MySQLi..."
apt update
apt install -y nginx php8.4-fpm php8.4-mysqli

echo "[2/4] Membersihkan file default dan membuat api.php dengan database logging..."
rm -f /var/www/html/index.nginx-debian.html
cat << 'EOF' > /var/www/html/api.php
<?php
header('Content-Type: application/json');

$host = '10.71.4.8';          // IP Master DB (yaga)
$db   = 'db_shibuya_k15';     // Nama database
$user = 'root';
$pass = 'password123';        // Password database

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["error" => "Connection failed: " . $conn->connect_error]);
    exit();
}

$endpoint = $_SERVER['REQUEST_URI'] ?? '/api.php';
$client_ip = $_SERVER['REMOTE_ADDR'] ?? 'UNKNOWN';

$endpoint = $conn->real_escape_string($endpoint);
$client_ip = $conn->real_escape_string($client_ip);

$sql = "INSERT INTO request_logs (endpoint, client_ip) VALUES ('$endpoint', '$client_ip')";
$conn->query($sql);

echo json_encode([
    "status" => "success", 
    "worker" => gethostname(), 
    "client_ip" => $client_ip
]);

$conn->close();
?>
EOF

echo "[3/4] Mengonfigurasi Nginx & Restriksi Akses (Hanya izinkan geto)..."
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.php index.html index.htm;

    server_name _;

    # Restriksi: Blokir akses langsung dari luar, izinkan geto
    allow 10.71.4.2;  # Ganti dengan IP geto jika berbeda
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

echo "=== Selesai! API Worker $(hostname) siap digunakan ==="