# Tahap verifikasi dan pembuktian menyeluruh untuk seluruh client di Network 2 (Divisi A) dan Network 3 (Divisi B).

#!/bin/bash
echo "=== 1. RENEEW LEASE ==="
ifdown eth0 && ifup eth0

echo -e "\n=== 2. IP ADDRESS & BROADCAST ==="
ip a show eth0 | grep "inet "

echo -e "\n=== 3. ROUTING & GATEWAY ==="
ip route | grep default

echo -e "\n=== 4. DNS RESOLVER & SEARCH DOMAIN ==="
cat /etc/resolv.conf