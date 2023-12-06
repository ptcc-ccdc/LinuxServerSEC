#!/bin/bash

# Update system packages
yum update -y

# Install Fail2ban and dependencies
yum install -y epel-release fail2ban fail2ban-systemd

# Enable and start Fail2ban service
systemctl enable fail2ban
systemctl start fail2ban

# Backup default Fail2ban configuration file
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Configure Fail2ban settings in jail.local
sed -i 's/bantime = 600/bantime = 86400/g' /etc/fail2ban/jail.local
sed -i 's/findtime = 600/findtime = 1200/g' /etc/fail2ban/jail.local
sed -i 's/maxretry = 3/maxretry = 5/g' /etc/fail2ban/jail.local

# Enable additional jails for common services
fail2ban-client set ssh enabled true
fail2ban-client set ssh bantime 86400
fail2ban-client set ssh findtime 1200
fail2ban-client set ssh maxretry 5

# Enable additional jails for potential E-commerce server vulnerabilities
fail2ban-client set php-fpm enabled true
fail2ban-client set php-fpm bantime 86400
fail2ban-client set php-fpm findtime 1200
fail2ban-client set php-fpm maxretry 5

# Display completion message
echo "Fail2ban installed and configured securely. Please review and adapt as needed."
