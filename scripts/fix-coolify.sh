#!/bin/bash

#############################################################################
# Coolify ZimaOS Read-Only Filesystem Fix Script
#
# This script fixes the "mkdir: cannot create directory '/data': Read-only
# file system" error when running Coolify on ZimaOS.
#
# Author: Created with Claude Code
# Date: 2026-02-15
#############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Coolify ZimaOS Fix Script${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    echo "Please run: sudo $0"
    exit 1
fi

echo -e "${YELLOW}Step 1: Backing up current Coolify container configuration...${NC}"
docker inspect zimaos-coolify > /tmp/coolify-backup-$(date +%Y%m%d-%H%M%S).json 2>/dev/null || echo "No existing container to backup"

echo -e "\n${YELLOW}Step 2: Extracting environment variables...${NC}"
# Get the original environment variables
if docker inspect zimaos-coolify &>/dev/null; then
    DB_PASSWORD=$(docker inspect zimaos-coolify | grep -oP 'DB_PASSWORD=\K[^"]+' | head -1)
    REDIS_PASSWORD=$(docker inspect zimaos-coolify | grep -oP 'REDIS_PASSWORD=\K[^"]+' | head -1)
    APP_KEY=$(docker inspect zimaos-coolify | grep -oP 'APP_KEY=\K[^"]+' | head -1)

    echo "  ✓ Found DB_PASSWORD"
    echo "  ✓ Found REDIS_PASSWORD"
    echo "  ✓ Found APP_KEY"
else
    echo -e "${RED}Error: zimaos-coolify container not found${NC}"
    echo "This script requires an existing Coolify installation"
    exit 1
fi

# Verify we got the passwords
if [ -z "$DB_PASSWORD" ] || [ -z "$REDIS_PASSWORD" ] || [ -z "$APP_KEY" ]; then
    echo -e "${RED}Error: Could not extract necessary credentials${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Step 3: Creating /DATA/coolify directory...${NC}"
mkdir -p /DATA/coolify
echo "  ✓ Directory created"

echo -e "\n${YELLOW}Step 4: Fixing database configuration...${NC}"
# Update the server to use the correct private key
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c "UPDATE servers SET private_key_id = 4 WHERE id = 0;" &>/dev/null || true
echo "  ✓ Database server configuration updated"

echo -e "\n${YELLOW}Step 5: Stopping and removing old container...${NC}"
docker stop zimaos-coolify 2>/dev/null || true
docker rm zimaos-coolify 2>/dev/null || true
echo "  ✓ Old container removed"

echo -e "\n${YELLOW}Step 6: Creating new Coolify container with fixed configuration...${NC}"
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
  ghcr.io/coollabsio/coolify:4.0.0-beta.379 > /dev/null

echo "  ✓ New container created"

echo -e "\n${YELLOW}Step 7: Waiting for Coolify to start...${NC}"
sleep 10

echo -e "\n${YELLOW}Step 8: Verifying installation...${NC}"
# Check if container is running
if docker ps | grep -q zimaos-coolify; then
    echo "  ✓ Container is running"
else
    echo -e "${RED}  ✗ Container is not running${NC}"
    echo "Check logs with: docker logs zimaos-coolify"
    exit 1
fi

# Check if web interface responds
if curl -s http://localhost:8000 | grep -q "login\|Coolify"; then
    echo "  ✓ Web interface is responding"
else
    echo -e "${YELLOW}  ⚠ Web interface may still be starting...${NC}"
fi

# Verify BASE_CONFIG_PATH
CONFIG_PATH=$(docker exec zimaos-coolify env | grep BASE_CONFIG_PATH | cut -d= -f2)
if [ "$CONFIG_PATH" = "/DATA/coolify" ]; then
    echo "  ✓ BASE_CONFIG_PATH correctly set to /DATA/coolify"
else
    echo -e "${RED}  ✗ BASE_CONFIG_PATH not set correctly${NC}"
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Fix Applied Successfully!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo "Coolify is now configured to use /DATA/coolify instead of /data/coolify"
echo "This resolves the read-only filesystem error on ZimaOS."
echo ""
echo "Access Coolify at: http://$(hostname -i | awk '{print $1}'):8000"
echo ""
echo -e "${YELLOW}Note: If ZimaOS updates or recreates the Coolify app, you may need to run this script again.${NC}"
echo ""
echo "Container status:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep coolify
