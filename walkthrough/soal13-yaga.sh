#!/bin/bash

# Update dan instalasi MariaDB Server
apt-get update
apt-get install -y mariadb-server
service mariadb start

# Membuat direktori untuk log binari
mkdir -p /var/log/mysql
chown -R mysql:mysql /var/log/mysql

# Konfigurasi 50-server.cnf untuk Master
cat << 'EOF' > /etc/mysql/mariadb.conf.d/50-server.cnf
[mysqld]
user            = mysql
pid-file        = /run/mysqld/mysqld.pid
basedir         = /usr
datadir         = /var/lib/mysql
tmpdir          = /tmp
bind-address    = 0.0.0.0
server-id       = 1
log-bin         = /var/log/mysql/mysql-bin.log
skip-name-resolve
EOF

# Restart MariaDB untuk menerapkan konfigurasi
service mariadb restart

# Inisialisasi Database, Tabel, dan User Replikasi via SQL
mysql -u root << 'EOF'
CREATE DATABASE IF NOT EXISTS db_shibuya_k15;
USE db_shibuya_k15;
CREATE TABLE IF NOT EXISTS request_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    endpoint VARCHAR(255),
    client_ip VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE USER IF NOT EXISTS 'replicator'@'%' IDENTIFIED BY 'password123';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
GRANT ALL PRIVILEGES ON db_shibuya_k15.* TO 'root'@'%' IDENTIFIED BY 'password123';
FLUSH PRIVILEGES;
EOF

echo "Setup Master (yaga) Selesai!"