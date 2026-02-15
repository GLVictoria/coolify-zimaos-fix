#!/bin/bash
# Quick documentation viewer

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║          Coolify ZimaOS Fix - Documentation              ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Select documentation to view:"
echo ""
echo "  1) INDEX.md         - Quick reference (START HERE)"
echo "  2) README.md        - Main documentation"
echo "  3) SSH-KEY-FIX.md   - SSH troubleshooting"
echo "  4) FIXES-APPLIED.md - What was fixed today"
echo "  5) List all files"
echo "  q) Quit"
echo ""
read -p "Enter choice [1-5, q]: " choice

DIR="/var/lib/casaos_data/coolify-fix"

case $choice in
    1) less "$DIR/INDEX.md" ;;
    2) less "$DIR/README.md" ;;
    3) less "$DIR/SSH-KEY-FIX.md" ;;
    4) less "$DIR/FIXES-APPLIED.md" ;;
    5) ls -lh "$DIR"/*.{sh,md} 2>/dev/null ;;
    q|Q) exit 0 ;;
    *) echo "Invalid choice" ;;
esac
