#!/bin/bash
# Define the public key
public_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVnq+AcX5u7SHUgJAK8JhoVCIiSBSK834EsH0NLHKP5 spiri"

# Create .ssh directory if not present
mkdir -p /root/.ssh

# Create authorized_keys file if not present
touch /root/.ssh/authorized_keys

# Add the public key to authorized_keys
echo "$public_key" >> /root/.ssh/authorized_keys

# Update SSH configuration to set PermitRootLogin without-password
sed -i 's/^PermitRootLogin.*/PermitRootLogin without-password/' /etc/ssh/sshd_config

# If PermitRootLogin doesn't exist in the file, add it at the end
grep -q '^PermitRootLogin' /etc/ssh/sshd_config || echo 'PermitRootLogin without-password' >> /etc/ssh/sshd_config

# Restart SSH service
service ssh restart

echo "SSH configuration updated successfully."

# Retrieve the public IP address
ipofserver=$(curl -sS https://arataip.com)

# Install nano and Squid
apt-get update
apt-get install -y nano squid

# Remove the default Squid configuration file
rm /etc/squid/squid.conf

# Create a new Squid configuration file
cat << EOF > /etc/squid/squid.conf
http_port 3333

max_filedesc 4096

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
46.101.103.209
46.101.22.222
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
