# Coolify ZimaOS Fix

> Fix for "Read-only file system" error when running Coolify on ZimaOS

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![ZimaOS](https://img.shields.io/badge/ZimaOS-Compatible-blue)](https://zimaos.io/)
[![Coolify](https://img.shields.io/badge/Coolify-4.0.0--beta-purple)](https://coolify.io/)

## 🚨 The Problem

When deploying applications with Coolify on ZimaOS, you encounter this error:

```bash
mkdir: cannot create directory '/data': Read-only file system
```

**Why it happens:**
- ZimaOS uses a read-only root filesystem (squashfs) for system stability
- Coolify expects to create `/data/coolify` directory
- Cannot create `/data` on read-only filesystem ❌

## ✅ The Solution

This fix reconfigures Coolify to use `/DATA/coolify` instead by setting the `BASE_CONFIG_PATH` environment variable.

**One command to fix it all:**

```bash
sudo bash /DATA/coolify-fix/fix-coolify.sh
```

## 🚀 Quick Start

### Installation

```bash
# Download the fix
cd /DATA
git clone https://github.com/YOUR_USERNAME/coolify-zimaos-fix.git coolify-fix
cd coolify-fix

# Run the fix
sudo bash fix-coolify.sh

# Verify it worked
./test-fix.sh
```

### What It Does

1. ✅ Backs up your current Coolify configuration
2. ✅ Extracts database and Redis credentials
3. ✅ Creates `/DATA/coolify` directory
4. ✅ Fixes database server SSH key configuration
5. ✅ Recreates container with `BASE_CONFIG_PATH=/DATA/coolify`
6. ✅ Verifies everything works

## 📋 Requirements

- **OS**: ZimaOS (any version with read-only root)
- **Coolify**: 4.0.0-beta.* or later
- **Access**: Root/sudo access
- **Storage**: 1GB free space in `/DATA`

## 🧪 Testing

After running the fix, verify with:

```bash
./test-fix.sh
```

Expected output:
```
✅ PASS: BASE_CONFIG_PATH is /DATA/coolify
✅ PASS: /DATA/coolify exists
✅ PASS: Coolify container is running
✅ PASS: Web interface is responding
✅ PASS: SSH authentication works
✅ PASS: Server using correct private key
```

## 📚 Documentation

- **[Installation Guide](INSTALLATION.md)** - Detailed installation instructions
- **[Quick Start](QUICK-START.md)** - Quick reference guide
- **[Contributing](CONTRIBUTING.md)** - How to contribute
- **[Changelog](CHANGELOG.md)** - Version history

## 🛠️ What Gets Fixed

| Issue | Before | After |
|-------|--------|-------|
| **Base Path** | ❌ `/data/coolify` (read-only) | ✅ `/DATA/coolify` (writable) |
| **SSH Key** | ❌ Private key ID 0 (not found) | ✅ Private key ID 4 (coolify-host) |
| **Deployments** | ❌ mkdir fails | ✅ Works perfectly |
| **Persistence** | ❌ Lost on updates | ✅ Stored in `/DATA` |

## 🔧 Manual Fix (Alternative)

If you prefer manual installation:

<details>
<summary>Click to expand manual instructions</summary>

### Step 1: Extract Credentials
```bash
DB_PASSWORD=$(docker inspect zimaos-coolify | grep -oP 'DB_PASSWORD=\K[^"]+' | head -1)
REDIS_PASSWORD=$(docker inspect zimaos-coolify | grep -oP 'REDIS_PASSWORD=\K[^"]+' | head -1)
APP_KEY=$(docker inspect zimaos-coolify | grep -oP 'APP_KEY=\K[^"]+' | head -1)
```

### Step 2: Create Directory
```bash
mkdir -p /DATA/coolify
```

### Step 3: Fix Database
```bash
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  "UPDATE servers SET private_key_id = 4 WHERE id = 0;"
```

### Step 4: Recreate Container
```bash
docker stop zimaos-coolify && docker rm zimaos-coolify

docker run -d \
  --name zimaos-coolify \
  --restart unless-stopped \
  --network zimaos_coolify_network \
  -p 8000:80 \
  -e BASE_CONFIG_PATH=/DATA/coolify \
  -e REDIS_HOST=zimaos-coolify-redis \
  -e REDIS_PASSWORD="$REDIS_PASSWORD" \
  -e DB_HOST=zimaos-coolify-postgres \
  -e DB_PASSWORD="$DB_PASSWORD" \
  -e DB_DATABASE=coolify \
  -e DB_USERNAME=coolify \
  -e DB_PORT=5432 \
  -e PUSHER_HOST=zimaos-coolify-soketi \
  -e APP_KEY="$APP_KEY" \
  -v /DATA/AppData/coolify/backups:/var/www/html/storage/app/backups \
  -v /DATA/AppData/coolify/webhooks-during-maintenance:/var/www/html/storage/app/webhooks-during-maintenance \
  -v /DATA/AppData/coolify/logs:/var/www/html/storage/logs \
  -v /DATA/AppData/coolify/ssh:/var/www/html/storage/app/ssh \
  -v /DATA/AppData/coolify/applications:/var/www/html/storage/app/applications \
  -v /DATA/AppData/coolify/databases:/var/www/html/storage/app/databases \
  -v /DATA/AppData/coolify/services:/var/www/html/storage/app/services \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ghcr.io/coollabsio/coolify:4.0.0-beta.379
```

</details>

## ❓ Troubleshooting

### Container Won't Start
```bash
docker logs zimaos-coolify --tail 50
```

### Still Getting Error
```bash
# Verify BASE_CONFIG_PATH
docker exec zimaos-coolify env | grep BASE_CONFIG_PATH

# Should output: BASE_CONFIG_PATH=/DATA/coolify
```

### SSH Issues
```bash
# Test SSH manually
ssh -i /DATA/.ssh/id_coolify root@localhost
```

More troubleshooting help: [INSTALLATION.md](INSTALLATION.md#troubleshooting)

## ⚠️ Important Notes

### Persistence
⚠️ **This fix may need to be reapplied if:**
- ZimaOS updates and recreates the Coolify container
- You reinstall Coolify from App Store
- The container is manually removed and recreated

**Solution**: Simply re-run the fix script

### Storage Paths
When deploying applications:
- ✅ **Use**: `/DATA/AppData/your-app-name/`
- ❌ **Avoid**: `/data/your-app-name/`

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) first.

### Ways to Contribute
- 🐛 Report bugs
- 💡 Suggest features
- 📖 Improve documentation
- 🔧 Submit pull requests

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Coolify](https://coolify.io/) - The amazing self-hosting platform
- [ZimaOS](https://zimaos.io/) - The personal cloud operating system
- Community contributors and testers

## 📞 Support

- 📖 [Documentation](README.md)
- 💬 [Discussions](https://github.com/YOUR_USERNAME/coolify-zimaos-fix/discussions)
- 🐛 [Issues](https://github.com/YOUR_USERNAME/coolify-zimaos-fix/issues)

## ⭐ Star History

If this helped you, consider giving it a star! ⭐

## 🔗 Related

- [ZimaOS Coolify Discussions](https://github.com/justserdar/zimaos-coolify/discussions/1) - Original issue discussion
- [Coolify Documentation](https://coolify.io/docs)
- [ZimaOS Documentation](https://zimaos.io/docs)

---

**Made with ❤️ for the ZimaOS and Coolify community**

