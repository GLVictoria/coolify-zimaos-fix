# Coolify ZimaOS Fix

> Automated fixes for common Coolify issues on ZimaOS

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![ZimaOS](https://img.shields.io/badge/ZimaOS-Compatible-blue.svg)](https://zimaos.com)
[![Coolify](https://img.shields.io/badge/Coolify-4.0.0--beta.379-green.svg)](https://coolify.io)

## 🚀 Quick Start

### Problem 1: Read-Only Filesystem Error

```
mkdir: cannot create directory '/data': Read-only file system
```

**Fix:**
```bash
sudo bash scripts/fix-coolify.sh
```

### Problem 2: SSH Key Validation Error

```
Error: This key is not valid for this server
```

**Fix:**
```bash
sudo bash scripts/fix-ssh-key.sh
```

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Documentation](#documentation)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This repository contains automated fix scripts and comprehensive documentation for resolving common Coolify issues on ZimaOS, specifically:

1. **Read-Only Filesystem Error** - ZimaOS uses an immutable root filesystem, preventing Coolify from creating `/data/coolify`
2. **SSH Key Validation Error** - Server configuration references non-existent SSH keys
3. **Database Connection Issues** - Password mismatches between configuration and database
4. **Permission Problems** - Incorrect file ownership preventing Coolify from writing logs

## ✨ Features

- ✅ **Automated Fix Scripts** - One-command solutions for common issues
- ✅ **Comprehensive Documentation** - Detailed troubleshooting guides
- ✅ **Manual Fix Instructions** - Step-by-step guides for understanding the fixes
- ✅ **Verification Tests** - Scripts to verify fixes are working correctly
- ✅ **Safety First** - Automatic backups before making changes
- ✅ **Verbose Output** - Clear explanations of what's happening

## 📦 Installation

### Method 1: Clone Repository

```bash
cd /var/lib/casaos_data/
git clone https://github.com/YOUR_USERNAME/coolify-zimaos-fix.git
cd coolify-zimaos-fix
```

### Method 2: Direct Download

```bash
cd /var/lib/casaos_data/
wget https://github.com/YOUR_USERNAME/coolify-zimaos-fix/archive/main.zip
unzip main.zip
cd coolify-zimaos-fix-main
```

### Method 3: Already on ZimaOS

If you already have the fix directory:
```bash
cd /var/lib/casaos_data/coolify-fix
```

## 🛠️ Usage

### Fix Read-Only Filesystem

This fixes the `mkdir: cannot create directory '/data': Read-only file system` error.

```bash
sudo bash scripts/fix-coolify.sh
```

**What it does:**
1. Backs up current Coolify configuration
2. Extracts database and Redis passwords
3. Creates `/DATA/coolify` directory
4. Sets `BASE_CONFIG_PATH=/DATA/coolify`
5. Recreates Coolify container with proper configuration
6. Verifies installation

### Fix SSH Key Validation

This fixes the `This key is not valid for this server` error.

```bash
sudo bash scripts/fix-ssh-key.sh
```

**What it does:**
1. Checks current server SSH key configuration
2. Finds available SSH keys in database
3. Updates server to use correct key ID
4. Ensures server user is set to `root`
5. Verifies SSH key is authorized
6. Tests SSH connection

### Verify Fixes

Test that all fixes are working correctly:

```bash
bash scripts/test-fix.sh
```

## 📚 Documentation

### Main Documentation

- **[README.md](README.md)** - This file, main entry point
- **[INDEX.md](INDEX.md)** - Quick reference and common workflows

### Detailed Guides

- **[docs/SSH-KEY-FIX.md](docs/SSH-KEY-FIX.md)** - Complete SSH key troubleshooting guide
- **[docs/FIXES-APPLIED.md](docs/FIXES-APPLIED.md)** - History of issues and fixes

### Scripts

- **[scripts/fix-coolify.sh](scripts/fix-coolify.sh)** - Read-only filesystem fix
- **[scripts/fix-ssh-key.sh](scripts/fix-ssh-key.sh)** - SSH key configuration fix
- **[scripts/test-fix.sh](scripts/test-fix.sh)** - Verification tests

## 🔧 Troubleshooting

### Check Coolify Status

```bash
docker ps | grep coolify
```

### Check Logs

```bash
docker logs zimaos-coolify --tail 100
```

### Verify Configuration

```bash
# Check BASE_CONFIG_PATH
docker exec zimaos-coolify env | grep BASE_CONFIG_PATH

# Check SSH keys
docker exec zimaos-coolify ls -la /var/www/html/storage/app/ssh/keys/

# Check database connection
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c "SELECT version();"
```

### Common Issues

| Error | Solution |
|-------|----------|
| `Read-only file system` | Run `scripts/fix-coolify.sh` |
| `This key is not valid` | Run `scripts/fix-ssh-key.sh` |
| `password authentication failed` | Check database passwords |
| Container won't start | Check logs and verify docker-compose.yml |

For detailed troubleshooting, see [INDEX.md](INDEX.md#troubleshooting-commands).

## 🎓 How It Works

### ZimaOS Filesystem

ZimaOS uses an immutable operating system design:
- **Read-only root filesystem** (`/` on squashfs)
- **Writable overlay** for `/etc` (configuration)
- **Persistent data storage** in `/DATA`

This prevents system corruption and enables atomic updates, but breaks applications that try to write to the root filesystem.

### The Fix

We configure Coolify to use `/DATA/coolify` instead of `/data/coolify` by setting the `BASE_CONFIG_PATH` environment variable:

```bash
BASE_CONFIG_PATH=/DATA/coolify
```

This redirects all Coolify's deployment configurations and data to writable storage.

### SSH Key Management

Coolify stores SSH keys in the PostgreSQL database and exports them to the container filesystem on startup. The server must reference a valid `private_key_id` that exists in the `private_keys` table.

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

### Development

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/coolify-zimaos-fix.git
cd coolify-zimaos-fix

# Make your changes
# Test thoroughly on ZimaOS

# Submit a pull request
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Coolify](https://coolify.io) - The self-hosting platform
- [ZimaOS](https://zimaos.com) - The immutable operating system
- Community contributors and testers

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/YOUR_USERNAME/coolify-zimaos-fix/issues)
- **Discussions**: [GitHub Discussions](https://github.com/YOUR_USERNAME/coolify-zimaos-fix/discussions)
- **Coolify Docs**: https://coolify.io/docs
- **ZimaOS Community**: https://community.zimaspace.com

## 🔄 Updates

**Latest Version**: 1.0.0 (February 15, 2026)

### Changelog

- **1.0.0** (2026-02-15)
  - Initial release
  - Read-only filesystem fix script
  - SSH key configuration fix script
  - Comprehensive documentation
  - Verification tests

---

**Made with ❤️ for the ZimaOS and Coolify community**

**⭐ Star this repo if it helped you!**
