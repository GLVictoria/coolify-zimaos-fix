# Coolify Fixes Applied - February 15, 2026

## Summary

This document tracks all fixes applied to resolve Coolify issues on ZimaOS.

## Issues Fixed

### 1. ✅ Coolify Containers Stopped
**Problem**: All Coolify containers were in "Exited" state
**Root Cause**: PostgreSQL password mismatch between docker-compose.yml and database
**Solution**: Reset PostgreSQL password to match configuration
**Status**: FIXED ✅

**Commands Used**:
```bash
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  "ALTER USER coolify WITH PASSWORD 'f1986213-9d72-4c36-bbd4-adca2f414fa1';"
docker restart zimaos-coolify
```

### 2. ✅ Read-Only Filesystem Error
**Problem**: `mkdir: cannot create directory '/data': Read-only file system`
**Root Cause**: ZimaOS uses read-only root filesystem (squashfs), Coolify tried to create `/data/coolify`
**Solution**: Set `BASE_CONFIG_PATH=/DATA/coolify` to use writable storage
**Status**: FIXED ✅

**Script Used**: `fix-coolify.sh`

### 3. ✅ SSH Key Validation Error
**Problem**: `Error: This key is not valid for this server`
**Root Cause**: Server configured to use private_key_id=4 which didn't exist; actual key was id=1
**Solution**: Updated server configuration to use correct SSH key ID
**Status**: FIXED ✅

**Commands Used**:
```bash
# Found actual key ID
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  "SELECT id, name FROM private_keys;"

# Updated server to use correct key
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  'UPDATE servers SET private_key_id = 1 WHERE id = 0;'

# Changed user to root
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  'UPDATE servers SET "user" = '\''root'\'' WHERE id = 0;'
```

### 4. ✅ File Permissions
**Problem**: Coolify couldn't write to log files
**Root Cause**: Wrong ownership on `/DATA/AppData/coolify/logs` and `/DATA/AppData/coolify/ssh`
**Solution**: Changed ownership to uid 9999 (www-data in container)
**Status**: FIXED ✅

**Commands Used**:
```bash
chown -R 9999:9999 /DATA/AppData/coolify/logs /DATA/AppData/coolify/ssh
```

## Current Status

### All Services Running ✅
```
zimaos-coolify            Up (healthy)   0.0.0.0:8000->80/tcp
zimaos-coolify-postgres   Up (healthy)   0.0.0.0:5432->5432/tcp
zimaos-coolify-redis      Up (healthy)   0.0.0.0:6379->6379/tcp
zimaos-coolify-soketi     Up (healthy)   0.0.0.0:6001-6002->6001-6002/tcp
```

### Configuration Verified ✅
- Database connection: Working
- SSH key configured: ID 1 (coolify-host)
- Server user: root
- BASE_CONFIG_PATH: /DATA/coolify
- Web interface: http://192.168.1.141:8000

### SSH Connection Tested ✅
```bash
# From host to localhost: SUCCESS
ssh -i /DATA/.ssh/id_coolify root@localhost "echo test"

# From container to host: SUCCESS  
docker exec zimaos-coolify ssh -i /var/www/html/storage/app/ssh/keys/ssh_key@* root@192.168.1.141 "echo test"
```

## Documentation Created

### New Files
1. **fix-ssh-key.sh** - Automated SSH key configuration fix script
2. **SSH-KEY-FIX.md** - Comprehensive SSH key troubleshooting guide
3. **INDEX.md** - Directory index and quick reference
4. **FIXES-APPLIED.md** - This file

### Updated Files
1. **README.md** - Added SSH key configuration section, updated with all fixes

## Scripts Available

### `/var/lib/casaos_data/coolify-fix/fix-coolify.sh`
- Fixes read-only filesystem error
- Sets BASE_CONFIG_PATH=/DATA/coolify
- Recreates Coolify container with proper configuration

### `/var/lib/casaos_data/coolify-fix/fix-ssh-key.sh`
- Fixes SSH key validation error
- Updates server to use correct SSH key ID
- Ensures proper user configuration
- Tests SSH connection

## Usage for Future Issues

### If Coolify Stops Working

1. **Check container status**:
   ```bash
   docker ps -a | grep coolify
   ```

2. **Check logs**:
   ```bash
   docker logs zimaos-coolify --tail 50
   ```

3. **Restart if needed**:
   ```bash
   cd /var/lib/casaos/apps/coolify
   docker compose up -d
   ```

### If Read-Only Filesystem Error Appears

```bash
sudo bash /var/lib/casaos_data/coolify-fix/fix-coolify.sh
```

### If SSH Key Validation Fails

```bash
sudo bash /var/lib/casaos_data/coolify-fix/fix-ssh-key.sh
```

## Lessons Learned

### PostgreSQL in Docker
- Environment variable `POSTGRES_PASSWORD` only affects initial database creation
- Changing it in docker-compose doesn't update existing database passwords
- Must use `ALTER USER` SQL command to change existing passwords

### Coolify SSH Keys
- SSH keys stored in `private_keys` table
- Server references keys by `private_key_id`
- PopulateSshKeysDirectorySeeder exports keys from DB to container filesystem
- Key files named: `ssh_key@<uuid>` or `id.<user>@<ip>_<id>`

### ZimaOS Filesystem
- Root filesystem (/) is read-only (squashfs)
- Use `/DATA/` for all persistent writable storage
- SSH authorized_keys location: `/DATA/.ssh/authorized_keys`
- Container volumes must map to `/DATA/AppData/`

### UID/GID in Containers
- Coolify container runs as www-data (uid=9999, gid=9999)
- PostgreSQL container runs as postgres (uid=70)
- File ownership must match for proper access

## Verification Checklist

- [x] All containers running and healthy
- [x] Database connection working
- [x] BASE_CONFIG_PATH set correctly
- [x] SSH key in database
- [x] SSH key in container filesystem
- [x] SSH key in authorized_keys
- [x] Server user set to root
- [x] Server references correct key ID
- [x] SSH connection test successful
- [x] Web interface accessible
- [x] Server validation successful

## Support Resources

- Main docs: `/var/lib/casaos_data/coolify-fix/README.md`
- SSH key docs: `/var/lib/casaos_data/coolify-fix/SSH-KEY-FIX.md`
- Index: `/var/lib/casaos_data/coolify-fix/INDEX.md`
- Coolify official docs: https://coolify.io/docs

---

**Date**: February 15, 2026
**ZimaOS Version**: Linux 6.12.25
**Coolify Version**: 4.0.0-beta.379
**Fixed By**: Claude Code
**Status**: All issues resolved ✅
