# ipxe

iPXE Network Boot Menu - automated boot menu generation and hosting powered by [elfshoe](https://timhughes.github.io/elfshoe/).

## About

This project provides an automatically-generated iPXE boot menu that supports multiple Linux distributions. The menu is regenerated daily and hosted on GitHub Pages.

**Live site**: https://timhughes.github.io/ipxe/

## Features

- **Multi-distribution support**: Fedora, CentOS Stream, Debian
- **Multi-architecture**: x86_64 and ARM64
- **Automatic updates**: Daily regeneration with latest versions
- **Complete documentation**: Setup guides for dnsmasq and TFTP

## Quick Start

1. Visit the [documentation site](https://timhughes.github.io/ipxe/)
2. Follow the [Setup Guide](https://timhughes.github.io/ipxe/setup/)
3. Download and use [elfshoe.ipxe](https://timhughes.github.io/ipxe/elfshoe.ipxe)

## Local Development

```bash
# Install hatch
pip install hatch

# Generate iPXE menu
hatch run docs:generate

# Build documentation site
hatch run docs:build

# Serve documentation locally
hatch run docs:serve
```

## Configuration

Edit `config.yaml` to customize the boot menu. Changes are automatically deployed via GitHub Actions.

## License

See LICENSE file for details.
