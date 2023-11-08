#!/bin/bash

# Check if user is root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# Prompt for a new password
read -s -p "Enter the new password: " new_password
echo

# Change the root password
echo "Changing root password..."
echo "root:$new_password" | chpasswd

# Change passwords for all users (except root)
for user in $(getent passwd | cut -d: -f1); do
    if [ "$user" != "root" ]; then
        echo "Changing password for $user..."
        echo "$user:$new_password" | chpasswd
    fi
done

# Remove sudo access for all users
for user in $(getent passwd | cut -d: -f1); do
  if [[ $user != "root" ]]; then
    echo "Removing sudo access for $user..."
    sudo deluser $user sudo
  fi
done

# Restrict users to basic commands
cat > /etc/rbash_profile <<EOL
PATH=/bin:/usr/bin
EOL

# Apply restricted shell to all users
for user in $(getent passwd | cut -d: -f1); do
  if [[ $user != "root" ]]; then
    echo "Setting restricted shell for $user..."
    usermod -s /bin/rbash $user
  fi
done

echo "Sudo access has been removed, and users are restricted to basic commands."

# You may want to consider rebooting the system to apply changes.

# Clean repositories and update packages
echo "Cleaning repositories and updating packages..."
dnf clean all
dnf update -y

# Check and install firewalld
if ! rpm -q firewalld &> /dev/null; then
    echo "Installing firewalld..."
    sudo dnf install firewalld -y
fi

# Start and enable firewalld
echo "Starting and enabling firewalld..."
systemctl start firewalld
systemctl enable firewalld

# Configure firewalld rules
echo "Configuring firewalld rules..."
firewall-cmd --add-service=http --permanent
firewall-cmd --add-service=imap --permanent
firewall-cmd --add-service=smtp --permanent
firewall-cmd --add-service=pop3 --permanent

# List all users with crontabs and delete their crontab entries
for user in $(cut -f1 -d: /etc/passwd); do
  if [[ -n $(crontab -u $user -l 2>/dev/null) ]]; then
    echo "Deleting crontab for user $user..."
    crontab -r -u $user
  fi
done

echo "Crontabs for all users have been wiped."

# Optionally, you can also remove the crontab files to ensure they're empty
find /var/spool/cron -type f -exec rm -f {} \;

 # Block SSH connections
echo "Blocking SSH connections in firewalld..."
firewall-cmd --remove-service=ssh --permanent
firewall-cmd --reload

else
    echo "Firewalld is not installed. Skipping firewall configuration."
fi

# Stop the SSH service
echo "Stopping SSH service..."
systemctl stop sshd

# Uninstall SSH
echo "Uninstalling SSH..."
dnf remove openssh-server -y

echo "SSH has been blocked, stopped, and uninstalled."

# Install available security patches and updates
echo "Installing security patches and updates..."
dnf update -y

# Define the banner message
banner_message="*******************************************************************************
* WARNING: This is a Company server. Unauthorized access is prohibited. *
* All access attempts are logged. Please log in only if authorized.       *
* Unauthorized access will be prosecuted to the full extent of the law.  *
*******************************************************************************"

# Write the banner message to /etc/motd
echo "$banner_message" | sudo tee /etc/motd > /dev/null

# Display the contents of /etc/motd
echo "The contents of /etc/motd are:"
cat /etc/motd

# Prompt for the new MySQL password
read -s -p "Enter the new MySQL password: " new_mysql_password
echo

# Change the MySQL root password
mysql -u root -p -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$new_mysql_password';"

# Optionally, you may want to update the password for any application users

echo "MySQL root password has been changed."

# Check if SELinux is installed
if ! rpm -q policycoreutils &> /dev/null; then
    echo "SELinux is not installed. Installing SELinux..."
    sudo dnf install policycoreutils -y
fi

# Set SELinux to enforce mode
echo "Configuring SELinux to the most secure mode (enforcing)..."
setenforce 1

# Optionally, you can update the SELinux policy, but be cautious as it may break some applications.
# sudo semodule -DB

echo "SELinux has been configured to enforce mode (the most secure mode)."

# Formatted output
becho() {
    echo "$(tput bold)$1...$(tput sgr0)"
}

declare -A osInfo;
osInfo[/etc/redhat-release]="yum install -y"
osInfo[/etc/debian_version]="apt install -y"
osInfo[/etc/alpine-release]="apk add"
osInfo[/etc/arch-release]="pacman -S"

for f in ${!osInfo[@]}
do
    if [[ -f $f ]]; then
        if [[ -f "/etc/centos-release" ]]; then
            becho "Adding EPEL repository"
            yum install -y epel-release
        fi
        
        becho "Installing fail2ban with ${osInfo[$f]} fail2ban"
        echo "$(${osInfo[$f]} fail2ban)"
        
        becho "Creating fail2ban config"
		cat > /etc/fail2ban/jail.local <<- EOM
			[sshd]
			enabled = true
			bantime = 5m
			maxretry = 3
		EOM
        
        becho "Enabling fail2ban service"
        if [[ "$f" == "/etc/alpine-release" ]]; then
            rc-update add fail2ban
            rc-service fail2ban start
        else
            systemctl enable --now fail2ban
        fi
    fi
done

# Disables the ability to load new modules
sysctl -w kernel.modules_disabled=1
echo 'kernel.modules_disabled=1' > /etc/sysctl.conf

echo "Script completed."
reboot