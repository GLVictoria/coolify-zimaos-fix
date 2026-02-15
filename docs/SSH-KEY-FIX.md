# SSH Key Configuration Fix

## Problem

After setting up Coolify on ZimaOS, you may encounter this error when validating the server:

```
Error: This key is not valid for this server.
```

## Root Cause

The server configuration in the database references an SSH key ID that doesn't exist. This happens because:

1. The initial setup creates a server entry with a placeholder key ID (usually 4)
2. When you add an SSH key through the web interface, it gets a different ID (usually 1)
3. The server still references the old, non-existent key ID

## Quick Fix

Run the automated fix script:

```bash
sudo bash /var/lib/casaos_data/coolify-fix/fix-ssh-key.sh
```

## What the Script Does

1. ✅ Checks current server SSH key configuration
2. ✅ Finds available SSH keys in the database
3. ✅ Updates server to use the correct key ID
4. ✅ Verifies server user is set to `root`
5. ✅ Ensures SSH key is in authorized_keys
6. ✅ Restarts Coolify
7. ✅ Tests SSH connection
8. ✅ Displays final configuration

## Manual Fix

If you prefer to fix it manually:

### 1. Check Current Configuration

```bash
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  'SELECT s.id, s.name, s.private_key_id, pk.name as key_name
   FROM servers s
   LEFT JOIN private_keys pk ON s.private_key_id = pk.id
   WHERE s.id = 0;'
```

If `key_name` shows `(null)`, the server references a non-existent key.

### 2. Find Your SSH Key ID

```bash
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  "SELECT id, name, fingerprint FROM private_keys ORDER BY created_at;"
```

Note the `id` (usually `1`).

### 3. Update Server Configuration

```bash
# Replace 1 with your actual key ID from step 2
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  'UPDATE servers SET private_key_id = 1 WHERE id = 0;'
```

### 4. Ensure Server User is Root

```bash
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  'UPDATE servers SET "user" = '\''root'\'' WHERE id = 0;'
```

### 5. Verify SSH Key is Authorized

```bash
# Check if key is in authorized_keys
grep "$(cat /DATA/.ssh/id_coolify.pub)" /DATA/.ssh/authorized_keys

# If not found, add it
cat /DATA/.ssh/id_coolify.pub >> /DATA/.ssh/authorized_keys
chmod 600 /DATA/.ssh/authorized_keys
```

### 6. Restart Coolify

```bash
docker restart zimaos-coolify
```

### 7. Verify in Web Interface

1. Go to: http://YOUR_IP:8000
2. Navigate to: **Servers** → **localhost**
3. Click **"Validate Server"**
4. Should succeed! ✅

## Verification Commands

### Check Server Configuration

```bash
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  'SELECT s.id, s.name, s.ip, s."user", s.port, s.private_key_id, pk.name as key_name
   FROM servers s
   LEFT JOIN private_keys pk ON s.private_key_id = pk.id
   WHERE s.id = 0;'
```

Expected output:
- `private_key_id`: Should match an existing key ID (usually 1)
- `key_name`: Should show your key name (e.g., "coolify-host")
- `user`: Should be "root"

### Check SSH Keys in Container

```bash
docker exec zimaos-coolify ls -la /var/www/html/storage/app/ssh/keys/
```

Should show a file like: `ssh_key@ro84k4kg880k8c80w80gcgkw`

### Test SSH Connection

```bash
# From host
ssh -i /DATA/.ssh/id_coolify root@localhost "echo 'SSH works'"

# From container (get the actual key file name first)
docker exec zimaos-coolify ssh \
  -i /var/www/html/storage/app/ssh/keys/ssh_key@* \
  -o StrictHostKeyChecking=no \
  root@192.168.1.141 "echo 'SSH from container works'"
```

## Common Issues

### Issue: "No SSH keys found in database"

**Solution**: Add an SSH key through the web interface first:

1. Go to **Settings** → **Private Keys**
2. Click **"Add Private Key"**
3. **Name**: `coolify-host`
4. **Private Key**: Paste contents of `/DATA/.ssh/id_coolify`
5. Click **"Add"**

Then run the fix script again.

### Issue: SSH key not appearing in container

**Check**: The PopulateSshKeysDirectorySeeder should run on startup

**Solution**: Restart Coolify to trigger the seeder:

```bash
docker restart zimaos-coolify
sleep 10
docker exec zimaos-coolify ls -la /var/www/html/storage/app/ssh/keys/
```

### Issue: "Permission denied" when testing SSH

**Possible causes**:
1. SSH key not in authorized_keys
2. Wrong file permissions
3. Wrong user

**Solution**:

```bash
# Verify authorized_keys
cat /DATA/.ssh/authorized_keys

# Fix permissions
chmod 600 /DATA/.ssh/authorized_keys
chmod 600 /DATA/.ssh/id_coolify

# Ensure key is added
cat /DATA/.ssh/id_coolify.pub >> /DATA/.ssh/authorized_keys
```

### Issue: Server user is "coolify" but user doesn't exist

**Check**:
```bash
id coolify  # Should show "no such user"
```

**Solution**: Change to root user (see manual fix step 4 above)

## Architecture Notes

### How Coolify Stores SSH Keys

1. **Database**: SSH keys are stored in the `private_keys` table
2. **Container Filesystem**: On startup, Coolify's `PopulateSshKeysDirectorySeeder` reads keys from the database and writes them to `/var/www/html/storage/app/ssh/keys/`
3. **Naming Convention**: Files are named `ssh_key@<uuid>` or `id.<user>@<ip>_<id>`
4. **Volume Mount**: The keys directory is mounted from `/DATA/AppData/coolify/ssh/keys/`

### Server-Key Relationship

```
servers table                private_keys table
┌─────────────────┐         ┌──────────────────┐
│ id: 0           │         │ id: 1            │
│ name: localhost │         │ uuid: ro84k4...  │
│ ip: 192.168...  │         │ name: coolify... │
│ user: root      │  ─────> │ private_key: --- │
│ private_key_id:1│         │ fingerprint: ... │
└─────────────────┘         └──────────────────┘
```

The `private_key_id` in servers must match an existing `id` in private_keys.

## Success Indicators

After applying the fix, you should see:

✅ Server configuration shows correct key_name (not null)
✅ SSH key file exists in container
✅ SSH connection test succeeds
✅ Server validation in web interface succeeds
✅ No "PrivateKey" errors in Coolify logs

## Support

If you still encounter issues:

1. Check Coolify logs: `docker logs zimaos-coolify --tail 100`
2. Verify SSH service: `systemctl status sshd`
3. Check database: Run verification commands above
4. Test manually: `ssh -i /DATA/.ssh/id_coolify root@localhost`

---

**Created**: February 15, 2026
**For**: ZimaOS + Coolify 4.0.0-beta.379
**Issue**: SSH key validation error
