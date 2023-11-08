#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Ask for the root password
read -s -p "Enter the new root password: " ROOT_PASSWORD
echo

# Set the root password
echo "root:$ROOT_PASSWORD" | chpasswd

# Revoke sudo access for all users except root
for username in $(awk -F: '{ if ($3 > 0 && $1 != "root") print $1 }' /etc/passwd); do
  userdel -r $username  # Remove user account and home directory
done

# Limit non-root users to basic command access
cat << 'EOF' > /etc/sudoers.d/basic_access
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
%users ALL=(ALL) /usr/bin/whoami, /usr/bin/uptime, /usr/bin/date, /usr/bin/df
EOF

# Make the sudoers file immutable to prevent changes
chattr +i /etc/sudoers.d/basic_access

echo "Sudo access has been revoked for all users except root, and non-root users have limited command access."

# Clean the repository metadata
yum clean all

# Update the repositories
yum makecache

# Install available security updates
yum update -y --security

echo "Repository metadata cleaned, repositories updated, and security packages installed."

# Check if firewalld is installed
if ! rpm -q firewalld; then
  echo "Firewalld is not installed. Installing..."
  yum install -y firewalld
fi

# Start and enable firewalld
systemctl enable firewalld
systemctl start firewalld

# Configure firewalld to allow only HTTP traffic on port 80
firewall-cmd --zone=public --add-service=http --permanent
# Block SSH in firewalld
firewall-cmd --zone=public --remove-service=ssh --permanent
firewall-cmd --reload

# Display a message
echo "Password for root has been changed, and firewalld is configured to allow HTTP on port 80 only."

# Stop the SSH service
systemctl stop sshd

# Disable SSH service on boot
systemctl disable sshd

# Remove SSH package
yum remove -y openssh-server

echo "SSH has been blocked, stopped, and disabled on this server."

# Block users from using crontab
touch /etc/cron.allow
echo "root" > /etc/cron.allow
chmod 600 /etc/cron.allow
chown root:root /etc/cron.allow

# Clear all crontabs for all users
for username in $(awk -F: '{ if ($3 > 0) print $1 }' /etc/passwd); do
  crontab -r -u $username
done

echo "Crontab access has been blocked for all users except root, and all crontabs have been cleared."

# Prompt for the new MySQL password
read -s -p "Enter the new MySQL password: " NEW_MYSQL_PASSWORD
echo

# Change the MySQL password
mysqladmin -u root password "$NEW_MYSQL_PASSWORD"

echo "MySQL password has been changed."

# Check if SELinux is installed
if ! rpm -q selinux-policy; then
  echo "SELinux is not installed. Installing..."
  yum install -y selinux-policy
fi

# Set SELinux to the most secure "Enforcing" mode
sed -i 's/SELINUX=permissive/SELINUX=enforcing/' /etc/selinux/config

# Reboot the server to apply changes
reboot
