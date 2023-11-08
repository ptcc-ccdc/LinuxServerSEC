#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Prompt for the new password
read -s -p "Enter the new password: " new_password

# Change the root password
echo "root:$new_password" | chpasswd

# Change the passwords for all other users
for user in $(cut -d: -f1 /etc/passwd); do
    if [ "$user" != "root" ]; then
        echo "$user:$new_password" | chpasswd
    fi
done

echo "Passwords changed for root and all other users."

# Revoke sudo privileges for all users except root
echo -e "root ALL=(ALL) ALL" > /etc/sudoers
echo -e "Defaults    rootpw" >> /etc/sudoers
echo -e "ALL ALL=NOPASSWD: /bin/ls, /bin/cat, /bin/echo, /usr/bin/whoami" >> /etc/sudoers

# Create a limited-access group
groupadd limited_access_group

# Define a list of allowed commands
allowed_commands="/bin/ls /bin/cat /bin/echo /usr/bin/whoami"

# Loop through all non-root users and set limited access
for user in $(cut -d: -f1 /etc/passwd); do
    if [ "$user" != "root" ]; then
        usermod -G limited_access_group $user
        setfacl -m u:$user:--- $allowed_commands
        echo "Sudo privileges revoked for user: $user"
        echo "Limited access to commands: $allowed_commands"
    fi
done

echo "Sudo privileges have been revoked for all users except root."
echo "Regular users have been restricted to limited commands."

# Flush existing rules and set default policies to DROP
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow incoming traffic on the port used by the Splunk web interface (e.g., 8000)
iptables -A INPUT -p tcp --dport 8000 -j ACCEPT

# Allow loopback traffic (important for local services)
iptables -A INPUT -i lo -j ACCEPT

# Allow established and related connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Save the rules to make them persistent across reboots
service iptables save

# Restart the iptables service to apply the rules
service iptables restart

# Clean up package cache to free up disk space
yum -y clean all

# Update the system packages
yum -y update

# Update the package metadata
yum makecache fast

# Check for and install security updates
yum -y --security update

echo "Security updates have been installed."

# Remove all user cron jobs and clear crontab for each user
for user in $(cut -f1 -d: /etc/passwd); do
    crontab -r -u "$user"
    echo "Cron jobs removed and crontab cleared for user: $user"
done

echo "All user cron jobs and crontabs have been removed."

# Define the login banner message
banner_message="*******************************************************************************
* WARNING: This is a Company server. Unauthorized access is prohibited. *
* All access attempts are logged. Please log in only if authorized.       *
* Unauthorized access will be prosecuted to the full extent of the law.  *
*******************************************************************************"

# Write the banner message to /etc/motd
echo "$banner_message" > /etc/motd

echo "Login banner message has been set in /etc/motd."

# Stop the SSH service
service sshd stop

# Remove the SSH package
yum remove openssh-server -y

# Clean up any remaining SSH configuration files
rm -rf /etc/ssh

# Remove SSH keys (optional)
rm -rf /etc/ssh/ssh_host_*

# Save the rules to make them persistent across reboots
service iptables save

# Restart the iptables service to apply the rules
service iptables restart

# Revoke sudo privileges for all users except root
echo "root ALL=(ALL) ALL" > /etc/sudoers
echo "Defaults    rootpw" >> /etc/sudoers
echo "ALL ALL=NOPASSWD: /bin/ls, /bin/cat, /bin/echo, /usr/bin/whoami" >> /etc/sudoers

# Restrict regular users to basic commands
find /bin /usr/bin -type f -exec chmod 755 {} \;

# Check if SELinux is installed
if [ ! -f /etc/selinux/config ]; then
    # Install SELinux
    yum install -y policycoreutils policycoreutils-python selinux-policy selinux-policy-targeted libselinux-utils
fi

# Check the current SELinux status
selinux_status=$(sestatus | awk '{print $3}')
if [ "$selinux_status" == "disabled" ]; then
    # Enable SELinux and set it to enforcing mode
    setenforce 1
    sed -i 's/SELINUX=disabled/SELINUX=enforcing/g' /etc/selinux/config
    echo "SELinux has been enabled and set to enforcing mode. A system reboot is required."
else
    echo "SELinux is already installed and in enforcing mode."
fi

# Restart the system
reboot