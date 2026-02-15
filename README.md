# Coolify ZimaOS Read-Only Filesystem Fix

## The Problem

When running Coolify on ZimaOS, you may encounter this error:

```
mkdir: cannot create directory '/data': Read-only file system
```

This happens because:
1. **ZimaOS has a read-only root filesystem** - The root filesystem (`/`) is mounted as read-only (squashfs), which is typical for immutable operating systems
2. **Coolify expects `/data/coolify` to exist** - By default, Coolify tries to create and use `/data/coolify` for deployments and configuration
3. **Cannot create `/data` directory** - Since the root filesystem is read-only, creating `/data` fails

## The Solution

The fix involves reconfiguring Coolify to use `/DATA/coolify` instead of `/data/coolify` by setting the `BASE_CONFIG_PATH` environment variable.

### Quick Fix

Run the automated fix script:

```bash
sudo bash /DATA/coolify-fix/fix-coolify.sh
```

### What the Script Does

1. ✅ Backs up current Coolify container configuration
2. ✅ Extracts existing database and Redis passwords
3. ✅ Creates `/DATA/coolify` directory (on writable storage)
4. ✅ Updates database server configuration
5. ✅ Recreates Coolify container with `BASE_CONFIG_PATH=/DATA/coolify`
6. ✅ Verifies the installation

## Manual Fix Instructions

If you prefer to fix it manually or understand what's happening:

### Step 1: Extract Current Configuration

```bash
# Get database password
DB_PASSWORD=$(docker inspect zimaos-coolify | grep -oP 'DB_PASSWORD=\K[^"]+' | head -1)

# Get Redis password
REDIS_PASSWORD=$(docker inspect zimaos-coolify | grep -oP 'REDIS_PASSWORD=\K[^"]+' | head -1)

# Get APP_KEY
APP_KEY=$(docker inspect zimaos-coolify | grep -oP 'APP_KEY=\K[^"]+' | head -1)
```

### Step 2: Create Data Directory

```bash
mkdir -p /DATA/coolify
```

### Step 3: Fix Database Configuration

```bash
# Update server to use correct SSH private key
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  "UPDATE servers SET private_key_id = 4 WHERE id = 0;"
```

### Step 4: Recreate Container

```bash
# Stop and remove old container
docker stop zimaos-coolify
docker rm zimaos-coolify

# Create new container with BASE_CONFIG_PATH
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

### Step 5: Verify

```bash
# Check container is running
docker ps | grep coolify

# Verify BASE_CONFIG_PATH
docker exec zimaos-coolify env | grep BASE_CONFIG_PATH

# Test web interface
curl http://localhost:8000
```

## Additional Fixes Applied

### SSH Configuration (Already Persistent on ZimaOS)

ZimaOS is already configured for persistent SSH:
- `AuthorizedKeysFile` points to `/DATA/.ssh/authorized_keys`
- `PubkeyAuthentication` is enabled
- SSH keys are stored in persistent storage

### Database Server Configuration

The fix also corrects the server's SSH private key reference:
- Updates `servers` table to use `private_key_id = 4` (coolify-host key)
- Fixes "No query results for model [App\Models\PrivateKey] 0" error

## Verification

After applying the fix, verify everything is working:

```bash
# 1. Check all containers are healthy
docker ps | grep coolify

# 2. Verify BASE_CONFIG_PATH
docker exec zimaos-coolify env | grep BASE_CONFIG_PATH
# Should output: BASE_CONFIG_PATH=/DATA/coolify

# 3. Test SSH connection
ssh -i /DATA/.ssh/id_coolify root@localhost "echo 'SSH works'"

# 4. Access Coolify web interface
# http://YOUR_SERVER_IP:8000
```

## Troubleshooting

### Container Won't Start

Check logs:
```bash
docker logs zimaos-coolify --tail 50
```

### Database Connection Errors

Verify passwords were extracted correctly:
```bash
docker inspect zimaos-coolify | grep -E "DB_PASSWORD|REDIS_PASSWORD"
```

### SSH Still Failing

Check if SSH service is running:
```bash
systemctl status sshd
# Or check for standalone SSH daemon
ps aux | grep sshd
```

## Important Notes

### Persistence

⚠️ **This fix is temporary if ZimaOS recreates the container**

If ZimaOS updates or the Coolify app is reinstalled from the app store, you will need to run this fix again.

**To make it permanent**, you would need to:
1. Modify the ZimaOS Coolify app store configuration
2. OR create a systemd service that runs this script on boot
3. OR contact the ZimaOS/Coolify integration maintainer

### Storage Paths

When deploying applications with Coolify:
- ✅ Use: `/DATA/AppData/your-app-name/` for persistent storage
- ❌ Avoid: `/data/` (read-only filesystem)

### System Information

- **ZimaOS Root Filesystem**: Read-only squashfs
- **Writable Storage**: `/DATA` (ext4, persistent)
- **Coolify Default Path**: `/data/coolify` (won't work on ZimaOS)
- **Fixed Path**: `/DATA/coolify` (works on ZimaOS)

## Technical Details

### Why This Happens

ZimaOS uses an immutable OS design with:
- **Read-only root filesystem** (`/` on squashfs)
- **Writable overlay for `/etc`** (configuration files)
- **Persistent data storage** in `/DATA` (user data)

This design:
- ✅ Prevents system corruption
- ✅ Enables atomic updates
- ✅ Improves reliability
- ❌ Prevents creating `/data` directory

### How Coolify Uses BASE_CONFIG_PATH

Coolify's `BASE_CONFIG_PATH` environment variable controls where it stores:
- Proxy configurations (Traefik/Caddy)
- Deployment scripts
- Application data paths
- Service configurations

Sources in Coolify code:
- `/var/www/html/config/constants.php`: Defines default path
- `/var/www/html/bootstrap/helpers/shared.php`: Uses the path
- Environment variable `BASE_CONFIG_PATH` overrides the default

## Related Issues

- [ZimaOS Coolify Discussion #1](https://github.com/justserdar/zimaos-coolify/discussions/1) - SSH key authentication
- Coolify expects writable `/data` directory
- ZimaOS immutable filesystem design

## Files in This Directory

- `fix-coolify.sh` - Automated fix script
- `README.md` - This documentation
- `/tmp/coolify-backup-*.json` - Backup files created by script

## Support

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review logs: `docker logs zimaos-coolify`
3. Verify storage: `df -h /DATA`
4. Check SSH: `systemctl status sshd`

## License

This fix is provided as-is for the ZimaOS and Coolify community.

---

**Last Updated**: February 15, 2026
**Tested On**: ZimaOS with Coolify 4.0.0-beta.379
