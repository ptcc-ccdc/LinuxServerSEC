# LinuxServerSEC


# Cyber Defense Competition (CCDC) Linux Bash Scripting Repository

Welcome to the CCDC Linux Bash Scripting Repository! This repository contains a collection of Bash scripts designed to help participants in Cyber Defense Competitions (CCDC) and anyone interested in securing Linux systems and firewalls, managing users, and automating tasks with crontab. These scripts are here to make your life easier as you defend, secure, and maintain your Linux systems.

## Table of Contents

- [Introduction](#introduction)
- [Scripts](#scripts)
  - [System Security](#system-security)
  - [User Management](#user-management)
  - [Crontab Automation](#crontab-automation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction

Cyber Defense Competitions are intense events where teams must defend their network infrastructure from attackers while ensuring services are available and secure. This repository provides Bash scripts to help automate common tasks, enhance system security, manage users, and schedule tasks with crontab.

## Scripts

### System Security

1. **`firewall-setup.sh`** - This script helps you set up and configure a firewall on your Linux system to restrict incoming and outgoing network traffic based on predefined rules.

2. **`ssh-hardening.sh`** - Use this script to harden your SSH server by configuring secure settings, such as disabling root login, enforcing strong ciphers, and setting up public key authentication.

3. **`security-audit.sh`** - This script performs a security audit on your system by checking for common security vulnerabilities and providing recommendations for improvements.

### User Management

1. **`user-add.sh`** - Simplify user creation with this script. It prompts you for user details and creates the user account, sets a password, and adds the user to the necessary groups.

2. **`user-delete.sh`** - Safely delete a user account using this script. It prompts you for the username and removes the user while preserving their home directory.

### Crontab Automation

1. **`cron-job.sh`** - Automate recurring tasks using crontab with this script. It guides you through scheduling tasks, specifying time intervals, and executing scripts at predefined times.

## Usage

To use these scripts, follow these general steps:

1. Clone this repository to your Linux system:
   ```bash
   git clone https://github.com/ptcc-ccdc/LinuxServerSEC.git
   ```

2. Navigate to the repository directory:
   ```bash
   cd LinuxServerSEC
   ```

3. Make the desired script executable:
   ```bash
   chmod +x script-name.sh
   ```

4. Execute the script:
   ```bash
   ./script-name.sh
   ```

Please refer to each script's documentation within the repository for specific usage instructions and options.

## Contributing

We welcome contributions from the CCDC community and other users. If you have a script to share, an enhancement to suggest, or a bug to report, please open an issue or submit a pull request. Your contributions are highly appreciated.

## License

This repository is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute these scripts in accordance with the license terms.

---

Happy scripting and best of luck in your CCDC competition! If you have any questions or need assistance, don't hesitate to reach out to the community.
