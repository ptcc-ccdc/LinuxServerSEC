#!/bin/bash

# Install ClamAV antivirus
yum install clamav-daemon clamav-scanner-systemd -y

# Enable and start ClamAV service
systemctl enable clamav-daemon
systemctl start clamav-daemon

# Update ClamAV virus definitions
freshclam

# Configure ClamAV to scan specific directories
echo "/var/www/html" >> /etc/clamav/scan.d/local.ign
echo "/home/*/.bashrc" >> /etc/clamav/scan.d/local.ign

# Schedule regular scans
crontab -l > mycron
echo "0 0 * * * clamscan -r /" >> mycron
crontab mycron
rm mycron

# Configure ClamAV to automatically take action on infected files
sed -i 's/Action = "Clean"/Action = "Quarantine"/g' /etc/clamav/clamd.conf

# Add ClamAV quarantine directory to firewall rules
firewall-cmd --permanent --zone=public --add-port=3310/tcp

# Restart firewall and ClamAV service
firewall-cmd --reload
systemctl restart clamav-daemon

# Display completion message
echo "ClamAV antivirus setup completed. Remember to review and adapt as needed."

#!/bin/bash

# Ensure ClamAV is running
systemctl restart clamav-daemon

# Update virus definitions
freshclam

# Perform a deep scan of all files
clamscan -r --recursive --move=/var/lib/clamav/quarantine/ /

# Analyze quarantined files
for file in /var/lib/clamav/quarantine/*; do
  # Check for scripts
  if file "$file" | grep -q "script"; then
    # Take action on script, e.g., log and delete
    echo "Found script: $file" >> /var/log/clamav.log
    rm -rf "$file"
  fi
done

# Report results
echo "Deep scan completed. Quarantined files: $(ls -l /var/lib/clamav/quarantine/ | wc -l)"

# Schedule regular deep scans
crontab -l > mycron
echo "0 0 * * * clamscan -r --recursive --move=/var/lib/clamav/quarantine/ /" >> mycron
crontab mycron
rm mycron

# Display completion message
echo "Deep scan and action script completed. Review quarantined files and logs carefully."
