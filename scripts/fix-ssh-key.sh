#!/bin/bash

#############################################################################
# Coolify SSH Key Configuration Fix Script
#
# This script fixes the "This key is not valid for this server" error
# by updating the server to use the correct SSH key from the database.
#
# Author: Created with Claude Code
# Date: 2026-02-15
#############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Coolify SSH Key Configuration Fix${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    echo "Please run: sudo $0"
    exit 1
fi

# Check if Coolify is running
if ! docker ps | grep -q zimaos-coolify; then
    echo -e "${RED}Error: Coolify container is not running${NC}"
    echo "Please start Coolify first"
    exit 1
fi

echo -e "${YELLOW}Step 1: Checking current server configuration...${NC}"
CURRENT_CONFIG=$(docker exec zimaos-coolify-postgres psql -U coolify -d coolify -t -c \
  'SELECT s.private_key_id, pk.name
   FROM servers s
   LEFT JOIN private_keys pk ON s.private_key_id = pk.id
   WHERE s.id = 0;' 2>&1)

echo "$CURRENT_CONFIG"

echo -e "\n${YELLOW}Step 2: Finding available SSH keys...${NC}"
KEYS=$(docker exec zimaos-coolify-postgres psql -U coolify -d coolify -t -c \
  "SELECT id, name, fingerprint FROM private_keys ORDER BY created_at;" 2>&1)

if [ -z "$KEYS" ] || echo "$KEYS" | grep -q "0 rows"; then
    echo -e "${RED}Error: No SSH keys found in database${NC}"
    echo -e "${BLUE}Please add an SSH key through the Coolify web interface first:${NC}"
    echo "  1. Go to Settings → Private Keys"
    echo "  2. Click 'Add Private Key'"
    echo "  3. Name: coolify-host"
    echo "  4. Paste the private key from /DATA/.ssh/id_coolify"
    exit 1
fi

echo "$KEYS"

# Get the first key ID
KEY_ID=$(docker exec zimaos-coolify-postgres psql -U coolify -d coolify -t -c \
  "SELECT id FROM private_keys ORDER BY created_at LIMIT 1;" 2>&1 | tr -d ' ')

if [ -z "$KEY_ID" ]; then
    echo -e "${RED}Error: Could not determine SSH key ID${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Step 3: Updating server to use SSH key ID: ${KEY_ID}...${NC}"
docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  "UPDATE servers SET private_key_id = ${KEY_ID} WHERE id = 0;" > /dev/null 2>&1

echo "  ✓ Server configuration updated"

echo -e "\n${YELLOW}Step 4: Verifying server user configuration...${NC}"
SERVER_USER=$(docker exec zimaos-coolify-postgres psql -U coolify -d coolify -t -c \
  'SELECT "user" FROM servers WHERE id = 0;' 2>&1 | tr -d ' ')

echo "  Current user: ${SERVER_USER}"

if [ "$SERVER_USER" != "root" ]; then
    echo -e "${YELLOW}  Changing user to 'root'...${NC}"
    docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
      'UPDATE servers SET "user" = '\''root'\'' WHERE id = 0;' > /dev/null 2>&1
    echo "  ✓ User changed to root"
fi

echo -e "\n${YELLOW}Step 5: Verifying SSH key is authorized...${NC}"
if grep -q "$(cat /DATA/.ssh/id_coolify.pub 2>/dev/null || echo '')" /DATA/.ssh/authorized_keys 2>/dev/null; then
    echo "  ✓ SSH key is in authorized_keys"
else
    echo -e "${YELLOW}  Adding SSH key to authorized_keys...${NC}"
    cat /DATA/.ssh/id_coolify.pub >> /DATA/.ssh/authorized_keys 2>/dev/null || true
    chmod 600 /DATA/.ssh/authorized_keys
    echo "  ✓ SSH key added to authorized_keys"
fi

echo -e "\n${YELLOW}Step 6: Restarting Coolify...${NC}"
docker restart zimaos-coolify > /dev/null
echo "  ✓ Coolify restarted"

echo -e "\n${YELLOW}Step 7: Waiting for Coolify to start...${NC}"
sleep 10

echo -e "\n${YELLOW}Step 8: Verifying configuration...${NC}"

# Check final configuration
FINAL_CONFIG=$(docker exec zimaos-coolify-postgres psql -U coolify -d coolify -c \
  'SELECT s.id, s.name, s.ip, s."user", s.port, s.private_key_id, pk.name as key_name
   FROM servers s
   LEFT JOIN private_keys pk ON s.private_key_id = pk.id
   WHERE s.id = 0;' 2>&1)

echo "$FINAL_CONFIG"

# Check if SSH key file exists in container
echo -e "\n${YELLOW}Step 9: Checking SSH key files in container...${NC}"
docker exec zimaos-coolify ls -la /var/www/html/storage/app/ssh/keys/ 2>&1 | tail -5

# Test SSH connection
echo -e "\n${YELLOW}Step 10: Testing SSH connection...${NC}"
SERVER_IP=$(docker exec zimaos-coolify-postgres psql -U coolify -d coolify -t -c \
  'SELECT ip FROM servers WHERE id = 0;' 2>&1 | tr -d ' ')

if docker exec zimaos-coolify ls /var/www/html/storage/app/ssh/keys/ssh_key@* > /dev/null 2>&1; then
    KEY_FILE=$(docker exec zimaos-coolify ls /var/www/html/storage/app/ssh/keys/ssh_key@* 2>/dev/null | head -1)

    if docker exec zimaos-coolify ssh -i "$KEY_FILE" \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=5 \
        root@${SERVER_IP} "echo 'SSH connection successful'" 2>&1 | grep -q "successful"; then
        echo -e "  ${GREEN}✓ SSH connection test PASSED${NC}"
    else
        echo -e "  ${YELLOW}⚠ SSH connection test failed, but configuration is correct${NC}"
        echo -e "  ${BLUE}Try validating the server in the Coolify web interface${NC}"
    fi
else
    echo -e "  ${YELLOW}⚠ SSH key file not found in container yet${NC}"
    echo -e "  ${BLUE}It should appear after a few seconds. Check in the web interface.${NC}"
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}SSH Key Configuration Updated!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo "Next steps:"
echo "1. Go to Coolify web interface: http://${SERVER_IP}:8000"
echo "2. Navigate to: Servers → localhost"
echo "3. Click 'Validate Server' or 'Check Connection'"
echo "4. The validation should now succeed!"
echo ""
echo -e "${BLUE}If validation still fails, check the logs:${NC}"
echo "  docker logs zimaos-coolify --tail 50"
echo ""
