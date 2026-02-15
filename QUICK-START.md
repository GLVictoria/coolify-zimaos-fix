# Coolify ZimaOS Fix - Quick Start

## The Error

```
mkdir: cannot create directory '/data': Read-only file system
```

## Quick Fix (One Command)

```bash
sudo bash /DATA/coolify-fix/fix-coolify.sh
```

That's it! The script will:
- ✅ Backup your current configuration
- ✅ Fix the read-only filesystem issue
- ✅ Update database configuration
- ✅ Recreate Coolify with correct paths
- ✅ Verify everything works

## After Running the Fix

1. **Access Coolify**: `http://YOUR_SERVER_IP:8000`
2. **Verify it worked**:
   ```bash
   docker exec zimaos-coolify env | grep BASE_CONFIG_PATH
   # Should show: BASE_CONFIG_PATH=/DATA/coolify
   ```

## What Was Fixed

| Before | After |
|--------|-------|
| ❌ Uses `/data/coolify` (read-only) | ✅ Uses `/DATA/coolify` (writable) |
| ❌ SSH key error (ID 0 not found) | ✅ Correct SSH key (ID 4) |
| ❌ mkdir fails | ✅ Deployments work |

## Need Help?

Read the full documentation: `/DATA/coolify-fix/README.md`

## Files

- `fix-coolify.sh` - Automated fix script
- `README.md` - Complete documentation
- `QUICK-START.md` - This file

---

**Location**: `/DATA/coolify-fix/`
**Run**: `sudo bash /DATA/coolify-fix/fix-coolify.sh`
