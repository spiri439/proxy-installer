#!/bin/bash

# Install build essentials and other requirements
apt-get update
apt-get install -y wget gcc curl nano make

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

# Download and install 3proxy
wget https://github.com/z3APA3A/3proxy/archive/0.9.4.tar.gz
tar -xvf 0.9.4.tar.gz
cd 3proxy-0.9.4/
make -f Makefile.Linux
make -f Makefile.Linux install

# Create the configuration file
cat <<EOF > /etc/3proxy/3proxy.cfg
daemon
nscache 65536
nserver 8.8.8.8
nserver 8.8.4.4

log /var/log/3proxy-%y%m%d.log D
rotate 30
auth iponly

# allowed ips
include /etc/3proxy/allowed_ips.list

socks -p3333
EOF

# Create the allowed IPs list file
cat <<EOF > /etc/3proxy/allowed_ips.list
allow * 46.101.103.209
allow * 46.101.22.222
allow * 176.124.104.234
allow * 176.124.104.250
allow * 82.78.126.222
allow * 92.85.160.202
allow * 95.76.142.136
allow * 78.97.158.136
allow * 85.204.12.12
allow * 95.76.141.135
allow * 84.117.17.0
allow * 85.204.15.116
allow * 85.204.13.87
allow * 84.117.64.43
allow * 84.117.17.90
EOF


# Enable and start the 3proxy service
systemctl enable 3proxy
systemctl start 3proxy
