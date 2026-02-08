# ipxe

Automated iPXE network boot menu powered by [elfshoe](https://timhughes.github.io/elfshoe/).

## About

This repository automatically generates an iPXE boot menu that supports multiple Linux distributions. The menu is regenerated daily via GitHub Actions and can be deployed to your TFTP server using the included systemd scripts.

## Features

- **Multi-distribution support**: Fedora Server, Debian
- **Multi-architecture**: x86_64 and ARM64
- **Automatic updates**: Daily regeneration with latest versions
- **Boot utilities**: memtest86+, local disk boot (default), reboot, iPXE shell
- **Visual customization**: Background image and color options included

## Quick Start

### 1. Set Up TFTP Server with dnsmasq

Install dnsmasq on your TFTP server:

```bash
# Debian/Ubuntu
sudo apt install dnsmasq

# RHEL/Fedora
sudo dnf install dnsmasq
```

Create `/etc/dnsmasq.d/pxe-boot.conf`:

```ini
# Enable TFTP server
enable-tftp
tftp-root=/tftpboot

# Match all PXE clients
dhcp-match=set:pxe,60,PXEClient

# Set tag based on client architecture
dhcp-match=set:bios,option:client-arch,0
dhcp-match=set:efi-x86_64,option:client-arch,7
dhcp-match=set:efi-x86_64,option:client-arch,9
dhcp-match=set:efi-arm64,option:client-arch,11

# Detect iPXE (for chain loading)
dhcp-match=set:ipxe,175

# First stage: Load iPXE bootloader
dhcp-boot=tag:bios,tag:!ipxe,ipxe.pxe
dhcp-boot=tag:efi-x86_64,tag:!ipxe,ipxe.efi
dhcp-boot=tag:efi-arm64,tag:!ipxe,ipxe-arm64.efi

# Second stage: Chain to elfshoe menu
dhcp-boot=tag:ipxe,elfshoe.ipxe

# Enable DHCP logging
log-dhcp
```

Restart dnsmasq:

```bash
sudo systemctl restart dnsmasq
sudo systemctl enable dnsmasq
```

### 2. Download iPXE Boot Files

```bash
sudo mkdir -p /tftpboot
sudo wget https://boot.ipxe.org/ipxe.pxe -O /tftpboot/ipxe.pxe
sudo wget https://boot.ipxe.org/x86_64-efi/ipxe.efi -O /tftpboot/ipxe.efi
sudo wget https://boot.ipxe.org/arm64-efi/ipxe.efi -O /tftpboot/ipxe-arm64.efi
sudo chmod 644 /tftpboot/*
```

### 3. Set Up Automatic Menu Updates

Since standard iPXE doesn't support HTTPS and GitHub mandates HTTPS, use the systemd timer to periodically download the menu:

**Option A: Direct download with wget (simplest)**

```bash
# Download the update script
sudo wget https://raw.githubusercontent.com/timhughes/ipxe/main/scripts/update-ipxe-menu.sh \
  -O /usr/local/bin/update-ipxe-menu.sh
sudo chmod +x /usr/local/bin/update-ipxe-menu.sh

# Download systemd service
sudo wget https://raw.githubusercontent.com/timhughes/ipxe/main/scripts/update-ipxe-menu.service \
  -O /etc/systemd/system/update-ipxe-menu.service

# Download systemd timer
sudo wget https://raw.githubusercontent.com/timhughes/ipxe/main/scripts/update-ipxe-menu.timer \
  -O /etc/systemd/system/update-ipxe-menu.timer

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable --now update-ipxe-menu.timer

# Verify it's running
sudo systemctl list-timers update-ipxe-menu.timer
```

**Option B: Clone repository**

```bash
# Clone this repository
git clone https://github.com/timhughes/ipxe.git
cd ipxe/scripts

# Install the update script
sudo cp update-ipxe-menu.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/update-ipxe-menu.sh

# Install systemd units
sudo cp update-ipxe-menu.service /etc/systemd/system/
sudo cp update-ipxe-menu.timer /etc/systemd/system/

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable --now update-ipxe-menu.timer

# Verify it's running
sudo systemctl list-timers update-ipxe-menu.timer
```

The script will download the latest menu from GitHub every 5 minutes.

### 4. Configure Firewall

```bash
# UFW (Ubuntu/Debian)
sudo ufw allow 67/udp   # DHCP
sudo ufw allow 69/udp   # TFTP

# firewalld (RHEL/Fedora)
sudo firewall-cmd --permanent --add-service=dhcp
sudo firewall-cmd --permanent --add-service=tftp
sudo firewall-cmd --reload
```

## Menu Configuration

Edit `config.yaml` to customize the boot menu. Changes trigger automatic regeneration via GitHub Actions.

### Available Distributions

The menu includes:

- **Fedora Server** - Latest 2 versions (x86_64, ARM64) with WebUI installer enabled
- **Debian** - Bookworm (12) and Trixie (13) (x86_64, ARM64)

!!! note "Fedora WebUI Installer"
    Fedora installations use the modern **Anaconda WebUI** installer. After PXE booting, watch the console for a URL like `http://192.168.1.100:9090`, then open it in your browser on any device to complete the installation via a modern web interface.

### Boot Options

- **Boot from Local Disk** (default) - Automatically selected after 30 seconds
- **Memtest86+** - Memory diagnostics
- **Reboot System** - Restart the machine
- **iPXE Shell** - Interactive debugging
- **Exit to BIOS** - Return to firmware

## Visual Customization

The generated menu includes a background image and commented color options. To customize:

1. Edit the generated `elfshoe.ipxe` file in `/tftpboot`
2. Uncomment color options:

```ipxe
# Uncomment these lines to enable custom colors:
cpair --foreground 0x00cc00 --background 0x000000 0  # Green on black
cpair --foreground 0xffffff --background 0x0066cc 1  # White on blue (selected)
```

**Note**: Color and image support requires iPXE built with `IMAGE_PNG` support.

## How It Works

1. **GitHub Actions** runs daily (midnight UTC) to generate the menu
2. **Systemd timer** on your TFTP server downloads updates every 5 minutes
3. **iPXE clients** boot from TFTP and display the menu
4. **Architecture detection** shows only compatible options for each CPU

## Troubleshooting

### Menu not updating

```bash
# Check timer status
sudo systemctl status update-ipxe-menu.timer

# Manually trigger update
sudo systemctl start update-ipxe-menu.service

# Check logs
sudo journalctl -u update-ipxe-menu.service -n 20
```

### PXE boot not working

```bash
# Test TFTP
tftp YOUR_SERVER_IP
tftp> get ipxe.efi
tftp> quit

# Check dnsmasq logs
sudo journalctl -u dnsmasq -f

# Verify elfshoe.ipxe exists
ls -lh /tftpboot/elfshoe.ipxe
```

### Debug with iPXE Shell

Press `Ctrl+B` during iPXE boot to enter the shell:

```ipxe
# Check network
dhcp
ifstat

# Test menu loading
chain tftp://${next-server}/elfshoe.ipxe
```

## Development

### Local Menu Generation

```bash
# Install elfshoe
pip install elfshoe

# Generate menu
elfshoe -c config.yaml -o elfshoe.ipxe --no-validate
```

**Note**: We use `--no-validate` because many distribution mirrors redirect HTTP to HTTPS, which would fail validation.

## Project Structure

```
.
├── config.yaml                      # elfshoe configuration
├── elfshoe.ipxe                     # Generated boot menu
├── scripts/                         # Systemd auto-update scripts
│   ├── update-ipxe-menu.sh         # Download script
│   ├── update-ipxe-menu.service    # Systemd service
│   ├── update-ipxe-menu.timer      # Systemd timer
│   └── README.md                    # Installation guide
└── .github/workflows/
    └── generate-menu.yml            # Auto-generation workflow
```

## GitHub Actions

The workflow automatically:

1. Generates the menu when `config.yaml` changes
2. Runs daily at midnight UTC
3. Adds visual customization options
4. Commits the updated menu back to the repository

## Resources

- **elfshoe**: https://timhughes.github.io/elfshoe/
- **iPXE**: https://ipxe.org/
- **iPXE Boot Files**: https://boot.ipxe.org/
- **Generated Menu**: https://raw.githubusercontent.com/timhughes/ipxe/main/elfshoe.ipxe

## License

See LICENSE file for details.
