#!/bin/bash

# ==========================================
# Script Konfigurasi Worker API
# ==========================================

echo "[*] Menginstal Nginx, PHP, dan ekstensi MySQL/MariaDB..."
apt-get update
apt-get install -y nginx php8.4-fpm php8.4-mysql

echo "[*] Membuat direktori web root untuk API..."
mkdir -p /var/www/html/api

echo "[*] Membuat script index.php endpoint API..."
cat << 'EOF' > /var/www/html/api/index.php
<?php
header('Content-Type: application/json');

// Konfigurasi Database ke Node Yaga
$host = '10.71.4.8'; // Ganti dengan IP node yaga
$db   = 'db_shibuya_k15'; // Ganti dengan nama database kelompokmu
$user = 'root';
$pass = ''; // Kosongkan jika root yaga tidak menggunakan password

try {
    // Membuat koneksi PDO
    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Ambil path request saat ini
    $requestPath = $_SERVER['REQUEST_URI'] ?? '/api/';

    // Masukkan log ke database
    $stmt = $pdo->prepare("INSERT INTO request_logs (request_path) VALUES (:path)");
    $stmt->execute(['path' => $requestPath]);

    // Dapatkan nama hostname/worker yang memproses
    $processedBy = gethostname();

    echo json_encode([
        "status" => "success",
        "message" => "Log successfully recorded",
        "processed_by" => $processedBy
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage()
    ]);
}
?>
EOF

echo "[*] Mengonfigurasi Nginx agar mendukung PHP-FPM..."
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    # Konfigurasi khusus untuk file PHP
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm8.4.sock; # Sesuaikan versi PHP jika perlu (misal: php8.2-fpm.sock)
    }
}
EOF

echo "[*] Menguji dan me-restart Nginx & PHP-FPM..."
nginx -t
service nginx restart
service php8.4-fpm restart

echo "[+] Konfigurasi Worker API selesai!"