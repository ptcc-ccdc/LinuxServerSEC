#!/bin/bash

# Update the system
echo "Updating the system..."
yum update -y

# Install EPEL repository
echo "Installing EPEL repository..."
yum install -y epel-release

# Install ClamAV
echo "Installing ClamAV..."
yum install -y clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-devel clamav-lib clamav-server-systemd

# Configure ClamAV
echo "Configuring ClamAV..."
cp /usr/share/clamav/template/clamd.conf /etc/clamd.d/clamd.conf
sed -i -e "s/^Example/#Example/" /etc/clamd.d/clamd.conf
sed -i -e "s/^Example/#Example/" /etc/freshclam.conf

# Update ClamAV database
echo "Updating ClamAV database..."
freshclam

# Start ClamAV
echo "Starting ClamAV..."
systemctl start clamd@scan
systemctl enable clamd@scan

# Create a quarantine directory
echo "Creating a quarantine directory..."
mkdir /var/quarantine

# Scan the entire system and move detected files to quarantine
echo "Scanning the entire system and moving detected files to quarantine..."
clamscan -r --move=/var/quarantine --bell -i /

echo "Malware scanning and quarantine completed."