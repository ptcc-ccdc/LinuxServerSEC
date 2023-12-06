#!/bin/bash

# Prompt user for new password
read -s -p "Enter new MySQL root password: " NEW_PASSWORD

# Validate password strength
if [[ ! "$NEW_PASSWORD" =~ ^[A-Za-z0-9!@#$%^&*()-_=+]{8,}$ ]]; then
  echo "Password must be at least 8 characters and contain a mix of upper and lowercase letters, numbers, and special characters."
  exit 1
fi

# Stop MySQL service
systemctl stop mysqld

# Update root password
mysqladmin -u root -p password "$NEW_PASSWORD"

# Force password expiration
mysqladmin -u root -p password expire

# Remove anonymous user access
mysql -u root -p -e "DELETE FROM mysql.user WHERE User='';"

# Disallow root login remotely
mysql -u root -p -e "UPDATE mysql.user SET host='localhost' WHERE User='root';"

# Flush privileges
mysql -u root -p -e "FLUSH PRIVILEGES;"

# Start MySQL service
systemctl start mysqld

# Secure MySQL configuration file
chmod 600 /etc/my.cnf

# Display completion message
echo "MySQL database secured and password updated successfully."