#!/bin/bash

# Update dan instalasi MariaDB Server
apt-get update
apt-get install -y mariadb-server
service mariadb start

# Konfigurasi 50-server.cnf untuk Slave
cat << 'EOF' > /etc/mysql/mariadb.conf.d/50-server.cnf
[mysqld]
user            = mysql
pid-file        = /run/mysqld/mysqld.pid
basedir         = /usr
datadir         = /var/lib/mysql
tmpdir          = /tmp
bind-address    = 0.0.0.0
server-id       = 2
skip-name-resolve
EOF

# Restart MariaDB untuk menerapkan konfigurasi
service mariadb restart

# Menghubungkan Slave ke Master dan Menyalakan Replikasi
# (Ganti MASTER_LOG_FILE dan MASTER_LOG_POS sesuai data dari yaga)
mysql -u root << 'EOF'
STOP SLAVE;
CREATE DATABASE IF NOT EXISTS db_shibuya_k15;
USE db_shibuya_k15;
CREATE TABLE IF NOT EXISTS request_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    endpoint VARCHAR(255),
    client_ip VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CHANGE MASTER TO
    MASTER_HOST='10.71.4.8',
    MASTER_USER='replicator',
    MASTER_PASSWORD='password123',
    MASTER_LOG_FILE='mysql-bin.000001',
    MASTER_LOG_POS=328;

START SLAVE;
EOF

echo "Setup Slave (inumaki) Selesai!"