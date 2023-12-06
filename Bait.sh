#!/bin/bash

# Choose a secure wiping method (e.g., DoD 5220.22-M, Gutmann)
wipefs -a -f DoD /dev/sda1

# Choose a secure wiping method (e.g., DoD 5220.22-M, Gutmann)
wipefs -a -f DoD /dev/sda1

# Optionally, overwrite the wiped data with random data
# dd if=/dev/urandom of=/dev/sda1 bs=1M status=progress

# Use a package manager specific command (e.g., apt-get, yum)
apt-get purge --auto-remove $(dpkg --get-selections | grep -v deinstall | cut -f1)

# Choose a random block device (e.g., /dev/urandom)
dd if=/dev/urandom of=/dev/sda bs=1M status=progress

# Choose a random block device (e.g., /dev/urandom)
dd if=/dev/urandom of=/dev/sda bs=512 count=1 status=progress

# Unmount the partition to prevent data corruption
umount /

# Reboot the system
reboot
