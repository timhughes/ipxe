# Automatic iPXE Menu Updates

This directory contains scripts and systemd units for automatically updating the iPXE menu from GitHub.

## Overview

Since standard iPXE doesn't support HTTPS and GitHub Pages mandates HTTPS, we need to periodically download the `elfshoe.ipxe` file from GitHub's raw content URL (which supports HTTP redirects) and place it in `/tftpboot` for TFTP/HTTP access.

## Components

- **update-ipxe-menu.sh** - Script that downloads and updates the menu
- **update-ipxe-menu.service** - Systemd service unit
- **update-ipxe-menu.timer** - Systemd timer (runs every 5 minutes)

## Installation

### 1. Copy the script to your TFTP server

```bash
# Copy script
sudo cp update-ipxe-menu.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/update-ipxe-menu.sh

# Test the script manually
sudo /usr/local/bin/update-ipxe-menu.sh
```

### 2. Install systemd units

```bash
# Copy systemd files
sudo cp update-ipxe-menu.service /etc/systemd/system/
sudo cp update-ipxe-menu.timer /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload
```

### 3. Enable and start the timer

```bash
# Enable timer to start on boot
sudo systemctl enable update-ipxe-menu.timer

# Start the timer now
sudo systemctl start update-ipxe-menu.timer

# Check timer status
sudo systemctl status update-ipxe-menu.timer
```

## Verification

### Check timer status

```bash
# See when it last ran and when it will run next
sudo systemctl list-timers update-ipxe-menu.timer

# Check service logs
sudo journalctl -u update-ipxe-menu.service -f
```

### Manual trigger

```bash
# Trigger an update manually
sudo systemctl start update-ipxe-menu.service

# Check logs
sudo journalctl -u update-ipxe-menu.service -n 20
```

### Verify file was downloaded

```bash
# Check the file exists
ls -lh /tftpboot/elfshoe.ipxe

# Verify it's a valid iPXE script
head -5 /tftpboot/elfshoe.ipxe
```

## Configuration

### Change update frequency

Edit `/etc/systemd/system/update-ipxe-menu.timer`:

```ini
# Update every 10 minutes instead of 5
OnUnitActiveSec=10min
```

Then reload:
```bash
sudo systemctl daemon-reload
sudo systemctl restart update-ipxe-menu.timer
```

### Change GitHub repository

Edit `/usr/local/bin/update-ipxe-menu.sh` and change:

```bash
GITHUB_RAW_URL="https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/docs/elfshoe.ipxe"
```

## Troubleshooting

### Timer not running

```bash
# Check if timer is enabled
sudo systemctl is-enabled update-ipxe-menu.timer

# Check timer status
sudo systemctl status update-ipxe-menu.timer

# View timer list
sudo systemctl list-timers --all
```

### Script fails to download

```bash
# Check network connectivity
curl -I https://raw.githubusercontent.com/timhughes/ipxe/main/docs/elfshoe.ipxe

# Check system logs
sudo journalctl -u update-ipxe-menu.service -n 50
```

### Permission issues

```bash
# Ensure /tftpboot is writable
sudo chown root:root /tftpboot
sudo chmod 755 /tftpboot

# Verify script permissions
ls -l /usr/local/bin/update-ipxe-menu.sh
```

## Security Notes

- Script runs as root (required to write to /tftpboot)
- Basic validation: Checks file is not empty and starts with `#!ipxe`
- Uses systemd security features: `PrivateTmp`, `NoNewPrivileges`, `ProtectSystem`
- Only updates if content actually changed

## Integration with dnsmasq

Update your `/etc/dnsmasq.d/pxe-boot.conf`:

```ini
# Chain to locally served elfshoe menu
dhcp-boot=tag:ipxe,elfshoe.ipxe
```

Or use the chain loader approach:

```ipxe
#!ipxe
# /tftpboot/chain.ipxe
chain tftp://${next-server}/elfshoe.ipxe || shell
```

## Uninstall

```bash
# Stop and disable timer
sudo systemctl stop update-ipxe-menu.timer
sudo systemctl disable update-ipxe-menu.timer

# Remove files
sudo rm /etc/systemd/system/update-ipxe-menu.{service,timer}
sudo rm /usr/local/bin/update-ipxe-menu.sh

# Reload systemd
sudo systemctl daemon-reload
```
