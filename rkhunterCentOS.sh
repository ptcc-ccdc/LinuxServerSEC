#!/bin/bash

# Install EPEL repository (if not already installed)
if ! rpm -q epel-release; then
  yum install -y epel-release
fi

# Install rkhunter
yum install -y rkhunter

# Update rkhunter signature database
rkhunter --update

# Generate initial system file property database
rkhunter --propupd

# Configure email notifications (optional)
# Edit `/etc/rkhunter.conf` and set `MAIL-ON-WARNING=your_email@address.com`

# Run a test scan
rkhunter --check

# Display completion message
echo "rkhunter installed and configured successfully. Review logs and adjust settings as needed."