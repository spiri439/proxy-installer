#!/bin/bash

# Ask for the number of public IP addresses
read -p "Enter the number of public IP addresses: " ip_count

# Retrieve the public IP addresses
declare -a ipofserver
for i in $(seq 1 $ip_count); do
    read -p "Enter IP address $i: " ipofserver[i]
done

# Install nano and Squid
apt-get update
apt-get install -y nano squid

# Remove the default Squid configuration file
rm /etc/squid/squid.conf

# Start creating a new Squid configuration file
cat << EOF > /etc/squid/squid.conf
http_port 3333

acl Safe_ports port "/etc/squid/Allowed_PORTs.txt"
http_access deny !Safe_ports

acl Allowed_IPs src "/etc/squid/Allowed_IPs.txt"
http_access allow Allowed_IPs
http_access deny all

EOF

# Add each IP to the Squid configuration file
for i in $(seq 1 $ip_count); do
    echo "acl myip$i myip ${ipofserver[i]}" >> /etc/squid/squid.conf
    echo "tcp_outgoing_address ${ipofserver[i]} myip$i" >> /etc/squid/squid.conf
done

# Add the rest of the Squid configuration
cat << EOF >> /etc/squid/squid.conf
request_header_access Authorization allow all
request_header_access Proxy-Authorization allow all
request_header_access Cache-Control allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Charset allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Connection allow all
request_header_access All deny all

reply_header_access Allow allow all
reply_header_access WWW-Authenticate allow all
reply_header_access Proxy-Authenticate allow all
reply_header_access Cache-Control allow all
reply_header_access Content-Encoding allow all
reply_header_access Content-Length allow all
reply_header_access Content-Type allow all
reply_header_access Date allow all
reply_header_access Expires allow all
reply_header_access Last-Modified allow all
reply_header_access Location allow all
reply_header_access Pragma allow all
reply_header_access Content-Language allow all
reply_header_access Retry-After allow all
reply_header_access Title allow all
reply_header_access Content-Disposition allow all
reply_header_access Connection allow all
reply_header_access All deny all

via off
forwarded_for delete
EOF

# Create the Allowed_IPs.txt file
cat << EOF > /etc/squid/Allowed_IPs.txt
176.124.104.234
176.124.104.250
82.78.126.222
92.85.160.202
95.76.142.136
78.97.158.136
85.204.12.12
95.76.141.135
84.117.17.0
85.204.15.116
85.204.13.87
84.117.64.43
84.117.17.90
EOF

# Create the Allowed_PORTs.txt file
cat << EOF > /etc/squid/Allowed_PORTs.txt
80
443
25
2525
465
587
EOF

# Reload Squid service
systemctl reload squid

echo "Squid installation and configuration completed."
