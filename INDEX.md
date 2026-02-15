# Coolify ZimaOS Fix Scripts - Index

This directory contains automated fix scripts and documentation for common Coolify issues on ZimaOS.

## Quick Reference

| Issue | Script | Documentation |
|-------|--------|---------------|
| Read-only filesystem error | `fix-coolify.sh` | [README.md](./README.md#problem-1-read-only-filesystem) |
| SSH key validation error | `fix-ssh-key.sh` | [SSH-KEY-FIX.md](./SSH-KEY-FIX.md) |
| Container stopped/not starting | Manual troubleshooting | [README.md](./README.md#troubleshooting) |

## Files in This Directory

### Fix Scripts

#### `fix-coolify.sh`
**Purpose**: Fixes the read-only filesystem error
**What it does**:
- Backs up current Coolify configuration
- Extracts database and Redis passwords
- Creates `/DATA/coolify` directory
- Updates database server configuration
- Recreates Coolify container with `BASE_CONFIG_PATH=/DATA/coolify`
- Verifies installation

**Usage**:
```bash
sudo bash /var/lib/casaos_data/coolify-fix/fix-coolify.sh
```

**When to use**:
- Fresh Coolify installation on ZimaOS
- After reinstalling Coolify from app store
- When deployments fail with read-only filesystem error

#### `fix-ssh-key.sh`
**Purpose**: Fixes SSH key validation errors
**What it does**:
- Checks current server SSH key configuration
- Finds available SSH keys in database
- Updates server to use correct key ID
- Ensures server user is set to `root`
- Verifies SSH key is authorized
- Tests SSH connection
- Displays final configuration

**Usage**:
```bash
sudo bash /var/lib/casaos_data/coolify-fix/fix-ssh-key.sh
```

**When to use**:
- After adding SSH key through web interface
- When server validation fails with "key is not valid" error
- When Coolify logs show "No query results for model [App\Models\PrivateKey]"

#### `test-fix.sh`
**Purpose**: Test script for validating fixes
**Usage**: Internal testing

### Documentation

#### `README.md`
**Main documentation file**
**Covers**:
- Read-only filesystem issue
- Manual fix instructions
- Troubleshooting guide
- SSH configuration
- System architecture

#### `SSH-KEY-FIX.md`
**Dedicated SSH key troubleshooting guide**
**Covers**:
- SSH key validation error
- Root cause analysis
- Quick fix with script
- Manual fix steps
- Verification commands
- Common issues and solutions
- Architecture notes

#### `INSTALLATION.md`
**Coolify installation guide**

#### `SUMMARY.md`
**Quick reference summary**

#### `INDEX.md` (This file)
**Directory index and quick reference**

## Common Workflows

### First Time Setup

1. Install Coolify from ZimaOS app store
2. Run read-only filesystem fix:
   ```bash
   sudo bash /var/lib/casaos_data/coolify-fix/fix-coolify.sh
   ```
3. Access Coolify web interface
4. Add SSH key through Settings → Private Keys
5. If validation fails, run SSH key fix:
   ```bash
   sudo bash /var/lib/casaos_data/coolify-fix/fix-ssh-key.sh
   ```

### After ZimaOS Update

If Coolify stops working after a ZimaOS update:

1. Check if containers are running:
   ```bash
   docker ps | grep coolify
   ```

2. If stopped, restart them:
   ```bash
   cd /var/lib/casaos/apps/coolify
   docker compose up -d
   ```

3. If read-only error appears, re-run filesystem fix:
   ```bash
   sudo bash /var/lib/casaos_data/coolify-fix/fix-coolify.sh
   ```

### After Coolify App Update

If Coolify is updated through the app store:

1. Check if `BASE_CONFIG_PATH` is still set:
   ```bash
   docker exec zimaos-coolify env | grep BASE_CONFIG_PATH
   ```

2. If not, re-run filesystem fix:
   ```bash
   sudo bash /var/lib/casaos_data/coolify-fix/fix-coolify.sh
   ```

## Troubleshooting Commands

### Check Coolify Status
```bash
docker ps | grep coolify
```

### Check Coolify Logs
```bash
docker logs zimaos-coolify --tail 100
```

### Check Database Configuration
```bash
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  'SELECT s.id, s.name, s.ip, s."user", s.private_key_id, pk.name as key_name
   FROM servers s
   LEFT JOIN private_keys pk ON s.private_key_id = pk.id
   WHERE s.id = 0;'
```

### Check SSH Keys
```bash
# In database
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  "SELECT id, name, fingerprint FROM private_keys;"

# In container
docker exec zimaos-coolify ls -la /var/www/html/storage/app/ssh/keys/
```

### Test SSH Connection
```bash
# From host
ssh -i /DATA/.ssh/id_coolify root@localhost "echo 'SSH works'"

# From container
docker exec zimaos-coolify ssh -i /var/www/html/storage/app/ssh/keys/ssh_key@* \
  -o StrictHostKeyChecking=no \
  root@192.168.1.141 "echo 'Container SSH works'"
```

## Getting Help

### Check the Logs First
```bash
docker logs zimaos-coolify --tail 100
```

### Common Error Messages

| Error | Fix |
|-------|-----|
| `mkdir: cannot create directory '/data': Read-only file system` | Run `fix-coolify.sh` |
| `This key is not valid for this server` | Run `fix-ssh-key.sh` |
| `No query results for model [App\Models\PrivateKey]` | Run `fix-ssh-key.sh` |
| `password authentication failed` | Check database passwords |
| `Could not setup dynamic configuration` | Check SSH key configuration |

### Still Need Help?

1. Read the full [README.md](./README.md)
2. Check [SSH-KEY-FIX.md](./SSH-KEY-FIX.md) for SSH issues
3. Review Coolify logs for specific errors
4. Check ZimaOS community forums
5. Check Coolify documentation: https://coolify.io/docs

## Version Information

- **Created**: February 15, 2026
- **ZimaOS Version**: Compatible with ZimaOS (Linux 6.12.25)
- **Coolify Version**: Tested with 4.0.0-beta.379
- **Fixes Included**:
  - Read-only filesystem fix
  - SSH key configuration fix
  - PostgreSQL password fix
  - File permissions fix

## Maintenance

### Backup Before Running Fixes

Both fix scripts automatically create backups:
- Container configs: `/tmp/coolify-backup-YYYYMMDD-HHMMSS.json`
- Database backups: Handled by PostgreSQL persistence in `/DATA/AppData/coolify/pgdata/`

### Restore from Backup

If something goes wrong, restore using docker-compose:

```bash
cd /var/lib/casaos/apps/coolify
docker compose down
# Restore any custom changes
docker compose up -d
```

## Contributing

Found an issue or improvement? The fix scripts are designed to be:
- **Idempotent**: Safe to run multiple times
- **Verbose**: Clear output of what's happening
- **Verified**: Self-checking and validation
- **Documented**: Comments explain each step

Feel free to modify and improve based on your needs!

---

**Maintained by**: Claude Code
**Repository**: `/var/lib/casaos_data/coolify-fix/`
**License**: Provided as-is for the community
