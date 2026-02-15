# Installation Guide

This guide will help you fix the "Read-only file system" error when running Coolify on ZimaOS.

## Prerequisites

Before you begin, ensure you have:

- ✅ ZimaOS installed and running
- ✅ Coolify installed from ZimaOS App Store (any version)
- ✅ Root/sudo access to your ZimaOS server
- ✅ SSH access to your ZimaOS server (optional, for remote installation)

## System Requirements

- **OS**: ZimaOS (any version with read-only root filesystem)
- **Coolify**: 4.0.0-beta.* or later
- **Docker**: Installed and running (comes with ZimaOS)
- **Storage**: At least 1GB free space in `/DATA`

## Quick Installation (Recommended)

### Step 1: Download the Fix Script

**Option A: Using git (if available)**
```bash
cd /DATA
git clone https://github.com/YOUR_USERNAME/coolify-zimaos-fix.git
cd coolify-zimaos-fix
```

**Option B: Using curl**
```bash
mkdir -p /DATA/coolify-fix
cd /DATA/coolify-fix
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/coolify-zimaos-fix/main/fix-coolify.sh
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/coolify-zimaos-fix/main/test-fix.sh
chmod +x fix-coolify.sh test-fix.sh
```

**Option C: Using wget**
```bash
mkdir -p /DATA/coolify-fix
cd /DATA/coolify-fix
wget https://raw.githubusercontent.com/YOUR_USERNAME/coolify-zimaos-fix/main/fix-coolify.sh
wget https://raw.githubusercontent.com/YOUR_USERNAME/coolify-zimaos-fix/main/test-fix.sh
chmod +x fix-coolify.sh test-fix.sh
```

**Option D: Manual Download**
1. Download the repository as ZIP from GitHub
2. Extract to `/DATA/coolify-fix/`
3. Make scripts executable: `chmod +x /DATA/coolify-fix/*.sh`

### Step 2: Run the Fix Script

```bash
sudo bash /DATA/coolify-fix/fix-coolify.sh
```

The script will:
1. ✅ Backup your current configuration
2. ✅ Extract database and Redis passwords
3. ✅ Create `/DATA/coolify` directory
4. ✅ Update database server configuration
5. ✅ Recreate Coolify container with correct settings
6. ✅ Verify the installation

### Step 3: Verify the Fix

```bash
/DATA/coolify-fix/test-fix.sh
```

Expected output:
```
Testing Coolify ZimaOS Fix...
==============================

1. Checking BASE_CONFIG_PATH...
   ✅ PASS: BASE_CONFIG_PATH is /DATA/coolify
2. Checking /DATA/coolify directory...
   ✅ PASS: /DATA/coolify exists
3. Checking Coolify container status...
   ✅ PASS: Coolify container is running
4. Checking web interface...
   ✅ PASS: Web interface is responding
5. Checking SSH configuration...
   ✅ PASS: SSH authentication works
6. Checking database server configuration...
   ✅ PASS: Server using correct private key (ID 4)
```

### Step 4: Access Coolify

Open your browser and navigate to:
```
http://YOUR_SERVER_IP:8000
```

You should now be able to deploy applications without the read-only filesystem error!

## Manual Installation

If you prefer to understand each step or the automated script fails, follow the [manual installation guide in README.md](README.md#manual-fix-instructions).

## Post-Installation

### Verify Everything Works

1. **Check container status:**
   ```bash
   docker ps | grep coolify
   ```

2. **Verify environment variable:**
   ```bash
   docker exec zimaos-coolify env | grep BASE_CONFIG_PATH
   # Should output: BASE_CONFIG_PATH=/DATA/coolify
   ```

3. **Test web interface:**
   ```bash
   curl http://localhost:8000
   ```

### Deploy Your First App

1. Log into Coolify at `http://YOUR_SERVER_IP:8000`
2. Create a new project
3. Add a resource (application, database, or service)
4. **Important**: When configuring persistent storage:
   - ✅ Use paths like: `/DATA/AppData/your-app-name/data`
   - ❌ Avoid paths like: `/data/your-app-name/data`

## Troubleshooting

### Script Fails with "Container not found"

**Problem**: The script cannot find the existing Coolify container.

**Solution**:
```bash
# Check if Coolify is installed
docker ps -a | grep coolify

# If not installed, install Coolify first from ZimaOS App Store
```

### Database Password Not Found

**Problem**: Script cannot extract database credentials.

**Solution**:
```bash
# Manually check if container exists and has environment variables
docker inspect zimaos-coolify | grep DB_PASSWORD

# If empty, you may need to reinstall Coolify first
```

### Container Starts But Shows Errors

**Problem**: Coolify container is running but shows errors in logs.

**Solution**:
```bash
# Check logs
docker logs zimaos-coolify --tail 50

# Common issues:
# 1. Redis connection - verify zimaos-coolify-redis is running
# 2. Database connection - verify zimaos-coolify-postgres is running
# 3. Permission errors - verify /DATA/coolify has correct permissions
```

### Web Interface Not Loading

**Problem**: Cannot access Coolify at port 8000.

**Solution**:
```bash
# 1. Check if container is running
docker ps | grep zimaos-coolify

# 2. Check if port is accessible
curl http://localhost:8000

# 3. Check firewall rules (if applicable)
# 4. Verify container health
docker inspect zimaos-coolify | grep -A 10 Health
```

### SSH Authentication Fails

**Problem**: Coolify cannot connect to the server via SSH.

**Solution**:
```bash
# 1. Check if SSH is running
ps aux | grep sshd

# 2. Test SSH connection manually
ssh -i /DATA/.ssh/id_coolify root@localhost

# 3. Verify authorized_keys
cat /DATA/.ssh/authorized_keys

# 4. Update database if needed
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  "UPDATE servers SET private_key_id = 4 WHERE id = 0;"
```

### Still Getting "Read-only file system" Error

**Problem**: Error persists after running the fix.

**Possible causes**:
1. Fix script didn't complete successfully
2. Container was recreated by ZimaOS
3. Environment variable not set correctly

**Solution**:
```bash
# 1. Verify BASE_CONFIG_PATH
docker exec zimaos-coolify env | grep BASE_CONFIG_PATH

# 2. If not set to /DATA/coolify, run the fix script again
sudo bash /DATA/coolify-fix/fix-coolify.sh

# 3. Check logs for the specific error
docker logs zimaos-coolify 2>&1 | grep "Read-only"
```

## Updating

### When to Re-run the Fix

You need to re-run the fix script if:
- ❗ ZimaOS updates and recreates the Coolify container
- ❗ You reinstall Coolify from the App Store
- ❗ You manually remove and recreate the container
- ❗ The "Read-only file system" error returns

### How to Update

Simply re-run the fix script:
```bash
cd /DATA/coolify-fix
git pull  # If you used git clone
sudo bash fix-coolify.sh
```

## Uninstallation

If you need to revert the fix (not recommended):

```bash
# Stop and remove the fixed container
docker stop zimaos-coolify
docker rm zimaos-coolify

# Reinstall Coolify from ZimaOS App Store
# Note: This will bring back the original "Read-only file system" error
```

## Getting Help

If you encounter issues:

1. **Check the documentation**: [README.md](README.md)
2. **Run the test script**: `/DATA/coolify-fix/test-fix.sh`
3. **Check logs**: `docker logs zimaos-coolify --tail 100`
4. **Open an issue**: [GitHub Issues](https://github.com/YOUR_USERNAME/coolify-zimaos-fix/issues)
5. **Join discussions**: [GitHub Discussions](https://github.com/YOUR_USERNAME/coolify-zimaos-fix/discussions)

## What's Next?

- 📚 Read the [README.md](README.md) for technical details
- 🤝 See [CONTRIBUTING.md](CONTRIBUTING.md) to contribute
- 🐛 Report bugs in [Issues](https://github.com/YOUR_USERNAME/coolify-zimaos-fix/issues)
- 💡 Share your experience in [Discussions](https://github.com/YOUR_USERNAME/coolify-zimaos-fix/discussions)

---

**Need help?** Open an issue on GitHub or check the troubleshooting section above.
