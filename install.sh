#!/bin/bash

# Copy script to /usr/local/bin/
sudo cp ./linux-beacon.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/linux-beacon.sh

# Copy configuration file to /etc/
mkdir -p /etc/linux-beacon/
cp *.config /etc/linux-beacon/

# Create systemd service file
cat <<EOF > /etc/systemd/system/linux-beacon.service
[Unit]
Description=linux-beacon service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/linux-beacon.sh
StandardOutput=journal
RemainAfterExit=yes
ExecStop=/usr/bin/sudo /usr/bin/hciconfig $(/usr/bin/hciconfig -a | /usr/bin/grep -e "Type: Primary" | /usr/bin/awk '{print $1}') noleadv
ExecStop=/usr/bin/sudo /usr/bin/hciconfig $(/usr/bin/hciconfig -a | /usr/bin/grep -e "Type: Primary" | /usr/bin/awk '{print $1}') down

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable/start the service
systemctl daemon-reload
systemctl enable linux-beacon.service
systemctl start linux-beacon.service
