#!/bin/bash
# Archive existing project specs to timestamped directory
# Usage: archive_project.sh <project-slug>
# Example: archive_project.sh task-tracker-pwa

set -euo pipefail

PROJECT_SLUG="$1"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
PROJECT_DIR="docs/projects/$PROJECT_SLUG"
ARCHIVE_DIR="$PROJECT_DIR/.archive/$TIMESTAMP"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🗄️  Archive Project: $PROJECT_SLUG"
echo "─────────────────────────────────────"

# Validation: Check if project exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ ERROR: Project directory not found${NC}"
    echo "   Expected: $PROJECT_DIR"
    exit 1
fi

# Validation: Check if planning or adrs directories exist
if [ ! -d "$PROJECT_DIR/planning" ] && [ ! -d "$PROJECT_DIR/adrs" ]; then
    echo -e "${RED}❌ ERROR: No planning/ or adrs/ directories found${NC}"
    echo "   Nothing to archive in $PROJECT_DIR"
    exit 1
fi

# Check for existing files to archive
FILES_TO_ARCHIVE=$(find "$PROJECT_DIR" -maxdepth 2 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$FILES_TO_ARCHIVE" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  WARNING: No .md files found to archive${NC}"
    exit 0
fi

echo "📦 Files to archive: $FILES_TO_ARCHIVE"
echo "📅 Timestamp: $TIMESTAMP"
echo "📂 Archive location: $ARCHIVE_DIR"
echo ""

# Create archive directory structure
echo "Creating archive directory..."
mkdir -p "$ARCHIVE_DIR"

# Archive planning directory if exists
if [ -d "$PROJECT_DIR/planning" ]; then
    echo "📁 Archiving planning/ directory..."
    if cp -r "$PROJECT_DIR/planning" "$ARCHIVE_DIR/"; then
        echo -e "${GREEN}   ✅ planning/ archived${NC}"
    else
        echo -e "${RED}   ❌ Failed to archive planning/${NC}"
        # Cleanup partial archive
        rm -rf "$ARCHIVE_DIR"
        exit 1
    fi
fi

# Archive adrs directory if exists
if [ -d "$PROJECT_DIR/adrs" ]; then
    echo "📁 Archiving adrs/ directory..."
    if cp -r "$PROJECT_DIR/adrs" "$ARCHIVE_DIR/"; then
        echo -e "${GREEN}   ✅ adrs/ archived${NC}"
    else
        echo -e "${RED}   ❌ Failed to archive adrs/${NC}"
        # Cleanup partial archive
        rm -rf "$ARCHIVE_DIR"
        exit 1
    fi
fi

# Create archive metadata
METADATA_FILE="$ARCHIVE_DIR/archive_metadata.json"
cat > "$METADATA_FILE" <<EOF
{
  "project_slug": "$PROJECT_SLUG",
  "archived_at": "$TIMESTAMP",
  "archived_at_iso": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "reason": "User requested archive before fresh planning",
  "files_archived": $FILES_TO_ARCHIVE
}
EOF

echo ""
echo "📋 Archive metadata created"

# Verify archive integrity
echo ""
echo "🔍 Verifying archive integrity..."
ARCHIVED_FILES=$(find "$ARCHIVE_DIR" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$ARCHIVED_FILES" -eq "$FILES_TO_ARCHIVE" ]; then
    echo -e "${GREEN}✅ Archive integrity verified ($ARCHIVED_FILES files)${NC}"
else
    echo -e "${RED}❌ Archive integrity check FAILED${NC}"
    echo "   Expected: $FILES_TO_ARCHIVE files"
    echo "   Found: $ARCHIVED_FILES files"
    exit 1
fi

# Now safe to delete originals
echo ""
echo "🗑️  Removing original files..."
if [ -d "$PROJECT_DIR/planning" ]; then
    rm -rf "$PROJECT_DIR/planning"
    echo -e "${GREEN}   ✅ planning/ removed${NC}"
fi

if [ -d "$PROJECT_DIR/adrs" ]; then
    rm -rf "$PROJECT_DIR/adrs"
    echo -e "${GREEN}   ✅ adrs/ removed${NC}"
fi

# Create fresh directories
echo ""
echo "📁 Creating fresh directory structure..."
mkdir -p "$PROJECT_DIR/planning"
mkdir -p "$PROJECT_DIR/adrs"
echo -e "${GREEN}✅ Fresh directories created${NC}"

echo ""
echo "═══════════════════════════════════════"
echo -e "${GREEN}✅ Archive completed successfully${NC}"
echo "═══════════════════════════════════════"
echo "Archive location: $ARCHIVE_DIR"
echo "Files archived: $FILES_TO_ARCHIVE"
echo "Restore command: .claude/utils/restore_archive.sh $PROJECT_SLUG $TIMESTAMP"
echo ""
