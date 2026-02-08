# iPXE Network Boot Menu

Welcome to the iPXE network boot menu site! This site hosts an automatically-generated iPXE boot menu powered by [elfshoe](https://timhughes.github.io/elfshoe/).

## What is This?

This site provides:

- **[elfshoe.ipxe](elfshoe.ipxe)** - A network boot menu that supports multiple Linux distributions
- **Setup instructions** - How to configure your TFTP/DHCP server to use this menu
- **Automatic updates** - The menu is regenerated daily with the latest distribution versions

## Available Distributions

The current menu includes:

- **Boot from Local Disk** (default) - Boots your installed operating system
- **Fedora Server** - Latest 3 versions (x86_64, ARM64)
- **Debian** - Bookworm (12) and Trixie (13) (x86_64, ARM64)
- **Utilities** - netboot.xyz, Memtest86+, Reboot, iPXE shell, and BIOS exit

!!! tip "Default Behavior"
    The menu defaults to "Boot from Local Disk" with a 30-second timeout. If you don't press any key, your system will boot normally from its hard drive.

!!! note "CentOS Stream"
    CentOS Stream is not included because mirror.stream.centos.org redirects to HTTPS, which requires iPXE to be built with HTTPS support.

## Quick Start

To use this boot menu:

1. **Download the iPXE script**: [elfshoe.ipxe](elfshoe.ipxe)
2. **Set up your infrastructure** - See the [Setup Guide](setup.md)
3. **Boot your machines** - Enable network boot in BIOS/UEFI

## Features

- **Architecture-aware** - Automatically shows only compatible options for your CPU architecture
- **Dynamic versions** - Fedora versions are fetched automatically from official metadata
- **Multi-architecture** - Supports x86_64 and ARM64 systems
- **Fast HTTP delivery** - Menu served over HTTP for speed and reliability

## About elfshoe

[elfshoe](https://timhughes.github.io/elfshoe/) is a tool that generates iPXE boot menus from a YAML configuration file. It supports:

- Dynamic version fetching from distribution metadata
- Multi-architecture support with intelligent client filtering
- URL validation to ensure boot files exist
- Flexible menu customization

## Updates

This menu is automatically regenerated:

- When the configuration is updated
- Daily at midnight UTC
- On manual trigger

---

**Need help?** Check the [Setup Guide](setup.md) or visit the [elfshoe documentation](https://timhughes.github.io/elfshoe/).
