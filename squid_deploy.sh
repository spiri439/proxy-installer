#!/bin/bash

# Retrieve the public IP address
ipofserver=$(curl -sS https://api.ipify.org)

# Install nano and Squid
apt-get update
apt-get install -y nano squid

# Remove the default Squid configuration file
rm /etc/squid/squid.conf

# Create a new Squid configuration file
cat << EOF > /etc/squid/squid.conf
http_port 3333

acl Safe_ports port "/etc/squid/Allowed_PORTs.txt"
http_access deny !Safe_ports

acl Allowed_IPs src "/etc/squid/Allowed_IPs.txt"
http_access allow Allowed_IPs
http_access deny all

acl myip1 myip $ipofserver
tcp_outgoing_address $ipofserver myip1

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
