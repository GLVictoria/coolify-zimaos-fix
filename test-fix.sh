#!/bin/bash
#
# Test script to verify the Coolify fix is working
#

echo "Testing Coolify ZimaOS Fix..."
echo "=============================="
echo ""

# Test 1: Check BASE_CONFIG_PATH
echo "1. Checking BASE_CONFIG_PATH..."
CONFIG_PATH=$(docker exec zimaos-coolify env 2>/dev/null | grep BASE_CONFIG_PATH | cut -d= -f2)
if [ "$CONFIG_PATH" = "/DATA/coolify" ]; then
    echo "   ✅ PASS: BASE_CONFIG_PATH is /DATA/coolify"
else
    echo "   ❌ FAIL: BASE_CONFIG_PATH is not set correctly (got: $CONFIG_PATH)"
fi

# Test 2: Check if /DATA/coolify exists
echo "2. Checking /DATA/coolify directory..."
if [ -d "/DATA/coolify" ]; then
    echo "   ✅ PASS: /DATA/coolify exists"
else
    echo "   ❌ FAIL: /DATA/coolify does not exist"
fi

# Test 3: Check container is running
echo "3. Checking Coolify container status..."
if docker ps | grep -q zimaos-coolify; then
    echo "   ✅ PASS: Coolify container is running"
else
    echo "   ❌ FAIL: Coolify container is not running"
fi

# Test 4: Check web interface
echo "4. Checking web interface..."
if curl -s http://localhost:8000 | grep -q "login\|Coolify"; then
    echo "   ✅ PASS: Web interface is responding"
else
    echo "   ⚠️  WARN: Web interface may still be starting"
fi

# Test 5: Check SSH
echo "5. Checking SSH configuration..."
if ssh -i /DATA/.ssh/id_coolify -o BatchMode=yes -o StrictHostKeyChecking=no root@localhost "exit" 2>/dev/null; then
    echo "   ✅ PASS: SSH authentication works"
else
    echo "   ⚠️  WARN: SSH authentication test failed (may be normal)"
fi

# Test 6: Check database server config
echo "6. Checking database server configuration..."
PRIVATE_KEY_ID=$(docker exec zimaos-coolify-postgres psql -U coolify -d coolify -t -c "SELECT private_key_id FROM servers WHERE id = 0;" 2>/dev/null | tr -d ' ')
if [ "$PRIVATE_KEY_ID" = "4" ]; then
    echo "   ✅ PASS: Server using correct private key (ID 4)"
else
    echo "   ⚠️  WARN: Server private key may not be set correctly (got: $PRIVATE_KEY_ID)"
fi

echo ""
echo "=============================="
echo "Test Complete"
echo ""
echo "Access Coolify: http://$(hostname -i | awk '{print $1}'):8000"
