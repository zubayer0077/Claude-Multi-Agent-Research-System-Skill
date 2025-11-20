#!/bin/bash
# Restore archived project specs from timestamp
# Usage: restore_archive.sh <project-slug> <timestamp>
# Example: restore_archive.sh task-tracker-pwa 20251120-094500

set -euo pipefail

PROJECT_SLUG="$1"
TIMESTAMP="$2"
PROJECT_DIR="docs/projects/$PROJECT_SLUG"
ARCHIVE_DIR="$PROJECT_DIR/.archive/$TIMESTAMP"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "♻️  Restore Archive: $PROJECT_SLUG"
echo "─────────────────────────────────────"

# Validation: Check if archive exists
if [ ! -d "$ARCHIVE_DIR" ]; then
    echo -e "${RED}❌ ERROR: Archive not found${NC}"
    echo "   Expected: $ARCHIVE_DIR"
    exit 1
fi

# Check if archive has content
if [ ! -d "$ARCHIVE_DIR/planning" ] && [ ! -d "$ARCHIVE_DIR/adrs" ]; then
    echo -e "${RED}❌ ERROR: Archive is empty or corrupted${NC}"
    echo "   No planning/ or adrs/ directories found in archive"
    exit 1
fi

# Show archive metadata if exists
if [ -f "$ARCHIVE_DIR/archive_metadata.json" ]; then
    echo "📋 Archive Metadata:"
    cat "$ARCHIVE_DIR/archive_metadata.json" | python3 -m json.tool
    echo ""
fi

# Warn if current specs exist
if [ -d "$PROJECT_DIR/planning" ] || [ -d "$PROJECT_DIR/adrs" ]; then
    echo -e "${YELLOW}⚠️  WARNING: Current specs will be overwritten${NC}"
    echo ""
    echo "Current files will be backed up to:"
    echo "   $PROJECT_DIR/.archive/backup-before-restore-$(date +%Y%m%d-%H%M%S)"
    echo ""
    read -p "Continue with restore? (yes/no): " -r CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "Restore cancelled"
        exit 0
    fi

    # Backup current state before restoring
    BACKUP_TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    BACKUP_DIR="$PROJECT_DIR/.archive/backup-before-restore-$BACKUP_TIMESTAMP"
    echo ""
    echo "📦 Creating backup of current specs..."
    mkdir -p "$BACKUP_DIR"
    [ -d "$PROJECT_DIR/planning" ] && cp -r "$PROJECT_DIR/planning" "$BACKUP_DIR/"
    [ -d "$PROJECT_DIR/adrs" ] && cp -r "$PROJECT_DIR/adrs" "$BACKUP_DIR/"
    echo -e "${GREEN}✅ Backup created${NC}"
fi

# Remove current specs
echo ""
echo "🗑️  Removing current specs..."
rm -rf "$PROJECT_DIR/planning" "$PROJECT_DIR/adrs"

# Restore from archive
echo ""
echo "📂 Restoring from archive..."

if [ -d "$ARCHIVE_DIR/planning" ]; then
    cp -r "$ARCHIVE_DIR/planning" "$PROJECT_DIR/"
    RESTORED_PLANNING=$(find "$PROJECT_DIR/planning" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    echo -e "${GREEN}   ✅ planning/ restored ($RESTORED_PLANNING files)${NC}"
fi

if [ -d "$ARCHIVE_DIR/adrs" ]; then
    cp -r "$ARCHIVE_DIR/adrs" "$PROJECT_DIR/"
    RESTORED_ADRS=$(find "$PROJECT_DIR/adrs" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    echo -e "${GREEN}   ✅ adrs/ restored ($RESTORED_ADRS files)${NC}"
fi

echo ""
echo "═══════════════════════════════════════"
echo -e "${GREEN}✅ Restore completed successfully${NC}"
echo "═══════════════════════════════════════"
echo "Restored from: $ARCHIVE_DIR"
echo ""
