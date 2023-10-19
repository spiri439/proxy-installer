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

# Ask for the number of IPs
read -p "How many IPs do you want to configure for 3proxy? " ip_count

for i in $(seq 1 $ip_count); do
    # Ask for each IP
    read -p "Enter IP #$i: " ip

    # Generate 3proxy configuration for each IP
    cat <<EOF > /etc/3proxy/3proxy-$ip.cfg
daemon
nscache 65536
nserver 8.8.8.8
nserver 8.8.4.4

log /var/log/3proxy-$ip-%y%m%d.log D
rotate 30
auth iponly

# allowed ips
include /etc/3proxy/allowed_ips.list

internal $ip
external $ip
socks -p3333
EOF

    # Create a systemd service unit for each IP instance
    cat <<EOF > /etc/systemd/system/3proxy-$ip.service
[Unit]
Description=3proxy for IP $ip
After=network.target

[Service]
ExecStart=/usr/local/bin/3proxy /etc/3proxy/3proxy-$ip.cfg
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd and enable the service to start on boot
    systemctl daemon-reload
    systemctl enable 3proxy-$ip
    systemctl start 3proxy-$ip

done

# Create the allowed IPs list file
cat <<EOF > /etc/3proxy/allowed_ips.list
allow * 46.101.103.209
allow * 46.101.22.222
# ... [rest of the IPs]
EOF

echo "3proxy setup completed for all IPs."
